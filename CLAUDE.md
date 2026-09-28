# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Module Identity
**Name:** paiementfacilite
**Version:** 1.2.0 (see `PF_VERSION` config key; `paiementfacilite.php` header constant currently reads `1.1.0` — trust `runUpgrades()` for the real schema state, not the version string)
**Type:** PrestaShop PaymentModule (1.7/8.x)
**Purpose:** Installment / bill-of-exchange ("facilité / traite") payment requests for Tunisian e-commerce. A customer submits a credit application (salaried, retired, or company); the request goes through a **two-stage approval** ("La Mode" then "employeur") before the linked order is marked paid.

---

## Development Environment

No build step. PHP changes are live after clearing PrestaShop cache:
- **Admin Panel:** Advanced Parameters → Performance → Clear Cache
- **Manual:** Delete contents of `var/cache/` in the PrestaShop root (`C:\Users\E-Market\Desktop\prestashop`)

Module installation/reinstallation from admin: Modules → Module Manager → Search "paiementfacilite".

**Schema migrations** live in `paiementfacilite.php::runUpgrades()`, gated by the `PF_VERSION` config key, and run every time an admin opens the module's `getContent()` config page (not just on install/upgrade). When adding a schema change, add a new `version_compare($version, 'X.Y.Z', '<')` block there — do not rely solely on `upgrade/upgrade-1.1.0.php`, which only fires through PrestaShop's module-upgrade mechanism.

---

## Architecture

### Request Lifecycle
```
Customer (logged in) → checkout "Paiement par facilité" (hookPaymentOptions, ?id_cart=X)
  → front/request.php::initContent() immediately calls PaymentModule::validateOrder()
    on that cart (pending state) and redirects to ?id_order=X — same as any other
    payment module (bank wire, cheque): the order exists before the wizard is shown
  → 6-step form runs against id_order (amount/items locked to the order total, not
    a cart — the cart is already converted/cleared by validateOrder())
  → step 6 submit → PaiementFaciliteRequest saved (status: pending), documents
    uploaded, request linked to the existing order via pf_request_orders
  → emails sent (pf_confirmation to customer w/ PDF attached, pf_admin_notification to admin)
  → redirect straight to order-confirmation (no separate "Confirmer" click)
  → Admin: AdminPaiementFaciliteRequests → validate/reject in TWO stages:
      1. "La Mode" stage:      approve_mode  → status=approved_mode / reject_mode → rejected_mode
      2. "Employeur" stage:    approve_employeur → status=approved_emp (only allowed from approved_mode)
                               reject_employeur  → rejected_emp (only allowed from approved_mode)
  → each stage transition sends pf_approved or pf_rejected email and moves the linked
    order to whatever ps_order_state is mapped in pf_statuses.id_order_state

Standalone entry (no cart at all — "Mes demandes" → "Nouvelle demande"):
  → 6-step form runs with no id_order, credit_amount freely entered
  → step 6 submit → PaiementFaciliteRequest saved, redirect to ?summary=1&id_request=X
  → customer clicks "Confirmer" → IF they have an active cart at that moment, an
    order is created from it and linked; otherwise the request stays orderless
```

Requests do **not** always have an order: a genuinely standalone request can have none at all — `pf_request_orders.id_order` is nullable and `PaiementFaciliteRequest::linkOrder($id_order = null)` handles both cases. But a checkout-originated request is *always* tied to an order from the very first page load, unlike the pre-order-first design this replaced.

### Entity Classes (`classes/`)

**`PaiementFaciliteRequest`** — table `pf_requests`
- Central entity. Two client paths: individual (`is_company=0`, further split by `is_retired`) vs company (`is_company=1`).
- `belongs_to_partner` flag: set when the customer picked a real partner organisation (`id_organisation > 0`); document uploads are skipped and interest is waived (org handles verification/financing terms externally). `id_organisation = -1` from the form means "autre" (free-text org name in `organisation_autre`), which is **not** partner status and still requires documents + interest.
- `status` is an enum with 5 values, not a simple pending/approved/rejected: `pending`, `approved_mode`, `rejected_mode`, `approved_emp`, `rejected_emp`. `updateStatus()` only allows these five.
- `interest_rate` and per-`nb_mois` minimums come from `PaiementFaciliteMonthConfig`, looked up at submission time and frozen onto the request row (historical, like commission_rate elsewhere in this codebase family).
- `linkOrder()` / `getLinkedOrder()` relate a request to a PrestaShop order via `pf_request_orders`.

**`PaiementFaciliteMonthConfig`** — table `pf_month_configs`
- One row per `nb_mois` (2–12): `min_amount` (credit floor to unlock that month count) + `interest_rate` (flat %, applied to the whole credit amount, not per-installment).
- `getAllConfigsForJs()` feeds the frontend JS so the month-selector buttons and mensualité math match server-side validation in `request.php::processForm()`.
- Formula: `total_with_interest = credit_amount * (1 + interest_rate/100)`; `min_tranche = total_with_interest / nb_mois`; `mensualite = (total_with_interest - premiere_tranche) / (nb_mois - 1)`.

**`PaiementFaciliteStatus`** — table `pf_statuses`
- Configurable metadata for the 5 status codes: display name, color, `sort_order`, and **`id_order_state`** — the PrestaShop order state a request status maps to. Seeded by `sql/install.php` with `id_order_state = NULL`; an admin wires these to real `ps_order_state` IDs (or the module's own `PF_OS_PENDING`/`PF_OS_APPROVED`/`PF_OS_REJECTED` states created in `installOrderStates()`) via `AdminPaiementFaciliteStatusController`.
- `applyOrderStateFromStatus()` in the requests admin controller reads this mapping and calls `OrderHistory::changeIdOrderState()` on the linked order — if there's no mapping or no linked order, it's a no-op.

**`PaiementFaciliteOrganisation`** — table `pf_organisations`
- Partner organisations selectable by customers, now with `contact_name`/`contact_email`/`contact_phone`/`address`/`logo` fields (managed via `AdminPaiementFaciliteOrganisationsController`).
- Logos live at `uploads/organisations/{id_organisation}/{filename}` (separate from request document uploads).

**`PaiementFaciliteDocument`** — table `pf_documents`
- Files stored at `uploads/{id_request}/{doc_type}_{uniqid}.{ext}` inside the module directory.
- `saveUpload()` validates MIME (jpeg/png/pdf via `finfo`), size ≤ 5 MB, and extension before moving.
- Single-upload types: `cin_recto`, `cin_verso`, `rib`, `facture_steg`, `attestation_retraite`, `copie_rne`. (`registre_commerce`, `statuts_societe` are defined as allowed types but not currently wired into the front form's upload map — check `request.php::processDocumentUploads()` before assuming they're collected.)
- Multi-upload types (up to 3 each): `fiche_paie`, `releve_bancaire`.
- For companies, gérant CIN photos post as `cin_gerant_recto`/`cin_gerant_verso` but are stored under the shared `TYPE_CIN_RECTO`/`TYPE_CIN_VERSO` doc types (same as individuals) — don't expect distinct gérant-specific doc_type values in `pf_documents`.

### Controllers

**`controllers/front/request.php`** — `PaiementFaciliteRequestModuleFrontController`
- Requires customer login; redirects to `authentication` otherwise.
- One controller, several states multiplexed through query params (handled in `initContent()` / `postProcess()`, in this priority order):
  - `?ajax=1` → JSON AJAX (`saveAddress`, `getAddresses`)
  - `submitPFRequest` POST → `processForm()`, creates the `pf_requests` row, links it to `id_order` (already existing — see below), and redirects to order-confirmation
  - `?id_cart=X` with no `id_order` yet (checkout entry, from `hookPaymentOptions`) → `initContent()` calls `validateOrder()` on that cart immediately and redirects to `?id_order=X`; the wizard is never shown against a bare cart
  - `?id_order=X` → the 6-step wizard, with amount/items locked to that order's total (`Order::total_paid`) instead of a cart
  - `?summary=1&id_request=X` → `initContentSummary()`: preview page with computed totals, PDF preview/download links, and — for a still-unlinked (standalone) request only — a "Confirmer" action; idempotent (if already linked to an order, just re-shows the summary)
  - `?confirm_request=1&id_request=X` (POST from the summary page, standalone requests only) → `processConfirmRequest()`: creates an order from whatever cart is active at that moment via `validateOrder()` (skipped if no cart — request stays orderless), links it, sends `pf_confirmation`/`pf_admin_notification` emails with the PDF attached, then redirects to order-confirmation or back to summary
  - `?download_pdf=1&id_request=X` / `?pdf_html=1&id_request=X` → stream the "cession de salaire" PDF (or its raw HTML for debugging) via `HTMLTemplateCessionSalairePDF`
  - `?confirmed=1&id_request=X` (legacy) → redirects into the summary flow
- All of the above ownership-gated: `loadOwnedRequest()` 404s (redirects home) if the request doesn't belong to the logged-in customer; the `id_order`/`id_cart` entry points check `Order`/`Cart` ownership the same way.
- Credit amount is **locked to the order total** (`Order::total_paid`) whenever `id_order` is present and owned by the customer; only a genuinely standalone request (no order at all) accepts a freely-entered `credit_amount` within `PF_MIN_AMOUNT`/`PF_MAX_AMOUNT`.

**`controllers/admin/AdminPaiementFaciliteRequestsController.php`** — `ModuleAdminController`
- List view with joins for customer, organisation, and linked order; status column uses PrestaShop's built-in badge coloring (`badge_warning`/`badge_info`/`badge_success`/`badge_danger`) across the 5 status codes.
- Individual + bulk actions: `approve_mode`/`reject_mode` (stage 1, valid from `pending`), `approve_employeur`/`reject_employeur` (stage 2, valid **only** from `approved_mode` — enforced by checking `$request->status === 'approved_mode'` before allowing the transition).
- Each transition: `updateStatus()` → `applyOrderStateFromStatus()` (order history/state change if mapped) → `sendStatusEmail()` (`pf_approved` template for both `approved_*`, `pf_rejected` for both `rejected_*`).
- `postProcess()` handles `download_doc` to stream an uploaded document to the admin browser.

**Other admin controllers:** `AdminPaiementFaciliteOrganisationsController` (organisation CRUD + logo upload), `AdminPaiementFaciliteStatusController` (edit `pf_statuses` name/color/order-state mapping), `AdminPaiementFaciliteAmountRangesController` (edits `pf_month_configs` despite the tab's legacy class name — the tab label was updated to "Config. mensualités" in the 1.2.0 upgrade but the class name from the 1.1.0 "amount ranges" concept was kept to avoid a tab-migration; don't rename the class without also updating `installTab()`/`uninstallTab()`/`runUpgrades()` tab lookups by class name).

### Main Module (`paiementfacilite.php`)
- Registered hooks: `paymentOptions`, `paymentReturn`, `displayCustomerAccount`, `displayBackOfficeHeader`, `displayOrderDetail` (self-registered lazily in `hookDisplayBackOfficeHeader()` if a pre-existing install predates this hook).
- `installOrderStates()` creates three module-owned order states (`PF_OS_PENDING`, `PF_OS_APPROVED`, `PF_OS_REJECTED`) on install, skipped if the config key already points at a valid state (safe to re-run).
- Config page (`getContent()`) manages `PF_ADMIN_EMAIL`, `PF_MIN_AMOUNT`, `PF_MAX_AMOUNT`, and triggers `runUpgrades()` on every visit.
- `hookPaymentOptions` hides the payment method entirely if the cart total is below `PF_MIN_AMOUNT`.
- `hookPaymentReturn` / `hookDisplayOrderDetail` both look up the linked request via `pf_request_orders` by `id_order` and render a summary block (with PDF link) on the order-confirmation page and in the customer's order detail view, respectively.
- `sendConfirmationEmail()` generates the `HTMLTemplateCessionSalairePDF` PDF and attaches it to the `pf_confirmation` email only (not `pf_admin_notification`) — PDF generation failures are caught and logged but don't block the emails from sending.

### Frontend JS (`views/js/paiementfacilite.js`)
6-step multi-step form driven by a `PF` state object (`currentStep`, `isCompany`, `isRetired`, `belongsToPartner`, `selectedAddressId`):

1. **Type** — salarié vs retraité vs société. After selecting individual, a retired toggle appears (Yes/No).
2. **Organisme** — dropdown of partner orgs; value `-1` shows a free-text "autre" input; a valid org sets `PF.belongsToPartner = true` and shows a bypass notice (no docs, no interest).
3. **Adresse** — dropdown of existing addresses + AJAX modal to add a new one. Auto-opened if customer has no addresses.
4. **Infos** — personal fields (date_naissance, CIN, fonction) for individuals; company fields (raison_sociale, representant_legal, date_naissance_gerant, telephone_gerant, email_gerant, cin_gerant) for companies.
5. **Crédit** — range slider (step 50), month toggle buttons 2–12 gated by `pf_month_configs` (`minAmount` per month), première tranche input (min = one mensualité, computed with interest), live mensualité display recomputed client-side to mirror the server formula in `PaiementFaciliteMonthConfig`.
6. **Documents** — file pickers shown/hidden per client type (see below). Skipped entirely for partner-org members.

**Partner-org shortcut navigation:** from step 2 → jumps directly to step 5 (skips steps 3 & 4); step 5 shows a submit button instead of "Suivant" (no step 6). On "Précédent" from step 5 → jumps back to step 2.

**Document sets per type** (see `processDocumentUploads()` in `request.php` for the authoritative input-name → doc_type map):
- Salarié: CIN recto/verso + facture STEG + 3× fiche de paie (multi) + RIB + 3× relevé bancaire (multi)
- Retraité: CIN recto/verso + facture STEG + attestation retraite + RIB + 3× relevé bancaire (multi) — no fiche de paie
- Société: copie RNE + CIN gérant recto/verso + RIB + 3× relevé bancaire (multi)

Errors from a failed submission travel via the `pf_errors` cookie (JSON-encoded array), read once by `initContent()`, injected into the template, and cleared immediately (`unset($this->context->cookie->pf_errors)`).

---

## Database Tables

| Table | Purpose |
|---|---|
| `pf_organisations` | Partner organisations (admin-managed), incl. logo/contact fields |
| `pf_requests` | Credit applications; `status` enum drives both order-state mapping and emails |
| `pf_request_orders` | Link between a request and a PS order (`id_order` nullable — standalone requests) |
| `pf_documents` | Uploaded supporting documents |
| `pf_statuses` | Display metadata + order-state mapping for each of the 5 status codes |
| `pf_month_configs` | Per-`nb_mois` minimum credit amount + interest rate |

Schema created by `sql/install.php` (includes seeding `pf_statuses` with the 5 workflow rows via `INSERT IGNORE`); further changes go through `paiementfacilite.php::runUpgrades()`. The SQL drop statements in `sql/uninstall.php` are intentionally **not** invoked from `uninstall()` (the call is commented out) — history is kept even after module removal.

---

## Configuration Keys

| Key | Default | Purpose |
|---|---|---|
| `PF_ADMIN_EMAIL` | `PS_SHOP_EMAIL` | Recipient for admin notification emails |
| `PF_MIN_AMOUNT` | 300 | Minimum credit amount (DT); also hides the payment option below this cart total |
| `PF_MAX_AMOUNT` | 3000 | Maximum credit amount (DT), only enforced for standalone (non-cart) requests |
| `PF_VERSION` | (unset) | Drives `runUpgrades()` idempotent migrations |
| `PF_OS_PENDING` / `PF_OS_APPROVED` / `PF_OS_REJECTED` | set on install | IDs of the module's own `ps_order_state` rows |

---

## Email Templates

Located in `mails/fr/` (txt only) and `mails/en/` (HTML + txt):

| Template | Trigger |
|---|---|
| `pf_confirmation` | Request confirmed into an order/standalone submission (→ customer, PDF attached) |
| `pf_admin_notification` | Same trigger (→ admin, no attachment) |
| `pf_approved` | Either `approved_mode` or `approved_emp` transition (→ customer) |
| `pf_rejected` | Either `rejected_mode` or `rejected_emp` transition (→ customer) |

Template variables include `{firstname}`, `{lastname}`, `{id_request}`, `{amount}`, `{date}`, `{status}`, plus richer ones (`{organisme_row}`, `{fonction_row}`, `{adresse}`, `{interest_rate}`, `{premiere_tranche}`, `{credit_reste}`, `{mensualite}`, `{nb_mois}`) used only by `pf_confirmation` — check `sendConfirmationEmail()` vs `sendStatusEmail()` before adding a variable to a template, since the two email-sending code paths pass different variable sets.

---

## Key Constraints & Non-obvious Behaviour

- **Two-stage approval, not a binary approve/reject:** always check which stage a status belongs to before writing logic against it. `approved_emp`/`rejected_emp` transitions are only valid from `approved_mode`; there's no direct `pending` → `approved_emp` path in the admin controller.
- **Organisation "Autre" (id = -1) vs. real partner org:** the form sends `-1` to signal free-text org (`organisation_autre`), which is validated and documented like any non-partner request. Only `id_organisation > 0` (a real, loaded `PaiementFaciliteOrganisation`) sets `belongs_to_partner = true` and waives documents/interest.
- **Credit amount is order-derived when an order exists:** `processForm()` locks `credit_amount` to `Order::total_paid` whenever `id_order` is present and owned by the customer; it only falls back to a free-form `credit_amount` input for a genuinely standalone request (no order at all) — don't assume the posted `credit_amount` field is authoritative in the checkout path.
- **Interest and minimums come from `pf_month_configs`, frozen at submission:** editing a month config later does not retroactively change `interest_rate`/`mensualite` on existing `pf_requests` rows, mirroring the historical-commission-rate pattern used elsewhere in this module family.
- **Order creation happens up front, not at confirm:** `initContent()` calls `validateOrder()` on the cart immediately (like any other payment module) and redirects to `?id_order=X` before the wizard is even shown; `processForm()` only *links* the already-existing order (`PaiementFaciliteRequest::linkOrder()`) and never creates one for a checkout-originated request. `confirmRequest()` / `validateCartAsOrder()` still create an order from whatever cart is active, but only as the standalone-request fallback reached from the summary page's "Confirmer" button — never for a request that already carries `id_order`. A request can still exist with no linked order at all (genuinely standalone, no cart at confirm time either).
- **Order-state changes are config-driven, not hardcoded:** `applyOrderStateFromStatus()` no-ops silently if `pf_statuses.id_order_state` isn't mapped for that status code — if order states aren't updating after an approval, check the mapping in `AdminPaiementFaciliteStatusController` before assuming the hook/controller logic is broken.
- **Uninstall intentionally preserves data:** the SQL drop in `uninstallSql()` is defined but never called from `uninstall()` — the `$this->uninstallSql();` call is commented out.
