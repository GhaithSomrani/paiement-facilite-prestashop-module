{extends file='page.tpl'}

{block name='page_title'}
  {l s='Demande de paiement par facilité' mod='paiementfacilite'}
{/block}

{block name='page_content'}
  <div class="pf-wrapper">
    {* ── Draft resume banner (shown by JS when localStorage draft exists) ── *}
    <div id="pf-draft-banner"
      style="display:none;background:#fff8e1;border:1px solid #ffe082;border-radius:6px;padding:14px 18px;margin-bottom:20px;display:none;">
      <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;">
        <span style="font-size:14px;">
          {l s='Vous avez une demande en cours (étape' mod='paiementfacilite'}
          <strong class="pf-draft-step">?</strong>/6).
          {l s='Voulez-vous reprendre là où vous vous êtes arrêté ?' mod='paiementfacilite'}
        </span>
        <span style="display:flex;gap:10px;align-items:center;">
          <button type="button" id="pf-resume-btn" class="pf-btn-next" style="font-size:13px;padding:6px 16px;">
            {l s='Reprendre' mod='paiementfacilite'}
          </button>
          <button type="button" id="pf-restart-btn"
            style="background:none;border:none;color:#999;font-size:12px;cursor:pointer;text-decoration:underline;">
            {l s='Recommencer' mod='paiementfacilite'}
          </button>
        </span>
      </div>
    </div>

    {* ── Progress stepper ── *}
    <div class="pf-stepper">
      <div class="pf-step active" data-step="1"><span
          class="pf-step-num">1</span><small>{l s='Type' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="2"><span
          class="pf-step-num">2</span><small>{l s='Organisme' mod='paiementfacilite'}</small></div>
      <div class="pf-step{if $pf_is_from_checkout} pf-step-skipped{/if}" data-step="3"><span
          class="pf-step-num">3</span><small>{l s='Adresse' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="4"><span
          class="pf-step-num">4</span><small>{l s='Infos' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="5"><span
          class="pf-step-num">5</span><small>{l s='Crédit' mod='paiementfacilite'}</small></div>
      <div class="pf-step" data-step="6"><span
          class="pf-step-num">6</span><small>{l s='Documents' mod='paiementfacilite'}</small></div>
    </div>
    <div class="pf-progress-bar-wrap">
      <div class="pf-progress-fill" id="pf-progress-bar" style="width:16%"></div>
    </div>

    {* ── Alert container ── *}
    <div id="pf-alerts"></div>

    <form id="pf-form" action="{$pf_form_action|escape:'html'}" method="POST" enctype="multipart/form-data" novalidate>

      <input type="hidden" name="submitPFRequest" value="1">
      <input type="hidden" name="id_order" id="pf_id_order" value="{$pf_id_order|intval}">
      <input type="hidden" name="id_cart" id="pf_id_cart" value="{$pf_id_cart|intval}">
      <input type="hidden" name="id_address" id="pf_id_address_hidden" value="{$pf_selected_address_id|intval}">
      <input type="hidden" name="belongs_to_partner" id="pf_belongs_to_partner" value="0">

      {* ======================================================
       STEP 1 — TYPE DE CLIENT
       ====================================================== *}
      <section class="pf-section pf-step-panel active" data-step="1">
        <h2 class="pf-section-title">{l s='Type de client' mod='paiementfacilite'}</h2>

        <div class="pf-client-types">
          <label class="pf-client-card" data-value="0">
            <input type="radio" name="is_company" value="0" class="pf-radio-type" required>
            <span class="pf-client-card-inner">
              <svg viewBox="0 0 24 24" width="44" height="44" fill="none" stroke="currentColor" stroke-width="1.5"
                stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <circle cx="9" cy="8" r="3.5" />
                <path d="M2.5 19c.7-3 3.4-4.5 6.5-4.5s5.8 1.5 6.5 4.5" />
                <circle cx="17" cy="7" r="2.5" />
                <path d="M15 13.5c1.5-.6 3-.8 4.5-.4 1.4.4 2.2 1.3 2.5 2.4" />
              </svg>
              <span class="pf-client-label">{l s='Salarié ou Retraité' mod='paiementfacilite'}</span>
            </span>
          </label>

          <label class="pf-client-card" data-value="1">
            <input type="radio" name="is_company" value="1" class="pf-radio-type">
            <span class="pf-client-card-inner">
              <svg viewBox="0 0 24 24" width="44" height="44" fill="none" stroke="currentColor" stroke-width="1.5"
                stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <path d="M4 21V7l8-4 8 4v14" />
                <path d="M4 21h16" />
                <path d="M9 21v-5h6v5" />
                <path d="M8 9h2M14 9h2M8 12h2M14 12h2" />
              </svg>
              <span class="pf-client-label">{l s='Société' mod='paiementfacilite'}</span>
            </span>
          </label>
        </div>

        {* Retraité toggle *}
        <div id="pf-retired-block" style="display:none;">
          <p class="pf-retired-question">{l s='Êtes-vous retraité(e) ?' mod='paiementfacilite'}</p>
          <div class="pf-toggle-row">
            <label class="pf-toggle-btn is-selected" data-value="0">
              <input type="radio" name="is_retired" value="0" checked> {l s='Non' mod='paiementfacilite'}
            </label>
            <label class="pf-toggle-btn" data-value="1">
              <input type="radio" name="is_retired" value="1"> {l s='Oui' mod='paiementfacilite'}
            </label>
          </div>
        </div>

        <div class="pf-nav">
          <span></span>
          <button type="button" class="pf-btn-next pf-next-btn">{l s='Suivant' mod='paiementfacilite'} →</button>
        </div>
      </section>

      {* ======================================================
       STEP 2 — ORGANISME
       ====================================================== *}
      <section class="pf-section pf-step-panel" data-step="2">
        <h2 class="pf-section-title">{l s='Organisme partenaire' mod='paiementfacilite'}</h2>

        <div class="pf-field">
          <select name="id_organisation" id="pf-org-select">
            <option value="0">{l s="N'appartient à aucun organisme" mod='paiementfacilite'}</option>
            {foreach $pf_organisations as $org}
              <option value="{$org.id_organisation|intval}">{$org.name|escape:'html'}</option>
            {/foreach}
            <option value="-1">{l s='Autre organisme' mod='paiementfacilite'}</option>
          </select>
        </div>

        <div id="pf-org-autre-block" style="display:none;">
          <div class="pf-field">
            <input type="text" name="organisation_autre" id="pf-org-autre" maxlength="255"
              placeholder="{l s='Nom de l\'organisme *' mod='paiementfacilite'}">
          </div>
        </div>

        <div id="pf-partner-notice" class="pf-notice pf-notice-success" style="display:none;">
          {l s='En tant que membre d\'un organisme partenaire, vous êtes dispensé(e) de fournir des documents.' mod='paiementfacilite'}
        </div>

        <div class="pf-nav">
          <button type="button" class="pf-btn-prev pf-prev-btn">← {l s='Précédent' mod='paiementfacilite'}</button>
          <button type="button" class="pf-btn-next pf-next-btn">{l s='Suivant' mod='paiementfacilite'} →</button>
        </div>
      </section>

      {* ======================================================
       STEP 3 — ADRESSE
       ====================================================== *}
      <section class="pf-section pf-step-panel" data-step="3">
        <h2 class="pf-section-title">{l s='Votre adresse' mod='paiementfacilite'}</h2>

        {if $pf_is_from_checkout && $pf_selected_address_id}
          <div class="pf-notice mb-3">
            <strong
              style="font-size:10px;letter-spacing:.06em;text-transform:uppercase;">{l s='Adresse de facturation' mod='paiementfacilite'}</strong><br>
            {foreach $pf_addresses as $addr}
              {if $addr.id_address == $pf_selected_address_id}
                {$addr.firstname|escape:'html'} {$addr.lastname|escape:'html'} —
                {$addr.address1|escape:'html'}, {$addr.postcode|escape:'html'} {$addr.city|escape:'html'}
              {/if}
            {/foreach}
          </div>
        {/if}

        <div class="pf-field">
          <select id="pf-address-select">
            {foreach $pf_addresses as $addr}
              <option value="{$addr.id_address|intval}" {if $addr.id_address == $pf_selected_address_id}selected{/if}>
                {$addr.alias|escape:'html'} — {$addr.address1|escape:'html'}, {$addr.city|escape:'html'}
              </option>
            {/foreach}
          </select>
        </div>

        <button type="button" id="pf-add-address-btn" class="pf-add-more">
          + {l s='Ajouter une nouvelle adresse' mod='paiementfacilite'}
        </button>

        <div class="pf-nav">
          <button type="button" class="pf-btn-prev pf-prev-btn">← {l s='Précédent' mod='paiementfacilite'}</button>
          <button type="button" class="pf-btn-next pf-next-btn">{l s='Suivant' mod='paiementfacilite'} →</button>
        </div>
      </section>

      {* ======================================================
       STEP 4 — INFORMATIONS PERSONNELLES
       ====================================================== *}
      <section class="pf-section pf-step-panel" data-step="4">
        <h2 class="pf-section-title" id="pf-step4-title">{l s='Informations personnelles' mod='paiementfacilite'}</h2>

        {* Personal fields — hidden for companies *}
        <div id="pf-personal-fields">
          <div class="pf-grid">
            <div class="pf-field">
              <input type="date" name="date_naissance" id="pf-date-naissance" value="{$pf_birthday|escape:'html'}"
                max="{$smarty.now|date_format:'%Y-%m-%d'}"
                placeholder="{l s='Date de naissance *' mod='paiementfacilite'}">
            </div>
            <div class="pf-field">
              <input type="text" name="cin" id="pf-cin" maxlength="32" placeholder="{l s='Numéro de CIN *' mod='paiementfacilite'}">
            </div>
            <div class="pf-field pf-span-2">
              <input type="text" name="fonction" id="pf-fonction" maxlength="128"
                placeholder="{l s='Fonction / Profession *' mod='paiementfacilite'}">
            </div>
          </div>
        </div>

        {* Company fields — hidden for individuals *}
        <div id="pf-company-fields" style="display:none;">
          <h3 class="pf-section-title" style="font-size:12px;margin-top:20px;">
            {l s='Informations de la société' mod='paiementfacilite'}</h3>
          <div class="pf-grid">
            <div class="pf-field">
              <input type="text" name="raison_sociale" id="pf-raison-sociale" maxlength="255"
                placeholder="{l s='Raison Sociale *' mod='paiementfacilite'}">
            </div>
            <div class="pf-field">
              <input type="text" name="representant_legal" id="pf-representant-legal" maxlength="255"
                placeholder="{l s='Représentant légal *' mod='paiementfacilite'}">
            </div>
            <div class="pf-field">
              <input type="date" name="date_naissance_gerant" id="pf-date-naissance-gerant"
                max="{$smarty.now|date_format:'%Y-%m-%d'}"
                placeholder="{l s='Date de naissance du gérant *' mod='paiementfacilite'}">
            </div>
            <div class="pf-field">
              <input type="tel" name="telephone_gerant" id="pf-telephone-gerant" maxlength="32"
                placeholder="{l s='Numéro de téléphone *' mod='paiementfacilite'} (+216 XX XXX XXX)">
            </div>
            <div class="pf-field">
              <input type="email" name="email_gerant" id="pf-email-gerant" maxlength="128"
                placeholder="{l s='Adresse email *' mod='paiementfacilite'}">
            </div>
            <div class="pf-field">
              <input type="text" name="cin_gerant" id="pf-cin-gerant" maxlength="32"
                placeholder="{l s="N° CIN gérant *" mod='paiementfacilite'}">
            </div>
          </div>
        </div>

        <div class="pf-nav">
          <button type="button" class="pf-btn-prev pf-prev-btn">← {l s='Précédent' mod='paiementfacilite'}</button>
          <button type="button" class="pf-btn-next pf-next-btn"
            data-validates-step="4">{l s='Suivant' mod='paiementfacilite'} →</button>
        </div>
      </section>

      {* ======================================================
       STEP 5 — DÉTAILS DU CRÉDIT
       ====================================================== *}
      <section class="pf-section pf-step-panel" data-step="5">
        <h2 class="pf-section-title">{l s='Détails du crédit' mod='paiementfacilite'}</h2>

        {if $pf_is_from_checkout && $pf_order_items}
          {* ── Order details replacing the slider ── *}
          <input type="hidden" name="credit_amount" id="pf-credit-slider" value="{$pf_order_amount|floatval}">

          <table style="width:100%;border-collapse:collapse;font-size:14px;margin-bottom:4px;">
            <thead>
              <tr style="background:#f1f3f5;">
                <th style="padding:8px 10px;text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.05em;">
                  {l s='Produit' mod='paiementfacilite'}</th>
                <th
                  style="padding:8px 10px;text-align:center;font-size:11px;text-transform:uppercase;letter-spacing:.05em;">
                  {l s='Qté' mod='paiementfacilite'}</th>
                <th style="padding:8px 10px;text-align:right;font-size:11px;text-transform:uppercase;letter-spacing:.05em;">
                  {l s='P.U.' mod='paiementfacilite'}</th>
                <th style="padding:8px 10px;text-align:right;font-size:11px;text-transform:uppercase;letter-spacing:.05em;">
                  {l s='Total' mod='paiementfacilite'}</th>
              </tr>
            </thead>
            <tbody>
              {foreach $pf_order_items as $item}
                <tr style="border-bottom:1px solid #e9ecef;">
                  <td style="padding:10px 10px;">{$item.name|escape:'html'}</td>
                  <td style="padding:10px;text-align:center;color:#555;">{$item.qty}</td>
                  <td style="padding:10px;text-align:right;white-space:nowrap;">{$item.unit|string_format:"%.3f"} DT</td>
                  <td style="padding:10px;text-align:right;white-space:nowrap;font-weight:600;">
                    {$item.total|string_format:"%.3f"} DT</td>
                </tr>
              {/foreach}
            </tbody>
            {if $pf_order_fees}
              <tbody>
                {foreach $pf_order_fees as $fee}
                  <tr style="border-bottom:1px solid #e9ecef;color:#555;">
                    <td colspan="3" style="padding:8px 10px;">{$fee.label|escape:'html'}</td>
                    <td style="padding:8px 10px;text-align:right;white-space:nowrap;">
                      {if $fee.sign == -1}−{/if}{$fee.amount|string_format:"%.3f"} DT
                    </td>
                  </tr>
                {/foreach}
              </tbody>
            {/if}
            <tfoot>
              <tr style="background:#f8f9fa;">
                <td colspan="3" style="padding:12px 10px;font-weight:700;font-size:15px;">
                  {l s='Montant total du crédit' mod='paiementfacilite'}</td>
                <td
                  style="padding:12px 10px;text-align:right;font-weight:700;font-size:18px;color:#1a1a1a;white-space:nowrap;">
                  <span id="pf-amount-display">{$pf_order_amount|string_format:"%.3f"}</span> DT
                </td>
              </tr>
            </tfoot>
          </table>

        {else}
          {* Standalone — free slider *}
          <p class="pf-slider-label">
            {l s='Fourchette de votre crédit' mod='paiementfacilite'}
            ({$pf_min_amount|intval} DT – {$pf_max_amount|intval} DT) *
          </p>
          <input type="range" name="credit_amount" id="pf-credit-slider" class="pf-slider" min="{$pf_min_amount|intval}"
            max="{$pf_max_amount|intval}" step="50" value="{$pf_default_amount|intval}">
          <div class="pf-slider-row">
            <span>{$pf_min_amount|intval} DT</span>
            <span class="pf-slider-current"><span id="pf-amount-display">{$pf_default_amount|intval}</span> DT</span>
            <span>{$pf_max_amount|intval} DT</span>
          </div>
        {/if}

        <p class="pf-slider-label" style="margin-top:24px;">{l s='Nombre de mensualités' mod='paiementfacilite'} *</p>
        <div class="pf-toggle-row pf-toggle-row--wrap" id="pf-mois-row">
          {for $m = 2 to $max_months}
            <label class="pf-toggle-btn{if $m == 6} is-selected{/if}" data-mois="{$m}">
              <input type="radio" name="nb_mois" value="{$m}" {if $m == 6} checked{/if}> {$m}
            </label>
          {/for}
        </div>

        {* Interest info — shown by JS only when a range with interest applies *}
        <div id="pf-interest-badge"
          style="display:none;margin:12px 0;padding:10px 14px;background:#fff8e1;border:1px solid #ffe082;border-radius:6px;font-size:13px;color:#795548;">
        </div>
        <input type="hidden" name="interest_rate" id="pf-interest-rate" value="0">

        <div class="pf-credit-boxes">
          <div class="pf-credit-box">
            <div class="pf-credit-box-label">{l s='1ère tranche (min = 1 mensualité)' mod='paiementfacilite'}</div>
            <input type="number" name="premiere_tranche" id="pf-tranche" step="0.01" required placeholder="0.00">
            <small id="pf-tranche-error" style="display:none;color:#c0392b;font-size:12px;margin-top:4px;"></small>
          </div>
          <div class="pf-credit-box">
            <div class="pf-credit-box-label">{l s='Mensualité' mod='paiementfacilite'} (<span
                id="pf-mois-display">6</span> {l s='mois' mod='paiementfacilite'})</div>
            <div class="pf-credit-box-value"><span id="pf-mensualite-display">—</span> DT</div>
            <input type="hidden" name="mensualite" id="pf-mensualite" value="0">
          </div>
        </div>

        <div class="pf-field" style="margin-top:20px;">
          <textarea name="commentaire" id="pf-commentaire" rows="3" maxlength="2000"
            placeholder="{l s='Commentaire (facultatif)' mod='paiementfacilite'}"></textarea>
        </div>

        <div class="pf-nav">
          <button type="button" class="pf-btn-prev pf-prev-btn">← {l s='Précédent' mod='paiementfacilite'}</button>
          <button type="button" class="pf-btn-next pf-next-btn" id="pf-step5-next">{l s='Suivant' mod='paiementfacilite'}
            →</button>
        </div>
      </section>

      {* ======================================================
       STEP 6 — DOCUMENTS
       ====================================================== *}
      <section class="pf-section pf-step-panel" data-step="6" id="pf-docs-step">
        <h2 class="pf-section-title">{l s='Documents requis' mod='paiementfacilite'}</h2>

        {* ── Individual docs (salarié / retraité) ── *}
        <div id="pf-doc-salarie-block" class="pf-doc pf-doc-group">
          <p class="pf-doc-title">{l s='Trois dernières fiches de paie' mod='paiementfacilite'} *</p>
          <p class="pf-doc-hint">
            {l s='Avec cachet et signature de l\'employeur (PNG, JPEG ou PDF — max 5 MB)' mod='paiementfacilite'}</p>
          <div class="pf-file-row" id="pf-fiche-rows">
            <label class="pf-file-pick">
              <input type="file" name="fiche_paie[]" accept=".jpg,.jpeg,.png,.pdf">
              <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
              <span class="pf-file-name"></span>
            </label>
          </div>
          <button type="button" class="pf-add-more" data-target="pf-fiche-rows" data-max="3">+
            {l s='Ajouter un autre fichier' mod='paiementfacilite'}</button>
        </div>

        <div id="pf-doc-retraite-block" class="pf-doc pf-doc-group" style="display:none;">
          <p class="pf-doc-title">{l s='Attestation retraite CNSS/CNRPS' mod='paiementfacilite'} *</p>
          <p class="pf-doc-hint">{l s='PNG, JPEG ou PDF — max 5 MB' mod='paiementfacilite'}</p>
          <div class="pf-file-row">
            <label class="pf-file-pick">
              <input type="file" name="attestation_retraite" accept=".jpg,.jpeg,.png,.pdf">
              <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
              <span class="pf-file-name"></span>
            </label>
          </div>
        </div>

        {* ── Company docs (société) ── *}
        <div id="pf-doc-societe-block" class="pf-doc-group" style="display:none;">
          <div class="pf-doc">
            <p class="pf-doc-title">{l s='Copie du RNE' mod='paiementfacilite'} *</p>
            <p class="pf-doc-hint">
              {l s='Registre National des Entreprises (PNG, JPEG ou PDF — max 5 MB)' mod='paiementfacilite'}</p>
            <div class="pf-file-row">
              <label class="pf-file-pick">
                <input type="file" name="copie_rne" accept=".jpg,.jpeg,.png,.pdf">
                <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
                <span class="pf-file-name"></span>
              </label>
            </div>
          </div>
          <div class="pf-doc">
            <p class="pf-doc-title">{l s='Carte d\'identité du gérant' mod='paiementfacilite'} *</p>
            <p class="pf-doc-hint">{l s='Recto et verso (PNG, JPEG ou PDF — max 5 MB)' mod='paiementfacilite'}</p>
            <div class="pf-file-row two-cols">
              <label class="pf-file-pick">
                <input type="file" name="cin_gerant_recto" accept=".jpg,.jpeg,.png,.pdf">
                <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
                <span class="pf-file-name"></span>
                <span class="pf-file-side">{l s='Recto' mod='paiementfacilite'}</span>
              </label>
              <label class="pf-file-pick">
                <input type="file" name="cin_gerant_verso" accept=".jpg,.jpeg,.png,.pdf">
                <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
                <span class="pf-file-name"></span>
                <span class="pf-file-side">{l s='Verso' mod='paiementfacilite'}</span>
              </label>
            </div>
          </div>
        </div>

        {* ── Individual common docs (hidden for companies) ── *}
        <div id="pf-doc-individual-common" class="pf-doc-group">
          <div class="pf-doc">
            <p class="pf-doc-title">{l s='Carte d\'identité nationale (CIN)' mod='paiementfacilite'} *</p>
            <p class="pf-doc-hint">{l s='Recto et verso (PNG, JPEG ou PDF — max 5 MB)' mod='paiementfacilite'}</p>
            <div class="pf-file-row two-cols">
              <label class="pf-file-pick">
                <input type="file" name="cin_recto" accept=".jpg,.jpeg,.png,.pdf">
                <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
                <span class="pf-file-name"></span>
                <span class="pf-file-side">{l s='Recto' mod='paiementfacilite'}</span>
              </label>
              <label class="pf-file-pick">
                <input type="file" name="cin_verso" accept=".jpg,.jpeg,.png,.pdf">
                <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
                <span class="pf-file-name"></span>
                <span class="pf-file-side">{l s='Verso' mod='paiementfacilite'}</span>
              </label>
            </div>
          </div>
          <div class="pf-doc">
            <p class="pf-doc-title">{l s='Dernière facture STEG ou SONEDE' mod='paiementfacilite'} *</p>
            <p class="pf-doc-hint">{l s='PNG, JPEG ou PDF — max 5 MB' mod='paiementfacilite'}</p>
            <div class="pf-file-row">
              <label class="pf-file-pick">
                <input type="file" name="facture_steg" accept=".jpg,.jpeg,.png,.pdf">
                <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
                <span class="pf-file-name"></span>
              </label>
            </div>
          </div>
        </div>

        {* ── Common docs (individual & company) ── *}
        <div class="pf-doc pf-doc-group">
          <p class="pf-doc-title">{l s='Identité Bancaire (RIB)' mod='paiementfacilite'} *</p>
          <p class="pf-doc-hint">{l s='Avec cachet de la banque (PNG, JPEG ou PDF — max 5 MB)' mod='paiementfacilite'}</p>
          <div class="pf-file-row">
            <label class="pf-file-pick">
              <input type="file" name="rib" id="pf-rib" accept=".jpg,.jpeg,.png,.pdf">
              <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
              <span class="pf-file-name"></span>
            </label>
          </div>
        </div>

        <div class="pf-doc pf-doc-group">
          <p class="pf-doc-title">{l s='Trois derniers relevés bancaires' mod='paiementfacilite'} *</p>
          <p class="pf-doc-hint">{l s='Avec cachet de la banque (PNG, JPEG ou PDF — max 5 MB)' mod='paiementfacilite'}</p>
          <div class="pf-file-row" id="pf-releve-rows">
            <label class="pf-file-pick">
              <input type="file" name="releve_bancaire[]" accept=".jpg,.jpeg,.png,.pdf">
              <span class="pf-file-btn">{l s='Choisir un fichier' mod='paiementfacilite'}</span>
              <span class="pf-file-name"></span>
            </label>
          </div>
          <button type="button" class="pf-add-more" data-target="pf-releve-rows" data-max="3">+
            {l s='Ajouter un autre fichier' mod='paiementfacilite'}</button>
        </div>

        {* Partner bypass *}
        <div id="pf-docs-bypass" class="pf-notice pf-notice-success" style="display:none;">
          {l s='Documents non requis — votre organisme partenaire prend en charge la vérification.' mod='paiementfacilite'}
        </div>

        <div class="pf-nav">
          <button type="button" class="pf-btn-prev pf-prev-btn">← {l s='Précédent' mod='paiementfacilite'}</button>
          <button type="submit" class="pf-submit-btn" id="pf-submit-btn">
            {l s='Je dépose mon dossier' mod='paiementfacilite'}
          </button>
        </div>
        <p class="pf-reassurance">
          {l s='Nous vous répondons dans 24 heures ouvrables.' mod='paiementfacilite'}
        </p>

      </section>

    </form>

  </div>{* /pf-wrapper *}

  {* ── Address Modal ── *}
  {include file='module:paiementfacilite/views/templates/front/_partials/address-modal.tpl'}

  {* ── JS config ── *}
  <script>
    var PF_CONFIG = {
      ajaxUrl:        '{$pf_ajax_url|escape:'javascript'}',
      minAmount:      {$pf_min_amount|floatval},
      maxAmount:      {$pf_max_amount|floatval},
      isFromCheckout: {if $pf_is_from_checkout}true{else}false{/if},
      hasAddresses:   {if $pf_addresses}true{else}false{/if},
      errorsJson:     {if $pf_errors_json}'{$pf_errors_json|escape:'javascript'}'{else}null{/if},
      orderAmount:    {$pf_order_amount|floatval},
      monthConfigs:   {$pf_month_configs_json nofilter},
    };
  </script>

{/block}