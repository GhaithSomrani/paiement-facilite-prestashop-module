{extends file='page.tpl'}

{block name='page_title'}
  {l s='Demande envoyée avec succès' mod='paiementfacilite'}
{/block}

{block name='page_content'}
<div class="pf-wrapper container">
  <div class="pf-confirmation text-center py-5">

    <div class="pf-confirm-icon mb-4">
      <svg viewBox="0 0 80 80" width="80" height="80" xmlns="http://www.w3.org/2000/svg">
        <circle cx="40" cy="40" r="38" fill="none" stroke="#28a745" stroke-width="4"/>
        <polyline points="22,42 34,54 58,28" fill="none" stroke="#28a745" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>

    <h2 class="text-success mb-3">{l s='Votre demande a bien été reçue !' mod='paiementfacilite'}</h2>

    <p class="lead mb-4">
      {l s='Votre demande de paiement par facilité n°' mod='paiementfacilite'}
      <strong>#{$pf_request->id|intval}</strong>
      {l s='a été enregistrée avec succès.' mod='paiementfacilite'}
    </p>

    <div class="card pf-confirm-card mx-auto mb-4" style="max-width:480px;">
      <div class="card-body text-left">
        <table class="table table-borderless table-sm mb-0">
          <tr>
            <th class="text-muted">{l s='Montant demandé' mod='paiementfacilite'}</th>
            <td class="text-right font-weight-bold">
              {$pf_request->credit_amount|string_format:"%.2f"} DT
            </td>
          </tr>
          <tr>
            <th class="text-muted">{l s='1ère tranche' mod='paiementfacilite'}</th>
            <td class="text-right">{$pf_request->premiere_tranche|string_format:"%.2f"} DT</td>
          </tr>
          <tr>
            <th class="text-muted">{l s='Mensualité' mod='paiementfacilite'}</th>
            <td class="text-right">{$pf_request->mensualite|string_format:"%.2f"} DT</td>
          </tr>
          <tr>
            <th class="text-muted">{l s='Statut' mod='paiementfacilite'}</th>
            <td class="text-right">
              <span class="badge badge-warning">{l s='En attente' mod='paiementfacilite'}</span>
            </td>
          </tr>
          {if $pf_id_order}
          <tr>
            <th class="text-muted">{l s='Commande liée' mod='paiementfacilite'}</th>
            <td class="text-right">
              <a href="{$pf_order_url|escape:'html'}"># {$pf_id_order|intval}</a>
            </td>
          </tr>
          {/if}
        </table>
      </div>
    </div>

    <p class="text-muted mb-4">
      {l s='Un email de confirmation vous a été envoyé. Notre équipe traitera votre demande dans les plus brefs délais.' mod='paiementfacilite'}
    </p>

    <div class="pf-confirm-actions">
      <a href="{$urls.pages.index}" class="btn btn-outline-secondary mr-2">
        {l s='Retour à la boutique' mod='paiementfacilite'}
      </a>
      {if $pf_id_order}
        <a href="{$pf_order_url|escape:'html'}" class="btn btn-primary">
          {l s='Voir ma commande' mod='paiementfacilite'}
        </a>
      {else}
        <a href="{$urls.pages.my_account}" class="btn btn-primary">
          {l s='Mon compte' mod='paiementfacilite'}
        </a>
      {/if}
    </div>

  </div>
</div>
{/block}
