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

    {* Instructions block *}
    <div class="alert alert-info text-left mb-4" style="max-width:580px; margin:0 auto 1.5rem; font-size:0.97rem; line-height:1.6;">
      <strong><i class="material-icons" style="vertical-align:middle; font-size:1.2rem;">info</i>
        {l s='Prochaine étape' mod='paiementfacilite'}</strong><br/><br/>
      {l s='Veuillez imprimer ce document en 3 exemplaires et le faire signer par votre Paierie et votre Amicale, puis le renvoyer par :' mod='paiementfacilite'}
      <ul class="mb-0 mt-2" style="padding-left:1.2rem;">
        <li>
          {l s='Mail sur l\'adresse :' mod='paiementfacilite'}
          <strong><a href="mailto:{$pf_admin_email|escape:'html'}">{$pf_admin_email|escape:'html'}</a></strong>
        </li>
        <li>{l s='WhatsApp' mod='paiementfacilite'}</li>
        <li>{l s='Messenger' mod='paiementfacilite'}</li>
      </ul>
    </div>

    {* Download button *}
    <div class="mb-4">
      <a href="{$pf_pdf_url|escape:'html'}" class="btn btn-success" id="pf-pdf-download-btn">
        <i class="material-icons" style="vertical-align:middle; font-size:1.1rem; margin-right:4px;">picture_as_pdf</i>
        {l s='Télécharger le document (Cession sur salaire)' mod='paiementfacilite'}
      </a>
    </div>

    <p class="text-muted mb-4">
      {l s='Notre équipe traitera votre demande dans les plus brefs délais.' mod='paiementfacilite'}
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

{* Auto-download the PDF when the confirmation page loads *}
<script>
  window.addEventListener('load', function () {
    setTimeout(function () {
      window.location.href = '{$pf_pdf_url nofilter}';
    }, 800);
  });
</script>
{/block}
