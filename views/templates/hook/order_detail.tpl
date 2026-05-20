<div class="pf-wrapper" style="padding:0; margin-top:24px;">
  <div class="pf-section" style="margin-bottom:0;">

    {* ── Header ── *}
    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:20px; flex-wrap:wrap; gap:12px;">
      <h2 class="pf-section-title" style="margin:0;">
        {l s='Financement par facilité' mod='paiementfacilite'}
        &nbsp;<span style="font-size:13px; font-weight:400; color:var(--pf-muted);">#{$pf_od_request->id|intval}</span>
      </h2>
      <a href="{$pf_od_pdf_url|escape:'html'}" class="pf-btn-prev"
         style="text-decoration:none; font-size:12px; padding:9px 18px; white-space:nowrap;">
        &#128462; {l s='Télécharger la Cession sur salaire' mod='paiementfacilite'}
      </a>
    </div>

    <div class="pf-summary-grid" style="grid-template-columns:1fr 1fr;">

      {* ── LEFT : Identité ── *}
      <div>
        <p class="pf-section-subtitle">{l s='Identité' mod='paiementfacilite'}</p>
        <table class="pf-summary-table" style="margin-bottom:0;">
          <tr>
            <td class="pf-td-label">{l s='Nom' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_customer->firstname|escape:'html'} {$pf_od_customer->lastname|escape:'html'}</td>
          </tr>
          {if $pf_od_request->is_company && $pf_od_request->raison_sociale}
          <tr>
            <td class="pf-td-label">{l s='Société' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_request->raison_sociale|escape:'html'}</td>
          </tr>
          {/if}
          {if !$pf_od_request->is_company && $pf_od_request->fonction}
          <tr>
            <td class="pf-td-label">{l s='Fonction' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_request->fonction|escape:'html'}</td>
          </tr>
          {/if}
          {if $pf_od_org_name}
          <tr>
            <td class="pf-td-label">{l s='Organisme' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_org_name|escape:'html'}</td>
          </tr>
          {/if}
          {if $pf_od_address->address1}
          <tr>
            <td class="pf-td-label">{l s='Adresse' mod='paiementfacilite'}</td>
            <td class="pf-td-value">
              {$pf_od_address->address1|escape:'html'}
              {if $pf_od_address->city}, {$pf_od_address->city|escape:'html'}{/if}
            </td>
          </tr>
          {/if}
        </table>
      </div>

      {* ── RIGHT : Financement ── *}
      <div>
        <p class="pf-section-subtitle">{l s='Financement' mod='paiementfacilite'}</p>
        <table class="pf-summary-table" style="margin-bottom:0;">
          <tr>
            <td class="pf-td-label">{l s='Montant des achats' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_request->credit_amount|string_format:"%.2f"} DT</td>
          </tr>
          <tr>
            <td class="pf-td-label">{l s='Taux d\'intérêts' mod='paiementfacilite'}</td>
            <td class="pf-td-value">
              {if $pf_od_request->interest_rate > 0}
                {$pf_od_request->interest_rate|string_format:"%.2f"} %
              {else}
                {l s='Sans intérêts' mod='paiementfacilite'}
              {/if}
            </td>
          </tr>
          <tr>
            <td class="pf-td-label">{l s='1ère tranche' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_request->premiere_tranche|string_format:"%.2f"} DT</td>
          </tr>
          <tr>
            <td class="pf-td-label">{l s='Reste à payer' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_credit_reste|string_format:"%.2f"} DT</td>
          </tr>
          <tr>
            <td class="pf-td-label">{l s='Mensualité' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_request->mensualite|string_format:"%.2f"} DT</td>
          </tr>
          <tr>
            <td class="pf-td-label">{l s='Nombre de mois' mod='paiementfacilite'}</td>
            <td class="pf-td-value">{$pf_od_request->nb_mois|intval} {l s='mois' mod='paiementfacilite'}</td>
          </tr>
          <tr>
            <td class="pf-td-label">{l s='Statut' mod='paiementfacilite'}</td>
            <td class="pf-td-value">
              {assign var='pf_status' value=$pf_od_request->status}
              {if $pf_status == 'approved_emp'}
                <span style="background:var(--pf-black); color:#fff; padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; letter-spacing:.04em; text-transform:uppercase;">
                  {l s='Approuvée' mod='paiementfacilite'}
                </span>
              {elseif $pf_status == 'approved_mode'}
                <span style="background:var(--pf-black); color:#fff; padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; letter-spacing:.04em; text-transform:uppercase;">
                  {l s='Validée — en attente employeur' mod='paiementfacilite'}
                </span>
              {elseif $pf_status == 'rejected_mode' || $pf_status == 'rejected_emp'}
                <span style="background:#e5e5e5; color:var(--pf-black); padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; letter-spacing:.04em; text-transform:uppercase;">
                  {l s='Non accordée' mod='paiementfacilite'}
                </span>
              {else}
                <span style="background:#f5c518; color:var(--pf-black); padding:2px 10px; border-radius:20px; font-size:11px; font-weight:700; letter-spacing:.04em; text-transform:uppercase;">
                  {l s='En attente' mod='paiementfacilite'}
                </span>
              {/if}
            </td>
          </tr>
        </table>
      </div>

    </div>{* /pf-summary-grid *}

    {* ── Download CTA (full width, below grid) ── *}
    <div style="margin-top:20px;">
      <a href="{$pf_od_pdf_url|escape:'html'}" class="pf-submit-btn"
         style="display:inline-block; text-decoration:none; width:100%;">
        &#128462; {l s='Télécharger le document Cession sur salaire' mod='paiementfacilite'}
      </a>
    </div>

  </div>
</div>
