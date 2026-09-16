{extends file='page.tpl'}

{block name='page_title'}
  {l s='Détails de la demande' mod='paiementfacilite'}
{/block}

{block name='page_content'}
<div class="pf-wrapper" style="max-width:560px;">

  <div class="pf-section">
    <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; margin-bottom:24px;">
      <h2 class="pf-section-title" style="margin:0;">
        {l s='Demande' mod='paiementfacilite'} &nbsp;#{$pf_request->id|intval}
      </h2>
      <span class="pf-request-row-status" style="background:{$pf_status_color|escape:'html'};">
        {$pf_status_name|escape:'html'}
      </span>
    </div>

    <p class="pf-section-subtitle">{l s='Identité' mod='paiementfacilite'}</p>
    <table class="pf-summary-table" style="margin-bottom:0;">
      <tr>
        <td class="pf-td-label">{l s='Nom' mod='paiementfacilite'}</td>
        <td class="pf-td-value">
          {$pf_customer->firstname|escape:'html'} {$pf_customer->lastname|escape:'html'}
        </td>
      </tr>
      {if $pf_request->is_company && $pf_request->raison_sociale}
      <tr>
        <td class="pf-td-label">{l s='Société' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->raison_sociale|escape:'html'}</td>
      </tr>
      {/if}
      {if $pf_org_name}
      <tr>
        <td class="pf-td-label">{l s='Organisme' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_org_name|escape:'html'}</td>
      </tr>
      {/if}
      {if !$pf_request->is_company && $pf_request->fonction}
      <tr>
        <td class="pf-td-label">{l s='Fonction' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->fonction|escape:'html'}</td>
      </tr>
      {/if}
      <tr>
        <td class="pf-td-label">{l s='Adresse' mod='paiementfacilite'}</td>
        <td class="pf-td-value">
          {$pf_address->address1|escape:'html'}
          {if $pf_address->city}, {$pf_address->city|escape:'html'}{/if}
        </td>
      </tr>
    </table>

    <hr class="pf-summary-sep">

    <p class="pf-section-subtitle">{l s='Financement' mod='paiementfacilite'}</p>
    <table class="pf-summary-table" style="margin-bottom:0;">
      <tr>
        <td class="pf-td-label">{l s='Montant des achats' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->credit_amount|string_format:"%.2f"} DT</td>
      </tr>
      {if $pf_is_bank_36}
      <tr>
        <td class="pf-td-label">{l s='Financement' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{l s="Jusqu'à 36 mois" mod='paiementfacilite'}</td>
      </tr>
      <tr>
        <td colspan="2" style="padding-top:6px;font-size:12px;color:var(--pf-muted);line-height:1.6;">
          {l s='Les échéances et le taux dépendront du dossier et seront communiqués une fois validé par la banque.' mod='paiementfacilite'}
        </td>
      </tr>
      {else}
      <tr>
        <td class="pf-td-label">{l s='Taux d\'intérêts' mod='paiementfacilite'}</td>
        <td class="pf-td-value">
          {if $pf_request->interest_rate > 0}
            {$pf_request->interest_rate|string_format:"%.2f"} %
          {else}
            {l s='Sans intérêts' mod='paiementfacilite'}
          {/if}
        </td>
      </tr>
      <tr>
        <td class="pf-td-label">{l s='1ère tranche' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->premiere_tranche|string_format:"%.2f"} DT</td>
      </tr>
      <tr>
        <td class="pf-td-label">{l s='Reste à payer' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_credit_reste|string_format:"%.2f"} DT</td>
      </tr>
      <tr>
        <td class="pf-td-label">{l s='Mensualité' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->mensualite|string_format:"%.2f"} DT</td>
      </tr>
      <tr>
        <td class="pf-td-label">{l s='Nombre de mois' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->nb_mois|intval} {l s='mois' mod='paiementfacilite'}</td>
      </tr>
      {/if}
      {if $pf_request->commentaire}
      <tr>
        <td class="pf-td-label">{l s='Commentaire' mod='paiementfacilite'}</td>
        <td class="pf-td-value">{$pf_request->commentaire|escape:'html'}</td>
      </tr>
      {/if}
    </table>

    <hr class="pf-summary-sep">

    <div style="display:flex; flex-wrap:wrap; gap:10px;">
      <a href="{$pf_back_url|escape:'html'}" class="pf-btn-prev" style="flex:1; min-width:160px; text-align:center; text-decoration:none; display:block;">
        &larr; {l s='Mes demandes' mod='paiementfacilite'}
      </a>
      {if !$pf_is_bank_36}
      <a href="{$pf_pdf_url|escape:'html'}" class="pf-btn-prev" style="flex:1; min-width:160px; text-align:center; text-decoration:none; display:block;">
        &#128462; {l s='Télécharger le PDF' mod='paiementfacilite'}
      </a>
      {/if}
    </div>

  </div>

</div>
{/block}
