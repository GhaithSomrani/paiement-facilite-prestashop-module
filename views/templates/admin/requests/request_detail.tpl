{* Admin — Request Detail View *}
<div class="panel">
  <div class="panel-heading">
    <a href="{$pf_back_url|escape:'html'}" class="btn btn-default btn-sm">
      <i class="process-icon-back"></i> {l s='Retour à la liste' mod='paiementfacilite'}
    </a>
    &nbsp;
    <span class="badge {if $pf_request->status == 'approved'}badge-success{elseif $pf_request->status == 'rejected'}badge-danger{else}badge-warning{/if}">
      {if $pf_request->status == 'approved'}{l s='Approuvé' mod='paiementfacilite'}
      {elseif $pf_request->status == 'rejected'}{l s='Rejeté' mod='paiementfacilite'}
      {else}{l s='En attente' mod='paiementfacilite'}{/if}
    </span>
    &nbsp;&nbsp;
    {if $pf_request->status == 'pending'}
      <a href="{$pf_approve_url|escape:'html'}" class="btn btn-success btn-sm"
         onclick="return confirm('{l s='Approuver cette demande ?' mod='paiementfacilite'}')">
        <i class="icon-check"></i> {l s='Approuver' mod='paiementfacilite'}
      </a>
      &nbsp;
      <a href="{$pf_reject_url|escape:'html'}" class="btn btn-danger btn-sm"
         onclick="return confirm('{l s='Rejeter cette demande ?' mod='paiementfacilite'}')">
        <i class="icon-times"></i> {l s='Rejeter' mod='paiementfacilite'}
      </a>
    {/if}
  </div>

  <div class="panel-body">
    <div class="row">

      {* ── Client info ── *}
      <div class="col-md-4">
        <div class="panel">
          <div class="panel-heading">{l s='Informations client' mod='paiementfacilite'}</div>
          <div class="panel-body">
            <p><strong>{$pf_customer->firstname|escape:'html'} {$pf_customer->lastname|escape:'html'}</strong></p>
            <p>{$pf_customer->email|escape:'html'}</p>
            <p>
              {if $pf_request->is_company}
                <span class="badge badge-info">{l s='Société' mod='paiementfacilite'}</span>
              {else}
                <span class="badge badge-secondary">{l s='Salarié' mod='paiementfacilite'}</span>
                {if $pf_request->is_retired}
                  <span class="badge badge-secondary">{l s='Retraité' mod='paiementfacilite'}</span>
                {/if}
              {/if}
            </p>
            <hr>
            <p><small class="text-muted">{l s='Date de naissance' mod='paiementfacilite'}</small><br>
              {$pf_request->date_naissance|escape:'html'}</p>
            <p><small class="text-muted">{l s='CIN' mod='paiementfacilite'}</small><br>
              {$pf_request->cin|escape:'html'}</p>
            <p><small class="text-muted">{l s='Fonction' mod='paiementfacilite'}</small><br>
              {$pf_request->fonction|escape:'html'}</p>
          </div>
        </div>
      </div>

      {* ── Address ── *}
      <div class="col-md-4">
        <div class="panel">
          <div class="panel-heading">{l s='Adresse' mod='paiementfacilite'}</div>
          <div class="panel-body">
            <p>
              {$pf_address->firstname|escape:'html'} {$pf_address->lastname|escape:'html'}<br>
              {$pf_address->address1|escape:'html'}<br>
              {if $pf_address->address2}{$pf_address->address2|escape:'html'}<br>{/if}
              {$pf_address->postcode|escape:'html'} {$pf_address->city|escape:'html'}
            </p>
            {if $pf_address->phone}<p><i class="icon-phone"></i> {$pf_address->phone|escape:'html'}</p>{/if}
          </div>
        </div>
      </div>

      {* ── Organisation ── *}
      <div class="col-md-4">
        <div class="panel">
          <div class="panel-heading">{l s='Organisme' mod='paiementfacilite'}</div>
          <div class="panel-body">
            {if $pf_request->belongs_to_partner && $pf_org}
              <span class="badge badge-success">{l s='Partenaire' mod='paiementfacilite'}</span>
              <p class="mt-2">{$pf_org->name|escape:'html'}</p>
            {elseif $pf_request->organisation_autre}
              <p>{l s='Autre' mod='paiementfacilite'} : {$pf_request->organisation_autre|escape:'html'}</p>
            {else}
              <em>{l s='Aucun organisme' mod='paiementfacilite'}</em>
            {/if}
          </div>
        </div>
      </div>

    </div>{* /row *}

    {* ── Société fields ── *}
    {if $pf_request->is_company}
    <div class="row">
      <div class="col-md-12">
        <div class="panel">
          <div class="panel-heading">{l s='Informations Société' mod='paiementfacilite'}</div>
          <div class="panel-body">
            <div class="row">
              <div class="col-md-3">
                <small class="text-muted">{l s='Raison sociale' mod='paiementfacilite'}</small>
                <p>{$pf_request->raison_sociale|escape:'html'}</p>
              </div>
              <div class="col-md-3">
                <small class="text-muted">{l s='Matricule fiscal' mod='paiementfacilite'}</small>
                <p>{$pf_request->matricule_fiscal|escape:'html'}</p>
              </div>
              <div class="col-md-3">
                <small class="text-muted">{l s='Représentant légal' mod='paiementfacilite'}</small>
                <p>{$pf_request->representant_legal|escape:'html'}</p>
              </div>
              <div class="col-md-3">
                <small class="text-muted">{l s='CIN gérant' mod='paiementfacilite'}</small>
                <p>{$pf_request->cin_gerant|escape:'html'}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    {/if}

    {* ── Credit details ── *}
    <div class="row">
      <div class="col-md-12">
        <div class="panel">
          <div class="panel-heading">{l s='Détails du crédit' mod='paiementfacilite'}</div>
          <div class="panel-body">
            <div class="row text-center">
              <div class="col-md-3">
                <div class="kpi-container">
                  <p class="kpi-label">{l s='Montant' mod='paiementfacilite'}</p>
                  <p class="kpi-value">{$pf_request->credit_amount|string_format:"%.2f"} DT</p>
                </div>
              </div>
              <div class="col-md-3">
                <div class="kpi-container">
                  <p class="kpi-label">{l s='1ère tranche' mod='paiementfacilite'}</p>
                  <p class="kpi-value">{$pf_request->premiere_tranche|string_format:"%.2f"} DT</p>
                </div>
              </div>
              <div class="col-md-3">
                <div class="kpi-container">
                  <p class="kpi-label">{l s='Mensualité' mod='paiementfacilite'}</p>
                  <p class="kpi-value">{$pf_request->mensualite|string_format:"%.2f"} DT</p>
                </div>
              </div>
              <div class="col-md-3">
                <div class="kpi-container">
                  <p class="kpi-label">{l s='Commande liée' mod='paiementfacilite'}</p>
                  <p class="kpi-value">
                    {if $pf_linked_order_id}
                      <a href="{$pf_order_url|escape:'html'}" target="_blank">#{$pf_linked_order_id|intval}</a>
                    {else}—{/if}
                  </p>
                </div>
              </div>
            </div>
            {if $pf_request->commentaire}
            <hr>
            <p><small class="text-muted">{l s='Commentaire :' mod='paiementfacilite'}</small><br>
              {$pf_request->commentaire|escape:'html'}</p>
            {/if}
          </div>
        </div>
      </div>
    </div>

    {* ── Documents ── *}
    {if $pf_docs}
    <div class="panel">
      <div class="panel-heading">{l s='Documents soumis' mod='paiementfacilite'}</div>
      <div class="panel-body">
        <table class="table table-bordered table-striped">
          <thead>
            <tr>
              <th>{l s='Type' mod='paiementfacilite'}</th>
              <th>{l s='Fichier' mod='paiementfacilite'}</th>
              <th>{l s='Date' mod='paiementfacilite'}</th>
              <th>{l s='Action' mod='paiementfacilite'}</th>
            </tr>
          </thead>
          <tbody>
            {foreach $pf_docs as $doc}
            <tr>
              {* <td>{if isset($doc_labels[$doc.doc_type])}{$doc_labels[$doc.doc_type]}{else}{$doc.doc_type|escape:'html'}{/if}</td> *}
              <td>{$doc.filename|escape:'html'}</td>
              <td>{$doc.date_add|escape:'html'}</td>
              <td>
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
        {l s='Aucun document soumis (membre d\'organisme partenaire ou non renseigné).' mod='paiementfacilite'}
      </div>
    {/if}

  </div>{* /panel-body *}
</div>{* /panel *}

<style>
.kpi-container { background:#f8f9fa; border:1px solid #dee2e6; border-radius:.4rem; padding:1rem; }
.kpi-label { font-size:.75rem; color:#6c757d; text-transform:uppercase; margin-bottom:.3rem; }
.kpi-value { font-size:1.4rem; font-weight:700; color:#1565C0; margin:0; }
</style>
