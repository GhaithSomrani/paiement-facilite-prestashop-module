# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Module Identity
**Name:** paiementfacilite
**Version:** 1.0.0
**Type:** PrestaShop PaymentModule (1.7/8.x)
**Purpose:** Installment/bill-of-exchange ("facilité / traite") payment requests for Tunisian e-commerce. Customers submit a credit application; admin reviews and approves/rejects it.

---

## Development Environment

No build step. PHP changes are live after clearing PrestaShop cache:
- **Admin Panel:** Advanced Parameters → Performance → Clear Cache
- **Manual:** Delete contents of `var/cache/` in the PrestaShop root (`C:\Users\E-Market\Desktop\prestashop`)

Module installation/reinstallation from admin: Modules → Module Manager → Search "paiementfacilite".

---

## Architecture

### Request Lifecycle
```
Customer checkout → clicks "Paiement par facilité" → front/request.php (6-step form)
  → uploads documents → PaiementFaciliteRequest saved (status: pending)
  → emails sent (customer confirmation + admin notification)
  → Admin: AdminPaiementFaciliteRequests → approve / reject
  → customer receives pf_approved or pf_rejected email
```

### Entity Classes (`classes/`)

**`PaiementFaciliteRequest`** — table `pf_requests`
- Central entity. Two client paths: individual (`is_company=0`) vs company (`is_company=1`).
- `belongs_to_partner` flag: when set, document uploads are skipped (org handles it externally).
- Status lifecycle: `pending` → `approved` | `rejected` (enforced in `updateStatus()`).
- `linkOrder()` / `getLinkedOrder()` relate a request to a PrestaShop order via `pf_request_orders` (nullable `id_order` — request may be standalone without a prior cart).

**`PaiementFaciliteOrganisation`** — table `pf_organisations`
- Partner organisations selectable by customers. When `id_organisation = -1` in the form, the customer typed a free-text "autre" name instead.

**`PaiementFaciliteDocument`** — table `pf_documents`
- Files stored at `uploads/{id_request}/{doc_type}_{uniqid}.{ext}` inside the module directory.
- `saveUpload()` validates MIME (jpeg/png/pdf), size ≤ 5 MB, and extension before moving.
- Single-upload types: cin_recto, cin_verso, rib, facture_steg, attestation_retraite.
- Multi-upload types (up to 3 each): fiche_paie, releve_bancaire.

### Controllers

**`controllers/front/request.php`** — `PaiementFaciliteRequestModuleFrontController`
- Requires customer login; redirects to auth otherwise.
- Single route handles three states via query params:
  - Default GET → render 6-step form
  - `?ajax=1` → JSON AJAX handler (`saveAddress`, `getAddresses`)
  - `?confirmed=1&id_request=X` → confirmation page (intercepted in `postProcess()`)
- Form submission validated in `processForm()`: address ownership, org validity, credit range, première tranche ≥ 20% of credit, company-specific fields.
- Mensualité calculated as `(credit_amount - premiere_tranche) / 12`.

**`controllers/admin/AdminPaiementFaciliteRequestsController.php`** — `ModuleAdminController`
- List view with custom JOIN to pull customer name, org name, and linked order.
- Single `view` row action → `renderView()` renders `views/templates/admin/requests/request_detail.tpl`.
- Approve/reject available as individual actions and bulk actions.
- `postProcess()` handles `download_doc` to stream uploaded files to admin browser.

### Main Module (`paiementfacilite.php`)
- Registered hooks: `paymentOptions`, `paymentReturn`, `displayCustomerAccount`, `displayBackOfficeHeader`.
- Config page (via `getContent()`) manages three keys: `PF_ADMIN_EMAIL`, `PF_MIN_AMOUNT`, `PF_MAX_AMOUNT`.
- `sendConfirmationEmail()` sends two emails on new request: `pf_confirmation` to customer and `pf_admin_notification` to admin.
- Tab installed under `AdminParentPayment` (fallback: `AdminModules`) as "Demandes de facilité".

### Frontend JS (`views/js/paiement_facilite.js`)
6-step multi-step form driven by a `PF` state object:
1. Client type selection (salarié / retraité / société)
2. Organisation membership
3. Address selection (with AJAX address-add modal)
4. Personal / company details + CIN
5. Credit amount slider + première tranche
6. Document uploads (conditionally shown; skipped for partner-org members)

Errors from a failed submission are stored in the `pf_errors` cookie and displayed on reload.

---

## Database Tables

| Table | Purpose |
|---|---|
| `pf_organisations` | Partner organisations (admin-managed) |
| `pf_requests` | Credit applications |
| `pf_request_orders` | Optional link between a request and a PS order |
| `pf_documents` | Uploaded supporting documents |

Schema created by `sql/install.php`; the SQL drop statements in `sql/uninstall.php` are intentionally commented out in the uninstall flow to preserve data.

---

## Configuration Keys

| Key | Default | Purpose |
|---|---|---|
| `PF_ADMIN_EMAIL` | `PS_SHOP_EMAIL` | Recipient for admin notification emails |
| `PF_MIN_AMOUNT` | 300 | Minimum credit amount (DT) |
| `PF_MAX_AMOUNT` | 3000 | Maximum credit amount (DT) |

---

## Email Templates

Located in `mails/fr/` and `mails/en/` (HTML + TXT pairs):

| Template | Trigger |
|---|---|
| `pf_confirmation` | New request submitted (→ customer) |
| `pf_admin_notification` | New request submitted (→ admin) |
| `pf_approved` | Request approved (→ customer) |
| `pf_rejected` | Request rejected (→ customer) |

Template variables: `{firstname}`, `{lastname}`, `{id_request}`, `{amount}`, `{date}`, `{status}`.

---

## Key Constraints & Non-obvious Behaviour

- **Organisation "Autre" (id = -1):** The form sends `-1` to signal a free-text org; `processForm()` converts this to `id_organisation = null` and captures the text in `organisation_autre`.
- **Document skip for partner members:** When `belongs_to_partner = true`, `processDocumentUploads()` is not called. The partner org is assumed to handle verification offline.
- **Confirmation page re-uses the same controller:** There is no separate `confirmation.php` front controller. The `postProcess()` override detects `?confirmed=1` and calls `initContentConfirmation()`, setting `$this->template_vars_set = true` to prevent `initContent()` from overwriting the template.
- **Uninstall intentionally preserves data:** The SQL drop in `uninstallSql()` is called but the call to `uninstallSql()` in `uninstall()` is commented out — history is kept even after module removal.
