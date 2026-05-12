{extends file='page.tpl'}

{block name='page_title'}
  {l s='Demande de paiement par facilité' mod='paiementfacilite'}
{/block}

{block name='page_content'}
<div class="pf-wrapper container-fluid">

  {* ── Error messages ── *}
  {* {if isset($smarty.cookie.pf_errors) && $smarty.cookie.pf_errors}
    {assign var="pf_errors_raw" value=$smarty.cookie.pf_errors}
  {/if} *}

  {* ── Progress bar ── *}
  <div class="pf-progress mb-4">
    <div class="pf-progress-steps d-flex justify-content-between">
      <div class="pf-step active" data-step="1"><span class="pf-step-num">1</span><small>{l s='Type' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="2"><span class="pf-step-num">2</span><small>{l s='Organisme' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="3"><span class="pf-step-num">3</span><small>{l s='Adresse' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="4"><span class="pf-step-num">4</span><small>{l s='Infos' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="5"><span class="pf-step-num">5</span><small>{l s='Crédit' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="6"><span class="pf-step-num">6</span><small>{l s='Documents' mod='paiementfacilite'}</small></div>
    </div>
    <div class="progress mt-2" style="height:6px;">
      <div class="progress-bar bg-primary" id="pf-progress-bar" role="progressbar" style="width:16%"></div>
    </div>
  </div>

  {* ── Alert container (JS fills this) ── *}
  <div id="pf-alerts"></div>

  <form id="pf-form"
        action="{$pf_form_action|escape:'html'}"
        method="POST"
        enctype="multipart/form-data"
        novalidate>

    <input type="hidden" name="submitPFRequest" value="1">
    <input type="hidden" name="id_order"  id="pf_id_order"  value="{$pf_id_order|intval}">
    <input type="hidden" name="id_cart"   id="pf_id_cart"   value="{$pf_id_cart|intval}">
    <input type="hidden" name="id_address" id="pf_id_address_hidden" value="{$pf_selected_address_id|intval}">
    <input type="hidden" name="belongs_to_partner" id="pf_belongs_to_partner" value="0">

    {* ======================================================
       STEP 1 — CLIENT TYPE
       ====================================================== *}
    <div class="pf-card pf-step-panel active" data-step="1">
      <div class="pf-card-header">
        <h3>{l s='Quel est votre statut ?' mod='paiementfacilite'}</h3>
      </div>
      <div class="pf-card-body">
        <div class="row justify-content-center">
          <div class="col-md-5 mb-3">
            <label class="pf-type-card" data-value="0">
              <input type="radio" name="is_company" value="0" class="pf-radio-type" required>
              <div class="pf-type-inner">
                <i class="pf-icon-person"></i>
                <strong>{l s='Salarié ou Retraité' mod='paiementfacilite'}</strong>
              </div>
            </label>
          </div>
          <div class="col-md-5 mb-3">
            <label class="pf-type-card" data-value="1">
              <input type="radio" name="is_company" value="1" class="pf-radio-type">
              <div class="pf-type-inner">
                <i class="pf-icon-building"></i>
                <strong>{l s='Société' mod='paiementfacilite'}</strong>
              </div>
            </label>
          </div>
        </div>

        {* Retraité toggle — shown only for Salarié *}
        <div id="pf-retired-block" class="text-center mt-2" style="display:none;">
          <p class="mb-1">{l s='Êtes-vous retraité(e) ?' mod='paiementfacilite'}</p>
          <div class="btn-group" role="group">
            <label class="btn btn-outline-secondary pf-retired-btn" data-value="0">
              <input type="radio" name="is_retired" value="0" checked> {l s='Non' mod='paiementfacilite'}
            </label>
            <label class="btn btn-outline-secondary pf-retired-btn" data-value="1">
              <input type="radio" name="is_retired" value="1"> {l s='Oui' mod='paiementfacilite'}
            </label>
          </div>
        </div>
      </div>
      <div class="pf-card-footer text-right">
        <button type="button" class="btn btn-primary pf-next-btn" data-validates="is_company">
          {l s='Suivant' mod='paiementfacilite'} <i class="material-icons">chevron_right</i>
        </button>
      </div>
    </div>

    {* ======================================================
       STEP 2 — ORGANISATION
       ====================================================== *}
    <div class="pf-card pf-step-panel" data-step="2">
      <div class="pf-card-header">
        <h3>{l s='Êtes-vous membre d\'un organisme partenaire ?' mod='paiementfacilite'}</h3>
      </div>
      <div class="pf-card-body">
        <div class="form-group">
          <label for="pf-org-select">{l s='Organisme' mod='paiementfacilite'}</label>
          <select name="id_organisation" id="pf-org-select" class="form-control custom-select">
            <option value="0">{l s="N'appartient à aucun organisme" mod='paiementfacilite'}</option>
            {foreach $pf_organisations as $org}
              <option value="{$org.id_organisation|intval}">{$org.name|escape:'html'}</option>
            {/foreach}
            <option value="-1">{l s='Autre' mod='paiementfacilite'}</option>
          </select>
        </div>
        <div id="pf-org-autre-block" class="form-group" style="display:none;">
          <label for="pf-org-autre">{l s='Nom de l\'organisme' mod='paiementfacilite'} *</label>
          <input type="text" name="organisation_autre" id="pf-org-autre"
                 class="form-control" maxlength="255"
                 placeholder="{l s='Entrez le nom de l\'organisme' mod='paiementfacilite'}">
        </div>
        <div id="pf-partner-notice" class="alert alert-success" style="display:none;">
          <i class="material-icons align-middle">check_circle</i>
          {l s='En tant que membre d\'un organisme partenaire, vous êtes dispensé(e) de fournir des documents.' mod='paiementfacilite'}
        </div>
      </div>
      <div class="pf-card-footer d-flex justify-content-between">
        <button type="button" class="btn btn-outline-secondary pf-prev-btn">{l s='Précédent' mod='paiementfacilite'}</button>
        <button type="button" class="btn btn-primary pf-next-btn">{l s='Suivant' mod='paiementfacilite'}</button>
      </div>
    </div>

    {* ======================================================
       STEP 3 — ADDRESS
       ====================================================== *}
    <div class="pf-card pf-step-panel" data-step="3">
      <div class="pf-card-header">
        <h3>{l s='Votre adresse' mod='paiementfacilite'}</h3>
      </div>
      <div class="pf-card-body">

        {if $pf_is_from_checkout && $pf_selected_address_id}
          {* Context A: checkout — show billing address card first *}
          <div id="pf-billing-address-card" class="pf-address-card mb-3">
            <div class="pf-address-label">{l s='Adresse de facturation' mod='paiementfacilite'}</div>
            {foreach $pf_addresses as $addr}
              {if $addr.id_address == $pf_selected_address_id}
                <strong>{$addr.firstname|escape:'html'} {$addr.lastname|escape:'html'}</strong><br>
                {$addr.address1|escape:'html'}<br>
                {if $addr.address2}{$addr.address2|escape:'html'}<br>{/if}
                {$addr.postcode|escape:'html'} {$addr.city|escape:'html'}
              {/if}
            {/foreach}
          </div>
        {/if}

        <div class="form-group">
          <label for="pf-address-select">{l s='Choisir une adresse' mod='paiementfacilite'}</label>
          <select id="pf-address-select" class="form-control custom-select">
            {foreach $pf_addresses as $addr}
              <option value="{$addr.id_address|intval}"
                {if $addr.id_address == $pf_selected_address_id}selected{/if}>
                {$addr.alias|escape:'html'} — {$addr.address1|escape:'html'}, {$addr.city|escape:'html'}
              </option>
            {/foreach}
          </select>
        </div>

        <div class="text-right">
          <button type="button" class="btn btn-outline-primary btn-sm" id="pf-add-address-btn">
            <i class="material-icons align-middle" style="font-size:1rem;">add</i>
            {l s='+ Ajouter une nouvelle adresse' mod='paiementfacilite'}
          </button>
        </div>

      </div>
      <div class="pf-card-footer d-flex justify-content-between">
        <button type="button" class="btn btn-outline-secondary pf-prev-btn">{l s='Précédent' mod='paiementfacilite'}</button>
        <button type="button" class="btn btn-primary pf-next-btn">{l s='Suivant' mod='paiementfacilite'}</button>
      </div>
    </div>

    {* ======================================================
       STEP 4 — PERSONAL INFO (+ Société fields)
       ====================================================== *}
    <div class="pf-card pf-step-panel" data-step="4">
      <div class="pf-card-header">
        <h3>{l s='Informations personnelles' mod='paiementfacilite'}</h3>
      </div>
      <div class="pf-card-body">

        {* Common personal fields *}
        <div class="row">
          <div class="col-md-4 form-group">
            <label for="pf-date-naissance">{l s='Date de naissance' mod='paiementfacilite'} *</label>
            <input type="date" name="date_naissance" id="pf-date-naissance"
                   class="form-control" required
                   value="{$pf_birthday|escape:'html'}"
                   max="{$smarty.now|date_format:'%Y-%m-%d'}">
          </div>
          <div class="col-md-4 form-group">
            <label for="pf-fonction">{l s='Fonction / Profession' mod='paiementfacilite'} *</label>
            <input type="text" name="fonction" id="pf-fonction"
                   class="form-control" required maxlength="128">
          </div>
          <div class="col-md-4 form-group">
            <label for="pf-cin">{l s='Numéro de CIN' mod='paiementfacilite'} *</label>
            <input type="text" name="cin" id="pf-cin"
                   class="form-control" required maxlength="32"
                   placeholder="00000000">
          </div>
        </div>

        {* Société fields — shown only when is_company = 1 *}
        <div id="pf-company-fields" style="display:none;">
          <hr>
          <h5>{l s='Informations de la société' mod='paiementfacilite'}</h5>
          <div class="row">
            <div class="col-md-6 form-group">
              <label for="pf-raison-sociale">{l s='Raison Sociale' mod='paiementfacilite'} *</label>
              <input type="text" name="raison_sociale" id="pf-raison-sociale"
                     class="form-control" maxlength="255">
            </div>
            <div class="col-md-6 form-group">
              <label for="pf-matricule-fiscal">{l s='Matricule fiscal' mod='paiementfacilite'} *</label>
              <input type="text" name="matricule_fiscal" id="pf-matricule-fiscal"
                     class="form-control" maxlength="64">
            </div>
            <div class="col-md-4 form-group">
              <label for="pf-representant-legal">{l s='Représentant légal' mod='paiementfacilite'} *</label>
              <input type="text" name="representant_legal" id="pf-representant-legal"
                     class="form-control" maxlength="255">
            </div>
            <div class="col-md-4 form-group">
              <label for="pf-cin-gerant">{l s='CIN du gérant' mod='paiementfacilite'} *</label>
              <input type="text" name="cin_gerant" id="pf-cin-gerant"
                     class="form-control" maxlength="32">
            </div>
            <div class="col-md-4 form-group">
              <label for="pf-date-naissance-gerant">{l s='Date de naissance du gérant' mod='paiementfacilite'} *</label>
              <input type="date" name="date_naissance_gerant" id="pf-date-naissance-gerant"
                     class="form-control">
            </div>
          </div>
        </div>

      </div>
      <div class="pf-card-footer d-flex justify-content-between">
        <button type="button" class="btn btn-outline-secondary pf-prev-btn">{l s='Précédent' mod='paiementfacilite'}</button>
        <button type="button" class="btn btn-primary pf-next-btn" data-validates-step="4">{l s='Suivant' mod='paiementfacilite'}</button>
      </div>
    </div>

    {* ======================================================
       STEP 5 — DÉTAILS DU CRÉDIT
       ====================================================== *}
    <div class="pf-card pf-step-panel" data-step="5">
      <div class="pf-card-header">
        <h3>{l s='Détails du crédit' mod='paiementfacilite'}</h3>
      </div>
      <div class="pf-card-body">

        <div class="form-group">
          <label for="pf-credit-slider">
            {l s='Montant souhaité' mod='paiementfacilite'} :
            <strong id="pf-amount-display">{$pf_default_amount|intval} DT</strong>
          </label>
          <input type="range"
                 name="credit_amount"
                 id="pf-credit-slider"
                 class="pf-slider form-control-range"
                 min="{$pf_min_amount|intval}"
                 max="{$pf_max_amount|intval}"
                 step="50"
                 value="{$pf_default_amount|intval}">
          <div class="d-flex justify-content-between">
            <small class="text-muted">{$pf_min_amount|intval} DT</small>
            <small class="text-muted">{$pf_max_amount|intval} DT</small>
          </div>
        </div>

        <div class="row pf-credit-summary">
          <div class="col-md-4">
            <div class="pf-summary-card">
              <div class="pf-summary-label">{l s='1ère tranche (min 20%)' mod='paiementfacilite'}</div>
              <div class="pf-summary-value">
                <input type="number"
                       name="premiere_tranche"
                       id="pf-tranche"
                       class="form-control"
                       step="0.01"
                       required>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="pf-summary-card">
              <div class="pf-summary-label">{l s='Mensualité (sur 12 mois)' mod='paiementfacilite'}</div>
              <div class="pf-summary-value" id="pf-mensualite-display">— DT</div>
              <input type="hidden" name="mensualite" id="pf-mensualite" value="0">
            </div>
          </div>
          <div class="col-md-4">
            <div class="pf-summary-card">
              <div class="pf-summary-label">{l s='Montant total' mod='paiementfacilite'}</div>
              <div class="pf-summary-value" id="pf-total-display">{$pf_default_amount|intval} DT</div>
            </div>
          </div>
        </div>

        <div class="form-group mt-3">
          <label for="pf-commentaire">{l s='Commentaire (facultatif)' mod='paiementfacilite'}</label>
          <textarea name="commentaire" id="pf-commentaire" class="form-control" rows="3"
                    maxlength="2000"></textarea>
        </div>

      </div>
      <div class="pf-card-footer d-flex justify-content-between">
        <button type="button" class="btn btn-outline-secondary pf-prev-btn">{l s='Précédent' mod='paiementfacilite'}</button>
        <button type="button" class="btn btn-primary pf-next-btn" data-validates-step="5">{l s='Suivant' mod='paiementfacilite'}</button>
      </div>
    </div>

    {* ======================================================
       STEP 6 — DOCUMENTS (hidden if partner org)
       ====================================================== *}
    <div class="pf-card pf-step-panel" data-step="6" id="pf-docs-step">
      <div class="pf-card-header">
        <h3>{l s='Documents requis' mod='paiementfacilite'}</h3>
      </div>
      <div class="pf-card-body">

        <div class="alert alert-info">
          <i class="material-icons align-middle">info</i>
          {l s='Formats acceptés : PDF, JPEG, PNG. Taille max : 5 MB par fichier.' mod='paiementfacilite'}
        </div>

        {* Fiches de paie OR Attestation retraite *}
        <div class="pf-doc-group">
          <div id="pf-doc-salarie-block">
            <label class="pf-doc-label">
              {l s='Fiches de paie (3 dernières)' mod='paiementfacilite'} *
              <span class="badge badge-secondary">{l s='max 3 fichiers' mod='paiementfacilite'}</span>
            </label>
            <div class="pf-upload-zone" id="pf-drop-fiche">
              <input type="file" name="fiche_paie[]" id="pf-fiche-paie"
                     accept=".jpg,.jpeg,.png,.pdf" multiple data-max-files="3">
              <label for="pf-fiche-paie" class="pf-upload-label">
                <i class="material-icons">cloud_upload</i>
                {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
              </label>
              <div class="pf-file-list" id="pf-list-fiche"></div>
            </div>
          </div>
          <div id="pf-doc-retraite-block" style="display:none;">
            <label class="pf-doc-label">
              {l s='Attestation retraite CNSS/CNRPS' mod='paiementfacilite'} *
            </label>
            <div class="pf-upload-zone" id="pf-drop-att">
              <input type="file" name="attestation_retraite" id="pf-attestation"
                     accept=".jpg,.jpeg,.png,.pdf">
              <label for="pf-attestation" class="pf-upload-label">
                <i class="material-icons">cloud_upload</i>
                {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
              </label>
              <div class="pf-file-list" id="pf-list-att"></div>
            </div>
          </div>
        </div>

        {* CIN *}
        <div class="row pf-doc-group mt-3">
          <div class="col-md-6">
            <label class="pf-doc-label">{l s='CIN Recto' mod='paiementfacilite'} *</label>
            <div class="pf-upload-zone">
              <input type="file" name="cin_recto" id="pf-cin-recto" accept=".jpg,.jpeg,.png,.pdf">
              <label for="pf-cin-recto" class="pf-upload-label">
                <i class="material-icons">cloud_upload</i>
                {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
              </label>
              <div class="pf-file-list" id="pf-list-cin-recto"></div>
            </div>
          </div>
          <div class="col-md-6">
            <label class="pf-doc-label">{l s='CIN Verso' mod='paiementfacilite'} *</label>
            <div class="pf-upload-zone">
              <input type="file" name="cin_verso" id="pf-cin-verso" accept=".jpg,.jpeg,.png,.pdf">
              <label for="pf-cin-verso" class="pf-upload-label">
                <i class="material-icons">cloud_upload</i>
                {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
              </label>
              <div class="pf-file-list" id="pf-list-cin-verso"></div>
            </div>
          </div>
        </div>

        {* RIB *}
        <div class="pf-doc-group mt-3">
          <label class="pf-doc-label">{l s='RIB / Identité Bancaire' mod='paiementfacilite'} *</label>
          <div class="pf-upload-zone">
            <input type="file" name="rib" id="pf-rib" accept=".jpg,.jpeg,.png,.pdf">
            <label for="pf-rib" class="pf-upload-label">
              <i class="material-icons">cloud_upload</i>
              {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
            </label>
            <div class="pf-file-list" id="pf-list-rib"></div>
          </div>
        </div>

        {* Relevés bancaires *}
        <div class="pf-doc-group mt-3">
          <label class="pf-doc-label">
            {l s='Relevés bancaires (3 derniers)' mod='paiementfacilite'} *
            <span class="badge badge-secondary">{l s='max 3 fichiers' mod='paiementfacilite'}</span>
          </label>
          <div class="pf-upload-zone">
            <input type="file" name="releve_bancaire[]" id="pf-releve"
                   accept=".jpg,.jpeg,.png,.pdf" multiple data-max-files="3">
            <label for="pf-releve" class="pf-upload-label">
              <i class="material-icons">cloud_upload</i>
              {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
            </label>
            <div class="pf-file-list" id="pf-list-releve"></div>
          </div>
        </div>

        {* Facture STEG/SONEDE *}
        <div class="pf-doc-group mt-3">
          <label class="pf-doc-label">{l s='Dernière facture STEG ou SONEDE' mod='paiementfacilite'} *</label>
          <div class="pf-upload-zone">
            <input type="file" name="facture_steg" id="pf-facture-steg" accept=".jpg,.jpeg,.png,.pdf">
            <label for="pf-facture-steg" class="pf-upload-label">
              <i class="material-icons">cloud_upload</i>
              {l s='Cliquer ou glisser-déposer' mod='paiementfacilite'}
            </label>
            <div class="pf-file-list" id="pf-list-facture"></div>
          </div>
        </div>

        {* Partner org bypass message *}
        <div id="pf-docs-bypass" class="alert alert-success" style="display:none;">
          <i class="material-icons align-middle">check_circle</i>
          {l s='Documents non requis pour les membres d\'organismes partenaires.' mod='paiementfacilite'}
          {l s='Vous pouvez soumettre directement votre demande.' mod='paiementfacilite'}
        </div>

      </div>
      <div class="pf-card-footer d-flex justify-content-between">
        <button type="button" class="btn btn-outline-secondary pf-prev-btn">{l s='Précédent' mod='paiementfacilite'}</button>
        <button type="submit" class="btn btn-success btn-lg" id="pf-submit-btn">
          <i class="material-icons align-middle">send</i>
          {l s='Soumettre ma demande' mod='paiementfacilite'}
        </button>
      </div>
    </div>

  </form>{* /pf-form *}

</div>{* /pf-wrapper *}

{* ── Address Modal ── *}
{include file='module:paiementfacilite/views/templates/front/_partials/address-modal.tpl'}

{* ── Pass vars to JS ── *}
<script>
var PF_CONFIG = {
  ajaxUrl: '{$pf_ajax_url|escape:'javascript'}',
  minAmount: {$pf_min_amount|floatval},
  maxAmount: {$pf_max_amount|floatval},
  isFromCheckout: {if $pf_is_from_checkout}true{else}false{/if},
  hasAddresses: {if $pf_addresses}true{else}false{/if},
};
</script>
  {* errorsJson: '{if isset($smarty.cookie.pf_errors)}{$smarty.cookie.pf_errors|escape:'javascript'}{/if}' *}

{/block}
