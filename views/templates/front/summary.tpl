{extends file='page.tpl'}

{block name='page_title'}
  {l s='Récapitulatif de votre demande' mod='paiementfacilite'}
{/block}

{block name='page_content'}
<div class="pf-wrapper">

{if $pf_confirmed}

  {* ── POST-CONFIRM: success state ── *}
  <div class="pf-section" style="max-width:640px; margin:0 auto; text-align:center;">

    <div style="margin-bottom:24px;">
      <svg viewBox="0 0 60 60" width="64" height="64" xmlns="http://www.w3.org/2000/svg">
        <circle cx="30" cy="30" r="28" fill="none" stroke="var(--pf-black)" stroke-width="2.5"/>
        <polyline points="16,31 25,40 44,21" fill="none" stroke="var(--pf-black)" stroke-width="3"
          stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>

    <h2 class="pf-section-title" style="margin-bottom:10px;">
      {l s='Demande confirmée !' mod='paiementfacilite'}
    </h2>
    <p style="font-size:14px; color:var(--pf-muted); margin-bottom:28px; line-height:1.7;">
      {l s='Votre demande n°' mod='paiementfacilite'}<strong>&nbsp;{$pf_request->id|intval}</strong>
      {l s=' a bien été enregistrée. Un email de confirmation a été envoyé à' mod='paiementfacilite'}
      &nbsp;<strong>{$pf_customer->email|escape:'html'}</strong>.
    </p>

    <div class="pf-notice" style="text-align:left; margin-bottom:28px;">
      <p style="margin:0 0 10px; font-weight:700; font-size:12px; letter-spacing:.07em; text-transform:uppercase;">
        {l s='Prochaine étape' mod='paiementfacilite'}
      </p>
      <p style="margin:0 0 8px; font-size:13px; line-height:1.7;">
        {l s='Veuillez imprimer ce document en 3 exemplaires et le faire signer par votre Paierie et votre Amicale, et le renvoyer par mail sur l\'adresse :' mod='paiementfacilite'}
        &nbsp;<a href="mailto:{$pf_admin_email|escape:'html'}" style="color:var(--pf-black); font-weight:700;">{$pf_admin_email|escape:'html'}</a>
        &nbsp;{l s='ou WhatsApp ou Messenger.' mod='paiementfacilite'}
      </p>
    </div>
    <a href="{$pf_pdf_url|escape:'html'}" class="pf-submit-btn"
       style="display:inline-block; text-decoration:none; margin-bottom:14px; width:100%;">
      &#128462; {l s='Télécharger le document PDF' mod='paiementfacilite'}
    </a>

    {if $pf_order_url}
    <a href="{$pf_order_url|escape:'html'}" class="pf-btn-prev"
       style="display:block; text-align:center; text-decoration:none; width:100%;">
      {l s='Voir ma commande' mod='paiementfacilite'} &rarr;
    </a>
    {/if}

  </div>

  <script>
    (function () {
      var key = 'pf_pdf_dl_{$pf_request->id|intval}';
      if (!sessionStorage.getItem(key)) {
        sessionStorage.setItem(key, '1');
        setTimeout(function () {
          window.location.href = '{$pf_pdf_url nofilter}';
        }, 600);
      }
    })();
  </script>

{else}

  {* ── PRE-CONFIRM: review & confirm state ── *}

  <div class="pf-notice" style="margin-bottom:28px;">
    <p style="margin:0 0 10px; font-weight:700; font-size:12px; letter-spacing:.07em; text-transform:uppercase;">
      {l s='Prochaine étape' mod='paiementfacilite'}
    </p>
    <p style="margin:0 0 8px; font-size:13px; line-height:1.7;">
      {l s='Veuillez imprimer ce document en 3 exemplaires et le faire signer par votre Paierie et votre Amicale, et le renvoyer par mail sur l\'adresse :' mod='paiementfacilite'}
      &nbsp;<a href="mailto:{$pf_admin_email|escape:'html'}" style="color:var(--pf-black); font-weight:700;">{$pf_admin_email|escape:'html'}</a>
      &nbsp;{l s='ou WhatsApp ou Messenger.' mod='paiementfacilite'}
    </p>
    <p style="margin:0; font-size:13px; color:var(--pf-muted); line-height:1.6;">
      {l s='Veuillez noter qu\'une copie de ce document vous sera envoyée sur votre adresse :' mod='paiementfacilite'}
      &nbsp;<strong style="color:var(--pf-black);">{$pf_customer->email|escape:'html'}</strong>
    </p>
  </div>

  <div class="pf-summary-grid">

    {* LEFT: summary + actions *}
    <div>
      <div class="pf-section" style="margin-bottom:0;">

        <h2 class="pf-section-title">
          {l s='Demande' mod='paiementfacilite'} &nbsp;#{$pf_request->id|intval}
        </h2>

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
        </table>

        <hr class="pf-summary-sep">

        <a href="{$pf_pdf_url|escape:'html'}" class="pf-btn-prev"
           style="display:block; text-align:center; text-decoration:none; margin-bottom:14px; width:100%;">
          &#128462; {l s='Télécharger le document PDF' mod='paiementfacilite'}
        </a>

        <form method="post" action="{$pf_confirm_url|escape:'html'}">
          <input type="hidden" name="confirm_request" value="1">
          <input type="hidden" name="id_request" value="{$pf_request->id|intval}">
          <button type="submit" class="pf-submit-btn">
            {l s='Confirmer ma demande' mod='paiementfacilite'} &rarr;
          </button>
        </form>

        <p class="pf-reassurance">
          {l s='En confirmant, votre demande sera transmise et un email vous sera envoyé.' mod='paiementfacilite'}
        </p>

      </div>
    </div>

    {* RIGHT: PDF preview *}
    <div>
      <div class="pf-section" style="padding:0; margin-bottom:0; overflow:hidden;">
        <div class="pf-preview-header">
          <span class="pf-section-title" style="margin:0; font-size:12px;">
            {l s='Aperçu — Cession sur salaire' mod='paiementfacilite'}
          </span>
          <a href="{$pf_pdf_url|escape:'html'}" class="pf-btn-prev"
             style="font-size:11px; padding:9px 18px; text-decoration:none;">
            {l s='Télécharger' mod='paiementfacilite'}
          </a>
        </div>
        <iframe
          src="{$pf_pdf_preview_url|escape:'html'}"
          style="width:100%; height:780px; border:none; display:block;"
          title="{l s='Aperçu du document' mod='paiementfacilite'}"
        ></iframe>
      </div>
    </div>

  </div>{* /pf-summary-grid *}

{/if}

</div>{* /pf-wrapper *}
{/block}
