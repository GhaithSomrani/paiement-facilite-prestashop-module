<div class="box pf-payment-return">

  <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;">
    <svg viewBox="0 0 50 50" width="42" height="42" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
      <circle cx="25" cy="25" r="23" fill="none" stroke="#28a745" stroke-width="3" />
      <polyline points="13,26 21,34 37,18" fill="none" stroke="#28a745" stroke-width="3.5" stroke-linecap="round"
        stroke-linejoin="round" />
    </svg>
    <h3 class="page-heading" style="margin:0;">
      {l s='Votre demande de paiement par facilité est en cours de traitement' mod='paiementfacilite'}
    </h3>
  </div>

  <p>
    {l s='Merci ! Votre commande n°' mod='paiementfacilite'}
    <strong>{$reference}</strong>
    {l s='a été enregistrée.' mod='paiementfacilite'}
  </p>
  <p>
    {l s='Notre équipe examinera votre demande de financement et vous contactera dans les 48 heures ouvrables.' mod='paiementfacilite'}
  </p>

  {if $pf_request}
    <div style="margin-top:20px;padding:16px;background:#f8f9fa;border-radius:6px;max-width:440px;">
      <p style="font-weight:600;margin-bottom:12px;font-size:14px;">
        {l s='Récapitulatif de votre demande' mod='paiementfacilite'} <span
          style="color:#6c757d;">#{$pf_request->id|intval}</span>
      </p>
      <table style="width:100%;border-collapse:collapse;font-size:14px;">
        <tr>
          <td style="padding:6px 0;color:#6c757d;">{l s='Montant du crédit' mod='paiementfacilite'}</td>
          <td style="padding:6px 0;text-align:right;font-weight:600;">
            {$pf_request->credit_amount|string_format:"%.2f"} DT
          </td>
        </tr>
        <tr>
          <td style="padding:6px 0;color:#6c757d;">{l s='1ère tranche' mod='paiementfacilite'}</td>
          <td style="padding:6px 0;text-align:right;">
            {$pf_request->premiere_tranche|string_format:"%.2f"} DT
          </td>
        </tr>
        <tr>
          <td style="padding:6px 0;color:#6c757d;">{l s='Mensualité' mod='paiementfacilite'}</td>
          <td style="padding:6px 0;text-align:right;">
            {$pf_request->mensualite|string_format:"%.2f"} DT
            &times; {$pf_request->nb_mois|intval} {l s='mois' mod='paiementfacilite'}
          </td>
        </tr>
        <tr>
          <td style="padding:6px 0;color:#6c757d;">{l s='Statut' mod='paiementfacilite'}</td>
          <td style="padding:6px 0;text-align:right;">
            <span
              style="background:#ffc107;color:#212529;padding:2px 8px;border-radius:4px;font-size:12px;font-weight:600;">
              {l s='En attente' mod='paiementfacilite'}
            </span>
          </td>
        </tr>
      </table>
    </div>

    {* Instructions + download *}
    {if $pf_pdf_url}
      <div
        style="margin-top:20px;padding:16px;background:#e8f4fd;border:1px solid #bee5eb;border-radius:6px;font-size:14px;line-height:1.6;">
        <strong>{l s='Prochaine étape' mod='paiementfacilite'}</strong><br /><br />
        {l s='Veuillez imprimer ce document en 3 exemplaires et le faire signer par votre Paierie et votre Amicale, puis le renvoyer par :' mod='paiementfacilite'}
        <ul style="margin:8px 0 0 0;padding-left:18px;">
          <li>
            {l s='Mail sur l\'adresse :' mod='paiementfacilite'}
            <strong><a href="mailto:{$pf_admin_email|escape:'html'}">{$pf_admin_email|escape:'html'}</a></strong>
          </li>
          <li>{l s='WhatsApp' mod='paiementfacilite'}</li>
          <li>{l s='Messenger' mod='paiementfacilite'}</li>
        </ul>
      </div>

      <div style="margin-top:16px;">
        <a href="{$pf_pdf_url}"
          style="display:inline-block;padding:10px 20px;background:#28a745;color:#fff;border-radius:5px;text-decoration:none;font-weight:600;font-size:14px;">
          &#128462; {l s='Télécharger le document (Cession sur salaire)' mod='paiementfacilite'}
        </a>
      </div>

      {* <script>
        window.addEventListener('load', function() {
          setTimeout(function() {
            window.location.href = "{$pf_pdf_url}";
          }, 800);
        });
      </script> *}
    {/if}

  {/if}

</div>