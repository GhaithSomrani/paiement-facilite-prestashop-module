{* Admin — Create / Edit paiementfacilite request *}

<form id="pf-admin-form" method="post" action="{$pf_form_action|escape:'html'}"
      enctype="multipart/form-data" class="form-horizontal">

  <input type="hidden" name="submitAddpf_requests" value="1">
  {if !$pf_is_add}
  <input type="hidden" name="id_request" value="{$pf_obj->id|intval}">
  {/if}

  {* ══════════════════════════════════════════════
     SECTION 1 — CLIENT
  ══════════════════════════════════════════════ *}
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-user"></i>&nbsp;
      {if $pf_is_add}
        {l s='Nouvelle demande de facilité' mod='paiementfacilite'}
      {else}
        {l s='Modifier la demande' mod='paiementfacilite'} <strong>#{$pf_obj->id|intval}</strong>
      {/if}
    </div>
    <div class="panel-body">

      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='Rechercher un client' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-6" style="position:relative;">
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
                title="{l s='Effacer la sélection' mod='paiementfacilite'}"
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
        <div class="col-lg-5">
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

      <div class="form-group" id="pf-order-wrap"
           {if !$pf_customer}style="display:none;"{/if}>
        <label class="control-label col-lg-3">
          {l s='Commande liée' mod='paiementfacilite'}
        </label>
        <div class="col-lg-5">
          <select name="id_order_link" id="pf-order-select" class="form-control">
            <option value="0">{l s='— Aucune commande —' mod='paiementfacilite'}</option>
            {foreach $pf_orders as $order}
            <option value="{$order.id_order|intval}"
                    data-total="{$order.total|floatval}"
                    {if $pf_linked_order_id == $order.id_order}selected{/if}>
              {$order.label|escape:'html'}
            </option>
            {/foreach}
          </select>
        </div>
        <div class="col-lg-4">
          <p class="help-block" style="margin-top:7px;">
            <i class="icon-info-circle"></i>
            {l s='Optionnel. Le montant de la commande sera proposé pour le crédit.' mod='paiementfacilite'}
          </p>
        </div>
      </div>

    </div>
  </div>

  {* ══════════════════════════════════════════════
     SECTION 2 — TYPE DE CLIENT
  ══════════════════════════════════════════════ *}
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-briefcase"></i>&nbsp;{l s='Type de client' mod='paiementfacilite'}
    </div>
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
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-building"></i>&nbsp;{l s='Organisme partenaire' mod='paiementfacilite'}
    </div>
    <div class="panel-body">

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Organisme' mod='paiementfacilite'}</label>
        <div class="col-lg-5">
          <select name="id_organisation" id="pf-org-select" class="form-control" required>
            <option value="" disabled {if !$pf_obj->id_organisation && !$pf_obj->organisation_autre}selected{/if}>
              {l s='-- Sélectionnez un organisme --' mod='paiementfacilite'}
            </option>
            {foreach $pf_organisations as $org}
            {if $org.id_organisation > 0}
            <option value="{$org.id_organisation|intval}"
                    {if $pf_obj->id_organisation == $org.id_organisation && !$pf_obj->organisation_autre}selected{/if}>
              {$org.name|escape:'html'}
            </option>
            {/if}
            {/foreach}
            <option value="-1" {if !$pf_obj->id_organisation && $pf_obj->organisation_autre}selected{/if}>
              {l s='Autre organisme' mod='paiementfacilite'}
            </option>
          </select>
        </div>
      </div>

      <div class="form-group" id="pf-org-autre-row"
           {if !$pf_obj->organisation_autre}style="display:none;"{/if}>
        <label class="control-label col-lg-3">
          {l s="Préciser l'organisme" mod='paiementfacilite'}
        </label>
        <div class="col-lg-5">
          <input type="text" name="organisation_autre" class="form-control"
                 value="{$pf_obj->organisation_autre|escape:'html'}">
        </div>
      </div>

      <input type="hidden" name="belongs_to_partner" id="pf-belongs-to-partner"
             value="{if $pf_obj->id_organisation > 0}1{else}0{/if}">

    </div>
  </div>

  {* ══════════════════════════════════════════════
     SECTION 4a — INFOS PERSONNELLES (individuel)
  ══════════════════════════════════════════════ *}
  <div class="panel" id="pf-individual-section"
       {if $pf_obj->is_company}style="display:none;"{/if}>
    <div class="panel-heading">
      <i class="icon-id-card-o"></i>&nbsp;{l s='Informations personnelles' mod='paiementfacilite'}
    </div>
    <div class="panel-body">

      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='Date de naissance' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-3">
          <input type="date" name="date_naissance" id="pf-date-naissance" class="form-control"
                 value="{$pf_obj->date_naissance|escape:'html'}">
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='CIN' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-3">
          <input type="text" name="cin" id="pf-cin" class="form-control"
                 value="{$pf_obj->cin|escape:'html'}">
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='Fonction / Profession' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-5">
          <input type="text" name="fonction" id="pf-fonction" class="form-control"
                 value="{$pf_obj->fonction|escape:'html'}">
        </div>
      </div>

    </div>
  </div>

  {* ══════════════════════════════════════════════
     SECTION 4b — INFOS SOCIÉTÉ
  ══════════════════════════════════════════════ *}
  <div class="panel" id="pf-company-section"
       {if !$pf_obj->is_company}style="display:none;"{/if}>
    <div class="panel-heading">
      <i class="icon-building-o"></i>&nbsp;{l s='Informations de la société' mod='paiementfacilite'}
    </div>
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
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-credit-card"></i>&nbsp;{l s='Détails du crédit' mod='paiementfacilite'}
    </div>
    <div class="panel-body">

      <div class="row pf-credit-row">
        <div class="col-sm-3">
          <div class="form-group">
            <label>{l s='Montant (DT)' mod='paiementfacilite'} <span class="required">*</span></label>
            <input type="number" step="0.01" min="0" name="credit_amount" id="pf-credit-amount"
                   class="form-control" value="{$pf_obj->credit_amount|floatval}">
          </div>
        </div>
        <div class="col-sm-3">
          <div class="form-group">
            <label>{l s='1ère tranche (DT)' mod='paiementfacilite'}</label>
            <input type="number" step="0.01" min="0" name="premiere_tranche"
                   id="pf-premiere-tranche" class="form-control"
                   value="{$pf_obj->premiere_tranche|floatval}">
          </div>
        </div>
        <div class="col-sm-2">
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
        <div class="col-sm-3">
          <div class="form-group">
            <label>
              {l s='Mensualité (DT)' mod='paiementfacilite'}
              <small class="text-muted">({l s='auto si 0' mod='paiementfacilite'})</small>
            </label>
            <input type="number" step="0.01" min="0" name="mensualite" id="pf-mensualite"
                   class="form-control" value="{$pf_obj->mensualite|floatval}">
          </div>
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">{l s='Commentaire' mod='paiementfacilite'}</label>
        <div class="col-lg-8">
          <textarea name="commentaire" class="form-control" rows="3">{$pf_obj->commentaire|escape:'html'}</textarea>
        </div>
      </div>

    </div>
  </div>

  {* ══════════════════════════════════════════════
     SECTION 6 — DOCUMENTS
  ══════════════════════════════════════════════ *}
  <div class="panel" id="pf-docs-panel">
    <div class="panel-heading">
      <i class="icon-folder-open"></i>&nbsp;{l s='Documents' mod='paiementfacilite'}
    </div>
    <div class="panel-body">

      {* ── Existing docs table ── *}
      {if $pf_docs}
      <div id="pf-existing-docs" style="margin-bottom:24px;">
        <h5 class="pf-doc-section-title">
          <i class="icon-folder-o"></i>
          {l s='Fichiers enregistrés' mod='paiementfacilite'}
          &nbsp;<span class="badge" id="pf-doc-count">{$pf_doc_count}</span>
        </h5>
        <div class="table-responsive">
          <table class="table table-bordered table-condensed table-hover" style="margin-bottom:0;">
            <thead>
              <tr>
                <th style="width:220px;">{l s='Type' mod='paiementfacilite'}</th>
                <th>{l s='Fichier' mod='paiementfacilite'}</th>
                <th style="width:110px;">{l s='Ajouté le' mod='paiementfacilite'}</th>
                <th class="text-center" style="width:190px;">{l s='Actions' mod='paiementfacilite'}</th>
              </tr>
            </thead>
            <tbody id="pf-docs-tbody">
              {foreach $pf_docs as $doc}
              <tr id="pf-doc-row-{$doc.id_document|intval}">
                <td>
                  <strong>
                    {if isset($doc_labels[$doc.doc_type])}{$doc_labels[$doc.doc_type]}{else}{$doc.doc_type|escape:'html'}{/if}
                  </strong>
                </td>
                <td>
                  <i class="icon-file{if $doc.file_ext == 'pdf'}-pdf-o" style="color:#c0392b;{else}-image-o" style="color:#2980b9;{/if} margin-right:5px;"></i>
                  <small class="text-muted">{$doc.filename|escape:'html'}</small>
                </td>
                <td><small class="text-muted">{$doc.date_formatted|escape:'html'}</small></td>
                <td class="text-center">
                  <a href="{$pf_form_action|escape:'html'}&download_doc=1&id_document={$doc.id_document|intval}"
                     class="btn btn-xs btn-default" target="_blank">
                    <i class="icon-download"></i> {l s='Télécharger' mod='paiementfacilite'}
                  </a>
                  &nbsp;
                  <button type="button" class="btn btn-xs btn-danger pf-doc-delete"
                          data-id="{$doc.id_document|intval}">
                    <i class="icon-trash-o"></i>
                  </button>
                </td>
              </tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
      {/if}

      <div class="alert alert-info" style="margin-bottom:20px;">
        <i class="icon-info-circle"></i>
        {l s='PNG, JPEG ou PDF — 5 MB max. Envoyer un nouveau fichier remplace automatiquement le fichier existant du même type.' mod='paiementfacilite'}
      </div>

      {* ── Salarié ── *}
      <div id="pf-docs-salarie"
           {if $pf_obj->is_company || $pf_obj->is_retired}style="display:none;"{/if}>
        <h5 class="pf-doc-section-title">{l s='Documents — Salarié' mod='paiementfacilite'}</h5>
        <div class="row">
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='CIN Recto' mod='paiementfacilite'}</label>
              <input type="file" name="cin_recto" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='CIN Verso' mod='paiementfacilite'}</label>
              <input type="file" name="cin_verso" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Facture STEG / SONEDE' mod='paiementfacilite'}</label>
              <input type="file" name="facture_steg" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='RIB' mod='paiementfacilite'}</label>
              <input type="file" name="rib" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
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
        <h5 class="pf-doc-section-title">{l s='Documents — Retraité' mod='paiementfacilite'}</h5>
        <div class="row">
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='CIN Recto' mod='paiementfacilite'}</label>
              <input type="file" name="cin_recto" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='CIN Verso' mod='paiementfacilite'}</label>
              <input type="file" name="cin_verso" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Facture STEG / SONEDE' mod='paiementfacilite'}</label>
              <input type="file" name="facture_steg" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Attestation de retraite' mod='paiementfacilite'}</label>
              <input type="file" name="attestation_retraite" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='RIB' mod='paiementfacilite'}</label>
              <input type="file" name="rib" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
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
        <h5 class="pf-doc-section-title">{l s='Documents — Société' mod='paiementfacilite'}</h5>
        <div class="row">
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Copie RNE' mod='paiementfacilite'}</label>
              <input type="file" name="copie_rne" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='CIN Gérant Recto' mod='paiementfacilite'}</label>
              <input type="file" name="cin_gerant_recto" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='CIN Gérant Verso' mod='paiementfacilite'}</label>
              <input type="file" name="cin_gerant_verso" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='RIB' mod='paiementfacilite'}</label>
              <input type="file" name="rib" class="form-control-file pf-file-input" accept=".jpg,.jpeg,.png,.pdf">
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
     STATUT + FOOTER
  ══════════════════════════════════════════════ *}
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-check-circle"></i>&nbsp;{l s='Statut de la demande' mod='paiementfacilite'}
    </div>
    <div class="panel-body">
      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='Statut' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-3">
          <select name="status" class="form-control">
            {foreach $pf_all_statuses as $pf_st}
            <option value="{$pf_st.code|escape:'html'}"
                    {if $pf_obj->status == $pf_st.code || ($pf_is_add && $pf_st.code == 'pending')}selected{/if}>
              {$pf_st.name|escape:'html'}
            </option>
            {/foreach}
          </select>
        </div>
      </div>
    </div>
    <div class="panel-footer">
      <a href="{$pf_back_url|escape:'html'}" class="btn btn-default">
        <i class="process-icon-cancel"></i> {l s='Annuler' mod='paiementfacilite'}
      </a>
      <button type="submit" class="btn btn-primary pull-right">
        <i class="process-icon-save"></i> {l s='Enregistrer' mod='paiementfacilite'}
      </button>
    </div>
  </div>

</form>

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
          <label>{l s='Alias' mod='paiementfacilite'} <span class="required">*</span></label>
          <input type="text" id="pf-addr-alias" class="form-control" placeholder="Domicile">
        </div>
        <div class="row">
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Prénom' mod='paiementfacilite'} <span class="required">*</span></label>
              <input type="text" id="pf-addr-firstname" class="form-control">
            </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label>{l s='Nom' mod='paiementfacilite'} <span class="required">*</span></label>
              <input type="text" id="pf-addr-lastname" class="form-control">
            </div>
          </div>
        </div>
        <div class="form-group">
          <label>{l s='Adresse' mod='paiementfacilite'} <span class="required">*</span></label>
          <input type="text" id="pf-addr-address1" class="form-control">
        </div>
        <div class="row">
          <div class="col-sm-4">
            <div class="form-group">
              <label>{l s='Code postal' mod='paiementfacilite'} <span class="required">*</span></label>
              <input type="text" id="pf-addr-postcode" class="form-control">
            </div>
          </div>
          <div class="col-sm-8">
            <div class="form-group">
              <label>{l s='Ville' mod='paiementfacilite'} <span class="required">*</span></label>
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
/* ── Autocomplete dropdown ── */
#pf-customer-dropdown {
  position: absolute; top: 100%; left: 0; right: 0; z-index: 9999;
  background: #fff; border: 1px solid #ccc; border-top: none;
  border-radius: 0 0 4px 4px; max-height: 260px; overflow-y: auto;
  box-shadow: 0 4px 10px rgba(0,0,0,.12); display: none;
}
#pf-customer-dropdown .pf-ac-item {
  padding: 8px 12px; cursor: pointer; font-size: 13px;
  border-bottom: 1px solid #f0f0f0;
}
#pf-customer-dropdown .pf-ac-item:last-child { border-bottom: none; }
#pf-customer-dropdown .pf-ac-item:hover,
#pf-customer-dropdown .pf-ac-item.active { background: #eef3ff; }
#pf-customer-dropdown .pf-ac-loading { padding: 10px 12px; color: #999; font-style: italic; }

/* ── Section titles in doc area ── */
.pf-doc-section-title {
  font-size: 13px; font-weight: 700; text-transform: uppercase;
  letter-spacing: .06em; color: #555;
  border-bottom: 2px solid #e5e5e5;
  padding-bottom: 7px; margin: 0 0 16px;
}

/* ── File inputs spacing ── */
.pf-file-input { display: block; margin-top: 4px; }

/* ── Credit row labels left-aligned (override form-horizontal right-align) ── */
.pf-credit-row label { text-align: left !important; font-weight: 600; margin-bottom: 5px; }

/* ── Doc table ── */
#pf-docs-tbody td { vertical-align: middle; }
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
        $('<div class="pf-ac-item">').text(r.label).data('row', r).appendTo($dd);
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
    $('#pf-order-wrap').hide();
    $('#pf-order-select').empty().append($('<option>').val(0).text('— Aucune commande —'));
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
    loadOrders(id_customer);
  }

  /* ── Order loading ── */
  function loadOrders(id_customer) {
    $.getJSON(ajaxUrl + '&ajax=1&action=getCustomerOrders', { id_customer: id_customer },
      function (orders) {
        var $sel = $('#pf-order-select').empty();
        $('<option>').val(0).text('— Aucune commande —').appendTo($sel);
        $.each(orders, function (i, o) {
          $('<option>').val(o.id_order).text(o.label).data('total', o.total).appendTo($sel);
        });
        $('#pf-order-wrap').show();
      }
    );
  }

  /* ── Order selection always updates credit amount ── */
  $('#pf-order-select').on('change', function () {
    var total = parseFloat($(this).find(':selected').data('total')) || 0;
    if (total > 0) {
      $('#pf-credit-amount').val(total.toFixed(2));
      recalcCredit();
    }
  });

  /* ── Type toggle ── */
  $('input[name=is_company]').on('change', function () {
    $('#pf-retired-row').toggle($(this).val() != '1');
    $('#pf-individual-section').toggle($(this).val() != '1');
    updateCompanySection();
    updateDocSections();
    disableHiddenDocs();
  });

  $('input[name=is_retired]').on('change', function () {
    updateDocSections();
    disableHiddenDocs();
  });

  function updateDocSections() {
    var isCompany = $('input[name=is_company]:checked').val() == '1';
    var isRetired = $('input[name=is_retired]:checked').val() == '1';
    $('#pf-docs-salarie').toggle(!isCompany && !isRetired);
    $('#pf-docs-retraite').toggle(!isCompany && isRetired);
    $('#pf-docs-societe').toggle(isCompany);
  }

  function disableHiddenDocs() {
    $('#pf-docs-panel input[type=file]').prop('disabled', false);
    $('#pf-docs-salarie, #pf-docs-retraite, #pf-docs-societe').each(function () {
      if ($(this).is(':hidden')) {
        $(this).find('input[type=file]').prop('disabled', true);
      }
    });
  }

  /* ── Organisation ── */
  function updateCompanySection() {
    var isCompany = $('input[name=is_company]:checked').val() == '1';
    var orgVal    = parseInt($('#pf-org-select').val()) || 0;
    var isPartner = isCompany && orgVal > 0;
    $('#pf-company-section').toggle(isCompany && !isPartner);
  }

  $('#pf-org-select').on('change', function () {
    var val = parseInt($(this).val()) || 0;
    $('#pf-org-autre-row').toggle(val === -1 || val <= 0);
    $('#pf-belongs-to-partner').val(val > 0 ? 1 : 0);
    $('#pf-docs-panel').toggle(val <= 0);
    updateCompanySection();
  });

  /* ── Credit calculations ── */
  function recalcCredit() {
    var credit = parseFloat($('#pf-credit-amount').val()) || 0;
    var nb     = parseInt($('#pf-nb-mois').val()) || 6;

    // Enforce 20% minimum on premiere_tranche
    var minTranche = Math.ceil(credit * 0.20 * 100) / 100;
    var tranche    = parseFloat($('#pf-premiere-tranche').val()) || 0;
    if (credit > 0 && tranche < minTranche) {
      tranche = minTranche;
      $('#pf-premiere-tranche').val(tranche.toFixed(2));
    }

    // Recalculate mensualite
    if (credit > 0 && tranche < credit && nb > 0) {
      $('#pf-mensualite').val(Math.round(((credit - tranche) / nb) * 100) / 100);
    } else {
      $('#pf-mensualite').val('0.00');
    }
  }

  $('#pf-credit-amount, #pf-premiere-tranche, #pf-nb-mois').on('input change', recalcCredit);

  /* ── Delete document ── */
  $(document).on('click', '.pf-doc-delete', function () {
    var $btn = $(this);
    var id   = $btn.data('id');
    if (!confirm('Supprimer ce document ? Cette action est irréversible.')) {
      return;
    }
    $btn.prop('disabled', true);
    $.post(ajaxUrl + '&ajax=1&action=deleteDocument', { id_document: id }, function (resp) {
      if (resp.success) {
        $('#pf-doc-row-' + id).fadeOut(300, function () {
          $(this).remove();
          var remaining = $('#pf-docs-tbody tr').length;
          $('#pf-doc-count').text(remaining);
          if (remaining === 0) {
            $('#pf-existing-docs').slideUp(200);
          }
        });
      } else {
        $btn.prop('disabled', false);
        alert(resp.error || 'Erreur lors de la suppression.');
      }
    }, 'json').fail(function () {
      $btn.prop('disabled', false);
      alert('Erreur de connexion.');
    });
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
      phone:       $('#pf-addr-phone').val()
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

  /* ── Init ── */
  updateDocSections();
  updateCompanySection();
  disableHiddenDocs();
  // Docs panel: hide on load when a partner org is already selected
  var initOrg = parseInt($('#pf-org-select').val()) || 0;
  $('#pf-docs-panel').toggle(initOrg <= 0);

  /* ── Submit validation ── */
  $('#pf-admin-form').on('submit', function (e) {
    var errors = [];
    var orgVal = parseInt($('#pf-org-select').val()) || 0;

    if (!orgVal && orgVal !== -1) {
      errors.push("{l s='L\'organisme est obligatoire.' mod='paiementfacilite' js=1}");
    }
    if (orgVal === -1 && !$('[name=organisation_autre]').val().trim()) {
      errors.push("{l s='Veuillez préciser le nom de l\'organisme.' mod='paiementfacilite' js=1}");
    }

    var isCompany = $('input[name=is_company]:checked').val() == '1';
    if (!isCompany) {
      if (!$('#pf-date-naissance').val()) {
        errors.push("{l s='La date de naissance est obligatoire.' mod='paiementfacilite' js=1}");
      }
      if (!$('#pf-cin').val().trim()) {
        errors.push("{l s='Le numéro de CIN est obligatoire.' mod='paiementfacilite' js=1}");
      }
      if (!$('#pf-fonction').val().trim()) {
        errors.push("{l s='La fonction / profession est obligatoire.' mod='paiementfacilite' js=1}");
      }
    }

    if (errors.length) {
      e.preventDefault();
      var $alert = $('#pf-validation-errors');
      if (!$alert.length) {
        $alert = $('<div id="pf-validation-errors" class="alert alert-danger" style="margin:10px 15px;"></div>');
        $('#pf-admin-form').prepend($alert);
      }
      $alert.html('<ul style="margin:0;padding-left:18px;">' +
        errors.map(function (m) { return '<li>' + m + '</li>'; }).join('') +
        '</ul>');
      $('html,body').animate({ scrollTop: 0 }, 200);
    }
  });

})(jQuery);
</script>
