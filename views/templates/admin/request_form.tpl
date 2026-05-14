{* Admin — Create / Edit paiementfacilite request *}

<div class="panel" id="pf-form-wrap">

  <div class="panel-heading">
    <i class="icon-file-text"></i>
    {if $pf_is_add}
      {l s='Nouvelle demande de facilité' mod='paiementfacilite'}
    {else}
      {l s='Modifier la demande' mod='paiementfacilite'} <strong>#{ $pf_obj->id|intval}</strong>
    {/if}
  </div>

  <form id="pf-admin-form" method="post" action="{$pf_form_action|escape:'html'}"
        enctype="multipart/form-data">

    <input type="hidden" name="submitAddpf_requests" value="1">
    {if !$pf_is_add}
    <input type="hidden" name="id_request" value="{$pf_obj->id|intval}">
    {/if}

    {* ══════════════════════════════════════════════
       SECTION 1 — CLIENT
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default">
      <div class="panel-heading">{l s='Client' mod='paiementfacilite'}</div>
      <div class="panel-body">

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Rechercher un client' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-7" style="position:relative;">
            <input type="text" id="pf-customer-search" class="form-control"
                   autocomplete="off"
                   placeholder="{l s='Nom, prénom, email ou téléphone…' mod='paiementfacilite'}"
                   value="{if $pf_customer}{$pf_customer->firstname|escape:'html'} {$pf_customer->lastname|escape:'html'} — {$pf_customer->email|escape:'html'}{/if}">
            <input type="hidden" name="id_customer" id="pf-id-customer"
                   value="{$pf_obj->id_customer|intval}">
            <div id="pf-customer-dropdown"></div>
          </div>
          <div class="col-lg-2">
            <span id="pf-customer-clear" class="btn btn-default btn-sm"
                  style="{if !$pf_customer}display:none;{/if}">
              <i class="icon-times"></i>
            </span>
          </div>
        </div>

        <div class="form-group" id="pf-address-wrap"
             {if !$pf_customer}style="display:none;"{/if}>
          <label class="control-label col-lg-3">
            {l s='Adresse' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-6">
            <select name="id_address" id="pf-address-select" class="form-control">
              {foreach $pf_addresses as $addr}
              <option value="{$addr.id_address|intval}"
                      {if $pf_obj->id_address == $addr.id_address}selected{/if}>
                {$addr.alias|escape:'html'} — {$addr.address1|escape:'html'}, {$addr.city|escape:'html'}
              </option>
              {/foreach}
            </select>
          </div>
          <div class="col-lg-3">
            <button type="button" id="pf-add-addr-btn" class="btn btn-default">
              <i class="icon-plus"></i> {l s='Nouvelle adresse' mod='paiementfacilite'}
            </button>
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       SECTION 2 — TYPE DE CLIENT
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default">
      <div class="panel-heading">{l s='Type de client' mod='paiementfacilite'}</div>
      <div class="panel-body">

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Type' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-9">
            <label class="radio-inline" style="margin-right:20px;">
              <input type="radio" name="is_company" id="ic0" value="0"
                     {if !$pf_obj->is_company}checked{/if}>
              {l s='Salarié / Retraité' mod='paiementfacilite'}
            </label>
            <label class="radio-inline">
              <input type="radio" name="is_company" id="ic1" value="1"
                     {if $pf_obj->is_company}checked{/if}>
              {l s='Société' mod='paiementfacilite'}
            </label>
          </div>
        </div>

        <div class="form-group" id="pf-retired-row"
             {if $pf_obj->is_company}style="display:none;"{/if}>
          <label class="control-label col-lg-3">
            {l s='Retraité ?' mod='paiementfacilite'}
          </label>
          <div class="col-lg-9">
            <label class="radio-inline" style="margin-right:20px;">
              <input type="radio" name="is_retired" id="ir0" value="0"
                     {if !$pf_obj->is_retired}checked{/if}>
              {l s='Non' mod='paiementfacilite'}
            </label>
            <label class="radio-inline">
              <input type="radio" name="is_retired" id="ir1" value="1"
                     {if $pf_obj->is_retired}checked{/if}>
              {l s='Oui' mod='paiementfacilite'}
            </label>
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       SECTION 3 — ORGANISME
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default">
      <div class="panel-heading">{l s='Organisme partenaire' mod='paiementfacilite'}</div>
      <div class="panel-body">

        <div class="form-group">
          <label class="control-label col-lg-3">{l s='Organisme' mod='paiementfacilite'}</label>
          <div class="col-lg-5">
            <select name="id_organisation" id="pf-org-select" class="form-control">
              {foreach $pf_organisations as $org}
              <option value="{$org.id_organisation|intval}"
                      {if $pf_obj->id_organisation == $org.id_organisation}selected{/if}>
                {$org.name|escape:'html'}
              </option>
              {/foreach}
            </select>
          </div>
        </div>

        <div class="form-group" id="pf-org-autre-row"
             {if !$pf_obj->organisation_autre}style="display:none;"{/if}>
          <label class="control-label col-lg-3">
            {l s='Préciser l\'organisme' mod='paiementfacilite'}
          </label>
          <div class="col-lg-5">
            <input type="text" name="organisation_autre" class="form-control"
                   value="{$pf_obj->organisation_autre|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Membre partenaire' mod='paiementfacilite'}
          </label>
          <div class="col-lg-9">
            <span class="switch prestashop-switch fixed-width-lg">
              <input type="radio" name="belongs_to_partner" id="bp1" value="1"
                     {if $pf_obj->belongs_to_partner}checked{/if}>
              <label for="bp1">{l s='Oui' mod='paiementfacilite'}</label>
              <input type="radio" name="belongs_to_partner" id="bp0" value="0"
                     {if !$pf_obj->belongs_to_partner}checked{/if}>
              <label for="bp0">{l s='Non' mod='paiementfacilite'}</label>
              <a class="slide-button btn"></a>
            </span>
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       SECTION 4a — INFOS PERSONNELLES (individuel)
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default" id="pf-individual-section"
         {if $pf_obj->is_company}style="display:none;"{/if}>
      <div class="panel-heading">{l s='Informations personnelles' mod='paiementfacilite'}</div>
      <div class="panel-body">

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Date de naissance' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-3">
            <input type="date" name="date_naissance" class="form-control"
                   value="{$pf_obj->date_naissance|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='CIN' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-3">
            <input type="text" name="cin" class="form-control"
                   value="{$pf_obj->cin|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Fonction / Profession' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-5">
            <input type="text" name="fonction" class="form-control"
                   value="{$pf_obj->fonction|escape:'html'}">
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       SECTION 4b — INFOS SOCIÉTÉ
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default" id="pf-company-section"
         {if !$pf_obj->is_company}style="display:none;"{/if}>
      <div class="panel-heading">{l s='Informations de la société' mod='paiementfacilite'}</div>
      <div class="panel-body">

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Raison sociale' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-6">
            <input type="text" name="raison_sociale" class="form-control"
                   value="{$pf_obj->raison_sociale|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Matricule fiscal' mod='paiementfacilite'}
          </label>
          <div class="col-lg-4">
            <input type="text" name="matricule_fiscal" class="form-control"
                   value="{$pf_obj->matricule_fiscal|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Représentant légal' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-5">
            <input type="text" name="representant_legal" class="form-control"
                   value="{$pf_obj->representant_legal|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Date de naissance gérant' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-3">
            <input type="date" name="date_naissance_gerant" class="form-control"
                   value="{$pf_obj->date_naissance_gerant|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='CIN gérant' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-3">
            <input type="text" name="cin_gerant" class="form-control"
                   value="{$pf_obj->cin_gerant|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Téléphone gérant' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-3">
            <input type="text" name="telephone_gerant" class="form-control"
                   value="{$pf_obj->telephone_gerant|escape:'html'}">
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Email gérant' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-4">
            <input type="email" name="email_gerant" class="form-control"
                   value="{$pf_obj->email_gerant|escape:'html'}">
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       SECTION 5 — CRÉDIT
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default">
      <div class="panel-heading">{l s='Détails du crédit' mod='paiementfacilite'}</div>
      <div class="panel-body">

        <div class="row" style="margin-left:0;margin-right:0;">
          <div class="col-md-3">
            <div class="form-group">
              <label>{l s='Montant (DT)' mod='paiementfacilite'} <span class="required">*</span></label>
              <input type="number" step="0.01" min="0" name="credit_amount" id="pf-credit-amount"
                     class="form-control"
                     value="{$pf_obj->credit_amount|floatval}">
            </div>
          </div>
          <div class="col-md-3">
            <div class="form-group">
              <label>{l s='1ère tranche (DT)' mod='paiementfacilite'}</label>
              <input type="number" step="0.01" min="0" name="premiere_tranche"
                     id="pf-premiere-tranche" class="form-control"
                     value="{$pf_obj->premiere_tranche|floatval}">
            </div>
          </div>
          <div class="col-md-2">
            <div class="form-group">
              <label>{l s='Nb mois' mod='paiementfacilite'}</label>
              <select name="nb_mois" id="pf-nb-mois" class="form-control">
                {for $m = 2 to 12}
                <option value="{$m}" {if $pf_obj->nb_mois == $m || ($pf_is_add && $m == 6)}selected{/if}>
                  {$m}
                </option>
                {/for}
              </select>
            </div>
          </div>
          <div class="col-md-3">
            <div class="form-group">
              <label>
                {l s='Mensualité (DT)' mod='paiementfacilite'}
                <small class="text-muted"> — {l s='auto si 0' mod='paiementfacilite'}</small>
              </label>
              <input type="number" step="0.01" min="0" name="mensualite" id="pf-mensualite"
                     class="form-control"
                     value="{$pf_obj->mensualite|floatval}">
            </div>
          </div>
        </div>

        <div class="form-group">
          <label class="control-label col-lg-3">{l s='Commentaire' mod='paiementfacilite'}</label>
          <div class="col-lg-8">
            <textarea name="commentaire" class="form-control" rows="3"
                      >{$pf_obj->commentaire|escape:'html'}</textarea>
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       SECTION 6 — DOCUMENTS
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default" id="pf-docs-panel">
      <div class="panel-heading">{l s='Documents' mod='paiementfacilite'}</div>
      <div class="panel-body">

        {* Existing docs *}
        {if $pf_docs}
        <div class="alert alert-info" style="margin-bottom:20px;">
          <strong>{l s='Fichiers déjà enregistrés' mod='paiementfacilite'}</strong>
          <ul class="list-unstyled" style="margin:6px 0 0;">
            {foreach $pf_docs as $doc}
            <li>
              <i class="icon-file-o"></i>
              {if isset($doc_labels[$doc.doc_type])}{$doc_labels[$doc.doc_type]}{else}{$doc.doc_type|escape:'html'}{/if}
              &nbsp;—&nbsp;{$doc.filename|escape:'html'}
            </li>
            {/foreach}
          </ul>
          <p class="help-block" style="margin:6px 0 0;">
            {l s='Les nouveaux fichiers s\'ajoutent aux existants.' mod='paiementfacilite'}
          </p>
        </div>
        {/if}

        <p class="help-block">{l s='PNG, JPEG ou PDF — 5 MB max par fichier.' mod='paiementfacilite'}</p>

        {* ── Salarié ── *}
        <div id="pf-docs-salarie"
             {if $pf_obj->is_company || $pf_obj->is_retired}style="display:none;"{/if}>
          <h5 class="pf-doc-section-title">{l s='Salarié' mod='paiementfacilite'}</h5>
          <div class="row">
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='CIN Recto' mod='paiementfacilite'}</label>
                <input type="file" name="cin_recto" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='CIN Verso' mod='paiementfacilite'}</label>
                <input type="file" name="cin_verso" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='Facture STEG / SONEDE' mod='paiementfacilite'}</label>
                <input type="file" name="facture_steg" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='RIB' mod='paiementfacilite'}</label>
                <input type="file" name="rib" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label>{l s='Fiches de paie (3 max)' mod='paiementfacilite'}</label>
            <input type="file" name="fiche_paie[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="fiche_paie[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="fiche_paie[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
          </div>
          <div class="form-group">
            <label>{l s='Relevés bancaires (3 max)' mod='paiementfacilite'}</label>
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
          </div>
        </div>

        {* ── Retraité ── *}
        <div id="pf-docs-retraite"
             {if !$pf_obj->is_retired || $pf_obj->is_company}style="display:none;"{/if}>
          <h5 class="pf-doc-section-title">{l s='Retraité' mod='paiementfacilite'}</h5>
          <div class="row">
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='CIN Recto' mod='paiementfacilite'}</label>
                <input type="file" name="cin_recto" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='CIN Verso' mod='paiementfacilite'}</label>
                <input type="file" name="cin_verso" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='Facture STEG / SONEDE' mod='paiementfacilite'}</label>
                <input type="file" name="facture_steg" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='Attestation de retraite' mod='paiementfacilite'}</label>
                <input type="file" name="attestation_retraite" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='RIB' mod='paiementfacilite'}</label>
                <input type="file" name="rib" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label>{l s='Relevés bancaires (3 max)' mod='paiementfacilite'}</label>
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
          </div>
        </div>

        {* ── Société ── *}
        <div id="pf-docs-societe"
             {if !$pf_obj->is_company}style="display:none;"{/if}>
          <h5 class="pf-doc-section-title">{l s='Société' mod='paiementfacilite'}</h5>
          <div class="row">
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='Copie RNE' mod='paiementfacilite'}</label>
                <input type="file" name="copie_rne" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='CIN Gérant Recto' mod='paiementfacilite'}</label>
                <input type="file" name="cin_gerant_recto" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='CIN Gérant Verso' mod='paiementfacilite'}</label>
                <input type="file" name="cin_gerant_verso" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-group">
                <label>{l s='RIB' mod='paiementfacilite'}</label>
                <input type="file" name="rib" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
              </div>
            </div>
          </div>
          <div class="form-group">
            <label>{l s='Relevés bancaires (3 max)' mod='paiementfacilite'}</label>
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf" style="margin-bottom:4px;">
            <input type="file" name="releve_bancaire[]" class="form-control-file" accept=".jpg,.jpeg,.png,.pdf">
          </div>
        </div>

      </div>
    </div>

    {* ══════════════════════════════════════════════
       STATUT
    ══════════════════════════════════════════════ *}
    <div class="panel panel-default">
      <div class="panel-body">
        <div class="form-group">
          <label class="control-label col-lg-3">
            {l s='Statut' mod='paiementfacilite'} <span class="required">*</span>
          </label>
          <div class="col-lg-3">
            <select name="status" class="form-control">
              <option value="pending"
                {if $pf_obj->status == 'pending' || $pf_is_add}selected{/if}>
                {l s='En attente' mod='paiementfacilite'}
              </option>
              <option value="approved"
                {if $pf_obj->status == 'approved'}selected{/if}>
                {l s='Approuvé' mod='paiementfacilite'}
              </option>
              <option value="rejected"
                {if $pf_obj->status == 'rejected'}selected{/if}>
                {l s='Rejeté' mod='paiementfacilite'}
              </option>
            </select>
          </div>
        </div>
      </div>
    </div>

    {* ── Footer ── *}
    <div class="panel-footer">
      <a href="{$pf_back_url|escape:'html'}" class="btn btn-default">
        <i class="process-icon-cancel"></i> {l s='Annuler' mod='paiementfacilite'}
      </a>
      <button type="submit" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Enregistrer' mod='paiementfacilite'}
      </button>
    </div>

  </form>

</div>{* /panel *}

{* ══════════════════════════════════════════════
   MODAL — Nouvelle adresse
══════════════════════════════════════════════ *}
<div class="modal fade" id="pf-addr-modal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">
          <i class="icon-map-marker"></i> {l s='Nouvelle adresse' mod='paiementfacilite'}
        </h4>
      </div>
      <div class="modal-body">
        <div id="pf-addr-error" class="alert alert-danger" style="display:none;"></div>
        <div class="form-group">
          <label>{l s='Alias' mod='paiementfacilite'} *</label>
          <input type="text" id="pf-addr-alias" class="form-control" placeholder="Domicile">
        </div>
        <div class="row">
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Prénom' mod='paiementfacilite'} *</label>
              <input type="text" id="pf-addr-firstname" class="form-control">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Nom' mod='paiementfacilite'} *</label>
              <input type="text" id="pf-addr-lastname" class="form-control">
            </div>
          </div>
        </div>
        <div class="form-group">
          <label>{l s='Adresse' mod='paiementfacilite'} *</label>
          <input type="text" id="pf-addr-address1" class="form-control">
        </div>
        <div class="row">
          <div class="col-sm-4">
            <div class="form-group">
              <label>{l s='Code postal' mod='paiementfacilite'} *</label>
              <input type="text" id="pf-addr-postcode" class="form-control">
            </div>
          </div>
          <div class="col-sm-8">
            <div class="form-group">
              <label>{l s='Ville' mod='paiementfacilite'} *</label>
              <input type="text" id="pf-addr-city" class="form-control">
            </div>
          </div>
        </div>
        <div class="form-group">
          <label>{l s='Téléphone' mod='paiementfacilite'}</label>
          <input type="text" id="pf-addr-phone" class="form-control">
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">
          {l s='Annuler' mod='paiementfacilite'}
        </button>
        <button type="button" class="btn btn-primary" id="pf-addr-save-btn">
          <i class="icon-save"></i> {l s='Sauvegarder' mod='paiementfacilite'}
        </button>
      </div>
    </div>
  </div>
</div>

<style>
#pf-customer-dropdown {
  position: absolute; top: 100%; left: 0; right: 0; z-index: 9999;
  background: #fff; border: 1px solid #ccc; border-top: none;
  border-radius: 0 0 4px 4px; max-height: 260px; overflow-y: auto;
  box-shadow: 0 4px 8px rgba(0,0,0,.1);
  display: none;
}
#pf-customer-dropdown .pf-ac-item {
  padding: 8px 12px; cursor: pointer; font-size: 13px; border-bottom: 1px solid #f0f0f0;
}
#pf-customer-dropdown .pf-ac-item:last-child { border-bottom: none; }
#pf-customer-dropdown .pf-ac-item:hover,
#pf-customer-dropdown .pf-ac-item.active { background: #f0f4ff; }
#pf-customer-dropdown .pf-ac-loading { padding: 10px 12px; color: #999; font-style: italic; }
.pf-doc-section-title {
  font-size: 13px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .06em; color: #555; border-bottom: 1px solid #e5e5e5;
  padding-bottom: 6px; margin: 16px 0 12px;
}
</style>

<script>
(function ($) {
  'use strict';

  var ajaxUrl = '{$pf_ajax_url|escape:"javascript"}';
  var searchTimer = null;
  var currentCustomerId = parseInt($('#pf-id-customer').val()) || 0;

  /* ── Customer autocomplete ── */
  $('#pf-customer-search').on('input', function () {
    var q = $(this).val().trim();
    clearTimeout(searchTimer);
    if (q.length < 2) { $('#pf-customer-dropdown').hide().empty(); return; }
    searchTimer = setTimeout(function () { doSearch(q); }, 300);
  }).on('focus', function () {
    if ($(this).val().trim().length >= 2) doSearch($(this).val().trim());
  });

  function doSearch(q) {
    var $dd = $('#pf-customer-dropdown');
    $dd.html('<div class="pf-ac-loading">Recherche…</div>').show();
    $.getJSON(ajaxUrl + '&ajax=1&action=searchCustomers', { q: q }, function (rows) {
      $dd.empty();
      if (!rows.length) {
        $dd.html('<div class="pf-ac-loading">Aucun résultat.</div>');
        return;
      }
      $.each(rows, function (i, r) {
        $('<div class="pf-ac-item">')
          .text(r.label)
          .data('row', r)
          .appendTo($dd);
      });
    });
  }

  $(document).on('click', '#pf-customer-dropdown .pf-ac-item', function () {
    var r = $(this).data('row');
    $('#pf-customer-search').val(r.label);
    $('#pf-id-customer').val(r.id);
    currentCustomerId = r.id;
    $('#pf-customer-dropdown').hide().empty();
    $('#pf-customer-clear').show();
    loadAddresses(r.id);
  });

  $(document).on('click', function (e) {
    if (!$(e.target).closest('#pf-customer-search, #pf-customer-dropdown').length) {
      $('#pf-customer-dropdown').hide();
    }
  });

  $('#pf-customer-clear').on('click', function () {
    $('#pf-customer-search').val('');
    $('#pf-id-customer').val(0);
    currentCustomerId = 0;
    $(this).hide();
    $('#pf-address-wrap').hide();
    $('#pf-address-select').empty();
  });

  /* ── Address loading ── */
  function loadAddresses(id_customer) {
    $.getJSON(ajaxUrl + '&ajax=1&action=getCustomerAddresses', { id_customer: id_customer },
      function (addresses) {
        var $sel = $('#pf-address-select').empty();
        $.each(addresses, function (i, a) {
          $('<option>').val(a.id_address).text(a.label).appendTo($sel);
        });
        $('#pf-address-wrap').show();
      }
    );
  }

  /* ── Type toggle ── */
  $('input[name=is_company]').on('change', function () {
    var isCompany = $(this).val() == 1;
    $('#pf-retired-row').toggle(!isCompany);
    $('#pf-individual-section').toggle(!isCompany);
    $('#pf-company-section').toggle(isCompany);
    updateDocSections();
    disableHiddenDocs();
  });

  $('input[name=is_retired]').on('change', function () {
    updateDocSections();
    disableHiddenDocs();
  });

  function updateDocSections() {
    var isCompany = $('input[name=is_company]:checked').val() == 1;
    var isRetired = $('input[name=is_retired]:checked').val() == 1;
    $('#pf-docs-salarie').toggle(!isCompany && !isRetired);
    $('#pf-docs-retraite').toggle(!isCompany && isRetired);
    $('#pf-docs-societe').toggle(isCompany);
  }

  function disableHiddenDocs() {
    // Disable inputs in hidden doc groups so they aren't submitted
    $('#pf-docs-panel input[type=file]').prop('disabled', false);
    $('#pf-docs-salarie, #pf-docs-retraite, #pf-docs-societe').each(function () {
      if ($(this).is(':hidden')) {
        $(this).find('input[type=file]').prop('disabled', true);
      }
    });
  }

  /* ── Organisation ── */
  $('#pf-org-select').on('change', function () {
    var val = parseInt($(this).val());
    $('#pf-org-autre-row').toggle(val === -1 || val === 0);
  });

  /* ── Mensualité auto-calc ── */
  $('#pf-credit-amount, #pf-premiere-tranche, #pf-nb-mois').on('input change', function () {
    var credit  = parseFloat($('#pf-credit-amount').val())      || 0;
    var tranche = parseFloat($('#pf-premiere-tranche').val())   || 0;
    var nb      = parseInt($('#pf-nb-mois').val())              || 6;
    if (credit > 0 && tranche < credit && nb > 0) {
      var m = Math.round(((credit - tranche) / nb) * 100) / 100;
      if (!parseFloat($('#pf-mensualite').val())) {
        $('#pf-mensualite').val(m.toFixed(2));
      }
    }
  });

  /* ── Add address modal ── */
  $('#pf-add-addr-btn').on('click', function () {
    $('#pf-addr-error').hide().empty();
    $('#pf-addr-modal input').val('');
    $('#pf-addr-modal').modal('show');
  });

  $('#pf-addr-save-btn').on('click', function () {
    var $btn = $(this).prop('disabled', true);
    var $err = $('#pf-addr-error');
    $err.hide().empty();

    $.post(ajaxUrl + '&ajax=1&action=saveNewAddress', {
      id_customer: currentCustomerId,
      alias:       $('#pf-addr-alias').val(),
      firstname:   $('#pf-addr-firstname').val(),
      lastname:    $('#pf-addr-lastname').val(),
      address1:    $('#pf-addr-address1').val(),
      postcode:    $('#pf-addr-postcode').val(),
      city:        $('#pf-addr-city').val(),
      phone:       $('#pf-addr-phone').val(),
    }, function (resp) {
      $btn.prop('disabled', false);
      if (!resp.success) { $err.text(resp.error || 'Erreur.').show(); return; }
      var $sel = $('#pf-address-select').empty();
      $.each(resp.addresses, function (i, a) {
        var $opt = $('<option>').val(a.id_address).text(a.label);
        if (a.id_address === resp.id_address) $opt.prop('selected', true);
        $opt.appendTo($sel);
      });
      $('#pf-addr-modal').modal('hide');
    }, 'json').fail(function () {
      $btn.prop('disabled', false);
      $err.text('Erreur de connexion.').show();
    });
  });

  /* ── Init on load ── */
  updateDocSections();
  disableHiddenDocs();

})(jQuery);
</script>
