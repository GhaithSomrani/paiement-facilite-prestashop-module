<div class="pf-wrapper" style="padding:0;">

  <div class="pf-section" style="max-width:100%;">

    {* ── Header ── *}
    <div style="display:flex; align-items:center; gap:16px; margin-bottom:24px;">
      <svg viewBox="0 0 60 60" width="52" height="52" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
        <circle cx="30" cy="30" r="28" fill="none" stroke="var(--pf-black)" stroke-width="2.5"/>
        <polyline points="16,31 25,40 44,21" fill="none" stroke="var(--pf-black)" stroke-width="3"
          stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      <div>
        <h2 class="pf-section-title" style="margin:0 0 4px;">
          {l s='Demande enregistrée !' mod='paiementfacilite'}
        </h2>
        <p style="margin:0; font-size:13px; color:var(--pf-muted);">
          {l s='Commande n°' mod='paiementfacilite'} <strong>{$reference|escape:'html'}</strong>
          &mdash; {l s='Notre équipe vous contactera dans les 48 heures ouvrables.' mod='paiementfacilite'}
        </p>
      </div>
    </div>

    {if $pf_request}

      {* ── Summary table ── *}
      <p class="pf-section-subtitle">{l s='Récapitulatif de votre demande' mod='paiementfacilite'} <span style="color:var(--pf-muted); font-weight:400;">#{$pf_request->id|intval}</span></p>
      <table class="pf-summary-table" style="margin-bottom:0;">
        <tr>
          <td class="pf-td-label">{l s='Montant des achats' mod='paiementfacilite'}</td>
          <td class="pf-td-value">{$pf_request->credit_amount|string_format:"%.2f"} DT</td>
        </tr>
        <tr>
          <td class="pf-td-label">{l s='1ère tranche' mod='paiementfacilite'}</td>
          <td class="pf-td-value">{$pf_request->premiere_tranche|string_format:"%.2f"} DT</td>
        </tr>
        <tr>
          <td class="pf-td-label">{l s='Mensualité' mod='paiementfacilite'}</td>
          <td class="pf-td-value">
            {$pf_request->mensualite|string_format:"%.2f"} DT
            &times; {$pf_request->nb_mois|intval} {l s='mois' mod='paiementfacilite'}
          </td>
        </tr>
        <tr>
          <td class="pf-td-label">{l s='Statut' mod='paiementfacilite'}</td>
          <td class="pf-td-value">
            <span class="pf-status-badge" style="background:var(--pf-yellow,#f5c518); color:var(--pf-black); padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; letter-spacing:.04em; text-transform:uppercase;">
              {l s='En attente' mod='paiementfacilite'}
            </span>
          </td>
        </tr>
      </table>

      {if $pf_pdf_url}

        <hr class="pf-summary-sep">

        {* ── Next steps notice ── *}
        <div class="pf-notice" style="margin-bottom:20px;">
          <p style="margin:0 0 10px; font-weight:700; font-size:12px; letter-spacing:.07em; text-transform:uppercase;">
            {l s='Prochaine étape' mod='paiementfacilite'}
          </p>
          <p style="margin:0 0 8px; font-size:13px; line-height:1.7;">
            {l s='Veuillez imprimer ce document en 3 exemplaires et le faire signer par votre Paierie et votre Amicale, et le renvoyer par mail sur l\'adresse :' mod='paiementfacilite'}
            &nbsp;<a href="mailto:{$pf_admin_email|escape:'html'}" style="color:var(--pf-black); font-weight:700;">{$pf_admin_email|escape:'html'}</a>
            &nbsp;{l s='ou WhatsApp ou Messenger.' mod='paiementfacilite'}
          </p>
        </div>

        {* ── Download button ── *}
        <a href="{$pf_pdf_url|escape:'html'}" class="pf-submit-btn"
           style="display:inline-block; text-decoration:none; width:100%;">
          &#128462; {l s='Télécharger le document (Cession sur salaire)' mod='paiementfacilite'}
        </a>

        {* Auto-download once *}
        <script>
          (function () {
            var key = 'pf_pdf_dl_ret_{$pf_request->id|intval}';
            if (!sessionStorage.getItem(key)) {
              sessionStorage.setItem(key, '1');
              window.addEventListener('load', function () {
                setTimeout(function () {
                  window.location.href = '{$pf_pdf_url nofilter}';
                }, 800);
              });
            }
          })();
        </script>

      {/if}

    {/if}

  </div>

</div>
