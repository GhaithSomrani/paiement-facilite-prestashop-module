{extends file='page.tpl'}

{block name='page_title'}
  {l s='Mes demandes de facilité' mod='paiementfacilite'}
{/block}

{block name='page_content'}
<div class="pf-wrapper" style="max-width:900px;">

  <div class="pf-section">
    <h2 class="pf-section-title" style="margin-bottom:20px;">{l s='Mes demandes' mod='paiementfacilite'}</h2>

    <a href="{$pf_new_url|escape:'html'}" class="pf-submit-btn"
       style="text-decoration:none; margin-bottom:24px;">
      + {l s='Nouvelle demande' mod='paiementfacilite'}
    </a>

    <div style="overflow-x:auto;">
      <table class="pf-list-table">
        <thead>
          <tr>
            <th>{l s='Demande' mod='paiementfacilite'}</th>
            <th>{l s='Date' mod='paiementfacilite'}</th>
            <th>{l s='Montant' mod='paiementfacilite'}</th>
            <th>{l s='Mois' mod='paiementfacilite'}</th>
            <th>{l s='Statut' mod='paiementfacilite'}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {foreach $pf_my_requests as $req}
            {assign var='st' value=$pf_status_map[$req.status]}
            <tr>
              <td>#{$req.id_request|intval}</td>
              <td>{$req.date_add|date_format:"%d/%m/%Y"}</td>
              <td>{$req.credit_amount|string_format:"%.2f"} DT</td>
              <td>{$req.nb_mois|intval}</td>
              <td>
                <span class="pf-request-row-status" style="background:{if $st.color}{$st.color|escape:'html'}{else}#888888{/if};">
                  {if $st.name}{$st.name|escape:'html'}{else}{$req.status|escape:'html'}{/if}
                </span>
              </td>
              <td class="pf-list-table-actions">
                <a href="{$pf_details_url|escape:'html'}&id_request={$req.id_request|intval}" class="pf-btn-prev">
                  {l s='Voir les détails' mod='paiementfacilite'}
                </a>
                {if $req.nb_mois != 36}
                <a href="{$pf_pdf_url|escape:'html'}&id_request={$req.id_request|intval}" class="pf-btn-prev">
                  &#128462; {l s='PDF' mod='paiementfacilite'}
                </a>
                {/if}
              </td>
            </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>

</div>
{/block}
