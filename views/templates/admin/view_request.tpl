{* Admin — Request Detail View *}
<div class="panel">

  {* ── Header ── *}
  <div class="panel-heading">
    <a href="{$pf_back_url|escape:'html'}" class="btn btn-default btn-sm">
      <i class="process-icon-back"></i> {l s='Retour à la liste' mod='paiementfacilite'}
    </a>
    &nbsp;
    <span class="pf-status-badge" style="background:{$pf_status_color|escape:'html'};">
      {$pf_status_name|escape:'html'}
    </span>

    {if $pf_request->status == 'approved_mode' || $pf_request->status == 'approved_emp'}
      &nbsp;&nbsp;
      <a href="{$pf_pdf_url|escape:'html'}" class="btn btn-default btn-sm" target="_blank">
        <i class="icon-print"></i> {l s='Imprimer Cession sur salaire' mod='paiementfacilite'}
      </a>
    {/if}

    {if $pf_request->status == 'pending'}
      &nbsp;&nbsp;
      <a href="{$pf_approve_mode_url|escape:'html'}" class="btn btn-info btn-sm"
        onclick="return confirm('{l s='Valider cette demande par La Mode ?' mod='paiementfacilite'}')">
        <i class="icon-check"></i> {l s='Valider (La Mode)' mod='paiementfacilite'}
      </a>
      &nbsp;
      <a href="{$pf_reject_mode_url|escape:'html'}" class="btn btn-danger btn-sm"
        onclick="return confirm('{l s='Rejeter cette demande par La Mode ?' mod='paiementfacilite'}')">
        <i class="icon-times"></i> {l s='Rejeter (La Mode)' mod='paiementfacilite'}
      </a>
    {elseif $pf_request->status == 'approved_mode'}
      &nbsp;&nbsp;
      <a href="{$pf_approve_emp_url|escape:'html'}" class="btn btn-success btn-sm"
        onclick="return confirm('Valider cette demande par employeur ?')">
        <i class="icon-check"></i> {l s="Valider (Employeur)" mod='paiementfacilite'}
      </a>
      &nbsp;
      <a href="{$pf_reject_emp_url|escape:'html'}" class="btn btn-danger btn-sm"
        onclick="return confirm('Rejeter cette demande par employeur ')">
        <i class="icon-times"></i> {l s="Rejeter (Employeur)" mod='paiementfacilite'}
      </a>
    {/if}
  </div>

  <div class="panel-body">

    {* ── Top row: Client / Address / Organisation ── *}
    <div class="row">

      <div class="col-md-4">
        <div class="panel panel-default">
          <div class="panel-heading">{l s='Informations client' mod='paiementfacilite'}</div>
          <div class="panel-body">
            <p class="pf-client-name">{$pf_customer->firstname|escape:'html'} {$pf_customer->lastname|escape:'html'}</p>
            <p class="pf-client-email">{$pf_customer->email|escape:'html'}</p>
            <p>
              {if $pf_request->is_company}
                <span class="pf-type-badge pf-type-company">{l s='Société' mod='paiementfacilite'}</span>
              {else}
                <span class="pf-type-badge pf-type-employee">{l s='Salarié' mod='paiementfacilite'}</span>
                {if $pf_request->is_retired}
                  <span class="pf-type-badge pf-type-employee">{l s='Retraité' mod='paiementfacilite'}</span>
                {/if}
              {/if}
            </p>
            <hr>
            <table class="pf-info-table">
              <tr>
                <th>{l s='Date de naissance' mod='paiementfacilite'}</th>
                <td>{$pf_request->date_naissance|escape:'html'}</td>
              </tr>
              <tr>
                <th>{l s='CIN' mod='paiementfacilite'}</th>
                <td>{$pf_request->cin|escape:'html'}</td>
              </tr>
              <tr>
                <th>{l s='Fonction' mod='paiementfacilite'}</th>
                <td>{$pf_request->fonction|escape:'html'}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="panel panel-default">
          <div class="panel-heading">{l s='Adresse' mod='paiementfacilite'}</div>
          <div class="panel-body">
            <address class="pf-address">
              <strong>{$pf_address->firstname|escape:'html'} {$pf_address->lastname|escape:'html'}</strong><br>
              {$pf_address->address1|escape:'html'}<br>
              {if $pf_address->address2}{$pf_address->address2|escape:'html'}<br>{/if}
              {$pf_address->postcode|escape:'html'} {$pf_address->city|escape:'html'}
              {if $pf_address->phone}
                <br><i class="icon-phone"></i> {$pf_address->phone|escape:'html'}
              {/if}
            </address>
          </div>
        </div>
      </div>

      <div class="col-md-4">
        <div class="panel panel-default">
          <div class="panel-heading">{l s='Organisme' mod='paiementfacilite'}</div>
          <div class="panel-body">
            {if $pf_request->belongs_to_partner && $pf_org}
              <span class="pf-type-badge pf-type-partner">{l s='Partenaire' mod='paiementfacilite'}</span>
              <p class="pf-org-name">{$pf_org->name|escape:'html'}</p>
            {elseif $pf_request->organisation_autre}
              <p><span class="pf-label">{l s='Autre' mod='paiementfacilite'} :</span>
                {$pf_request->organisation_autre|escape:'html'}</p>
            {else}
              <em class="pf-none">{l s='Aucun organisme renseigné' mod='paiementfacilite'}</em>
            {/if}
          </div>
        </div>
      </div>

    </div>{* /row *}

    {* ── Company details (conditional) ── *}
    {if $pf_request->is_company}
      <div class="panel panel-default">
        <div class="panel-heading">{l s='Informations Société' mod='paiementfacilite'}</div>
        <div class="panel-body">
          <div class="row">
            <div class="col-sm-4">
              <p class="pf-field-label">{l s='Raison sociale' mod='paiementfacilite'}</p>
              <p class="pf-field-value">{$pf_request->raison_sociale|escape:'html'}</p>
            </div>
            <div class="col-sm-4">
              <p class="pf-field-label">{l s='Représentant légal' mod='paiementfacilite'}</p>
              <p class="pf-field-value">{$pf_request->representant_legal|escape:'html'}</p>
            </div>
            <div class="col-sm-4">
              <p class="pf-field-label">{l s='Date de naissance du gérant' mod='paiementfacilite'}</p>
              <p class="pf-field-value">{$pf_request->date_naissance_gerant|escape:'html'}</p>
            </div>
          </div>
          <div class="row" style="margin-top:12px;">
            <div class="col-sm-4">
              <p class="pf-field-label">{l s='Téléphone' mod='paiementfacilite'}</p>
              <p class="pf-field-value">{$pf_request->telephone_gerant|escape:'html'}</p>
            </div>
            <div class="col-sm-4">
              <p class="pf-field-label">{l s='Email' mod='paiementfacilite'}</p>
              <p class="pf-field-value">{$pf_request->email_gerant|escape:'html'}</p>
            </div>
            <div class="col-sm-4">
              <p class="pf-field-label">{l s='N° CIN du gérant' mod='paiementfacilite'}</p>
              <p class="pf-field-value">{$pf_request->cin_gerant|escape:'html'}</p>
            </div>
          </div>
        </div>
      </div>
    {/if}

    {* ── Credit KPIs ── *}
    <div class="panel panel-default">
      <div class="panel-heading">{l s='Détails du crédit' mod='paiementfacilite'}</div>
      <div class="panel-body">
        <div class="row">
          <div class="col-sm-2">
            <div class="pf-kpi">
              <div class="pf-kpi-label">{l s='Montant demandé' mod='paiementfacilite'}</div>
              <div class="pf-kpi-value">{$pf_request->credit_amount|string_format:"%.2f"} <span
                  class="pf-kpi-unit">DT</span></div>
            </div>
          </div>
          <div class="col-sm-2">
            <div class="pf-kpi">
              <div class="pf-kpi-label">
                {l s='Total après intérêts' mod='paiementfacilite'}
                {if $pf_request->interest_rate > 0}
                  <small style="color:#795548;">({$pf_request->interest_rate|string_format:"%.2f"} %)</small>
                {/if}
              </div>
              <div class="pf-kpi-value">{$pf_total_with_interest|string_format:"%.2f"} <span
                  class="pf-kpi-unit">DT</span></div>
            </div>
          </div>
          <div class="col-sm-2">
            <div class="pf-kpi">
              <div class="pf-kpi-label">{l s='1ère tranche' mod='paiementfacilite'}</div>
              <div class="pf-kpi-value">{$pf_request->premiere_tranche|string_format:"%.2f"} <span
                  class="pf-kpi-unit">DT</span></div>
            </div>
          </div>
          <div class="col-sm-2">
            <div class="pf-kpi">
              <div class="pf-kpi-label">{l s='Mensualité' mod='paiementfacilite'} (×{$pf_request->nb_mois|intval}
                {l s='mois' mod='paiementfacilite'})</div>
              <div class="pf-kpi-value">{$pf_request->mensualite|string_format:"%.2f"} <span
                  class="pf-kpi-unit">DT</span></div>
            </div>
          </div>
          <div class="col-sm-2">
            <div class="pf-kpi">
              <div class="pf-kpi-label">{l s='Commande liée' mod='paiementfacilite'}</div>
              <div class="pf-kpi-value">
                {if $pf_linked_order_id}
                  <a href="{$pf_order_url|escape:'html'}" target="_blank" class="pf-order-link">
                    #{$pf_linked_order_id|intval} <i class="icon-external-link"></i>
                  </a>
                {else}
                  <span class="pf-none">—</span>
                {/if}
              </div>
            </div>
          </div>
        </div>
        <div class="row" style="margin-top:10px;">

        </div>

        {if $pf_request->commentaire}
          <hr>
          <p class="pf-field-label">{l s='Commentaire' mod='paiementfacilite'}</p>
          <p class="pf-comment">{$pf_request->commentaire|escape:'html'|nl2br}</p>
        {/if}
      </div>
    </div>

    {* ── Documents ── *}
    {if $pf_docs}
      <div class="panel panel-default">
        <div class="panel-heading">{l s='Documents soumis' mod='paiementfacilite'}</div>
        <div class="panel-body pf-table-wrap">
          <table class="table table-bordered table-striped">
            <thead>
              <tr>
                <th>{l s='Type' mod='paiementfacilite'}</th>
                <th>{l s='Fichier' mod='paiementfacilite'}</th>
                <th>{l s='Date' mod='paiementfacilite'}</th>
                <th class="text-center pf-col-action">{l s='Action' mod='paiementfacilite'}</th>
              </tr>
            </thead>
            <tbody>
              {foreach $pf_docs as $doc}
                <tr>
                  <td>
                    {if isset($doc_labels[$doc.doc_type])}{$doc_labels[$doc.doc_type]}{else}{$doc.doc_type|escape:'html'}{/if}
                  </td>
                  <td><i class="icon-file-o"></i> {$doc.filename|escape:'html'}</td>
                  <td>{$doc.date_add|escape:'html'}</td>
                  <td class="text-center">
                    <a href="{$pf_back_url|escape:'html'}&download_doc=1&id_document={$doc.id_document|intval}"
                      class="btn btn-xs btn-default">
                      <i class="icon-download"></i> {l s='Télécharger' mod='paiementfacilite'}
                    </a>
                  </td>
                </tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    {else}
      <div class="alert alert-info">
        <i class="icon-info-circle"></i>
        {l s='Aucun document soumis (membre d\'organisme partenaire ou non renseigné).' mod='paiementfacilite'}
      </div>
    {/if}

  </div>{* /panel-body *}

  <div class="panel-footer">
    <a href="{$pf_back_url|escape:'html'}" class="btn btn-default">
      <i class="process-icon-back"></i> {l s='Retour à la liste' mod='paiementfacilite'}
    </a>
    {if $pf_request->status == 'approved_mode' || $pf_request->status == 'approved_emp'}
      &nbsp;&nbsp;
      <a href="{$pf_pdf_url|escape:'html'}" class="btn btn-default" target="_blank">
        <i class="icon-print"></i> {l s='Imprimer Cession sur salaire' mod='paiementfacilite'}
      </a>
    {/if}
    {if $pf_request->status == 'pending'}
      <div class="pull-right">
        <a href="{$pf_reject_mode_url|escape:'html'}" class="btn btn-danger"
          onclick="return confirm('{l s='Rejeter cette demande par La Mode ?' mod='paiementfacilite'}')">
          <i class="icon-times"></i> {l s='Rejeter (La Mode)' mod='paiementfacilite'}
        </a>
        &nbsp;
        <a href="{$pf_approve_mode_url|escape:'html'}" class="btn btn-info"
          onclick="return confirm('{l s='Valider cette demande par La Mode ?' mod='paiementfacilite'}')">
          <i class="icon-check"></i> {l s='Valider (La Mode)' mod='paiementfacilite'}
        </a>
      </div>
    {elseif $pf_request->status == 'approved_mode'}
      <div class="pull-right">
        <a href="{$pf_reject_emp_url|escape:'html'}" class="btn btn-danger"
          onclick="return confirm('Rejeter cette demande par employeur ')">
          <i class="icon-times"></i> {l s="Rejeter (Employeur)" mod='paiementfacilite'}
        </a>
        &nbsp;
        <a href="{$pf_approve_emp_url|escape:'html'}" class="btn btn-success"
          onclick="return confirm('Valider cette demande par employeur')">
          <i class="icon-check"></i> {l s="Valider (Employeur)" mod='paiementfacilite'}
        </a>
      </div>
    {/if}
  </div>

</div>{* /panel *}

<style>
  /* ── Status badge ── */
  .pf-status-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 3px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: .04em;
    text-transform: uppercase;
    vertical-align: middle;
    color: #fff;
  }

  /* ── Type badges ── */
  .pf-type-badge {
    display: inline-block;
    padding: 2px 9px;
    border-radius: 3px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: .03em;
    color: #fff;
    margin-right: 3px;
  }

  .pf-type-company {
    background: #2980b9;
  }

  .pf-type-employee {
    background: #7f8c8d;
  }

  .pf-type-partner {
    background: #27ae60;
  }

  /* ── Client card ── */
  .pf-client-name {
    font-size: 15px;
    font-weight: 700;
    margin-bottom: 2px;
  }

  .pf-client-email {
    color: #7f8c8d;
    margin-bottom: 8px;
  }

  .pf-org-name {
    font-size: 14px;
    font-weight: 600;
    margin-top: 8px;
  }

  /* ── Info table (replaces dl-horizontal) ── */
  .pf-info-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }

  .pf-info-table th {
    width: 40%;
    color: #7f8c8d;
    font-weight: 600;
    padding: 3px 8px 3px 0;
    vertical-align: top;
    white-space: nowrap;
  }

  .pf-info-table td {
    padding: 3px 0;
  }

  /* ── Address ── */
  .pf-address {
    font-size: 13px;
    line-height: 1.7;
    margin: 0;
  }

  /* ── Field label / value (company section) ── */
  .pf-field-label {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .05em;
    color: #95a5a6;
    margin-bottom: 3px;
  }

  .pf-field-value {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 0;
  }

  /* ── KPI boxes ── */
  .pf-kpi {
    background: #f8f9fa;
    border: 1px solid #e0e0e0;
    border-top: 3px solid #1565C0;
    border-radius: 3px;
    padding: 14px 16px 12px;
    margin-bottom: 16px;
    text-align: center;
  }

  .pf-kpi-label {
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .07em;
    color: #95a5a6;
    margin-bottom: 6px;
  }

  .pf-kpi-value {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1565C0;
    line-height: 1.2;
  }

  .pf-kpi-unit {
    font-size: .9rem;
    font-weight: 500;
  }

  /* ── Order link inside KPI ── */
  .pf-order-link {
    font-size: 1.4rem;
    font-weight: 700;
  }

  .pf-order-link i {
    font-size: .9rem;
  }

  /* ── Comment ── */
  .pf-comment {
    font-size: 13px;
    line-height: 1.6;
    background: #f8f9fa;
    border-left: 3px solid #bdc3c7;
    padding: 8px 12px;
    border-radius: 0 3px 3px 0;
    margin: 0;
  }

  /* ── Misc ── */
  .pf-label {
    font-weight: 600;
    color: #7f8c8d;
  }

  .pf-none {
    color: #bdc3c7;
  }

  .pf-table-wrap {
    padding: 0;
  }

  .pf-table-wrap table {
    margin: 0;
  }

  .pf-col-action {
    width: 130px;
  }
</style>