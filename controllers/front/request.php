<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteRequest.php';
require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteOrganisation.php';
require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteDocument.php';

class PaiementFaciliteRequestModuleFrontController extends ModuleFrontController
{
    public $ssl = true;

    public function init()
    {
        parent::init();

        // Require customer login
        if (!$this->context->customer->isLogged()) {
            $back = urlencode($this->context->link->getModuleLink('paiementfacilite', 'request', [], true));
            Tools::redirect('index.php?controller=authentication&back=' . $back);
        }
    }

    public function initContent()
    {
        parent::initContent();

        $this->context->controller->addCSS($this->module->getPathUri() . 'views/css/paiementfacilite.css');
        $this->context->controller->addJS($this->module->getPathUri() . 'views/js/paiementfacilite.js');

        // Handle AJAX sub-actions
        if (Tools::isSubmit('ajax')) {
            $this->handleAjax();
            return;
        }

        // Handle form submission
        if (Tools::isSubmit('submitPFRequest')) {
            $this->processForm();
            return;
        }

        // Detect context
        $id_order = (int) Tools::getValue('id_order');
        $id_cart  = (int) $this->context->cart->id;

        // Addresses
        $id_lang      = (int) $this->context->language->id;
        $id_customer  = (int) $this->context->customer->id;
        $addresses    = $this->context->customer->getAddresses($id_lang);
        $selected_address_id = 0;

        // Pre-select invoice address from the active cart
        if ($id_cart && (int) $this->context->cart->id_address_invoice) {
            $selected_address_id = (int) $this->context->cart->id_address_invoice;
        }

        if (!$selected_address_id && !empty($addresses)) {
            $selected_address_id = (int) $addresses[0]['id_address'];
        }

        // Partner organisations
        $organisations = PaiementFaciliteOrganisation::getActiveOrganisations();

        // Credit limits
        $min_amount = (float) (Configuration::get('PF_MIN_AMOUNT') ?: 300);
        $max_amount = (float) (Configuration::get('PF_MAX_AMOUNT') ?: 3000);

        // Load cart products for checkout context
        $order_items  = [];
        $order_fees   = [];
        $order_amount = 0.0;

        if ($id_cart) {
            $active_cart = $this->context->cart;
            if ($active_cart && $active_cart->id && $active_cart->nbProducts() > 0) {
                foreach ($active_cart->getProducts() as $p) {
                    $order_items[] = [
                        'name'  => $p['name'],
                        'qty'   => (int) $p['quantity'],
                        'unit'  => (float) $p['price_wt'],
                        'total' => (float) ($p['price_wt'] * $p['quantity']),
                    ];
                }
                $order_amount = (float) $active_cart->getOrderTotal(true, Cart::BOTH);

                // Additional fees
                $order_fees = [];
                $shipping = (float) $active_cart->getOrderTotal(true, Cart::ONLY_SHIPPING);
                if ($shipping > 0) {
                    $order_fees[] = ['label' => $this->module->l('Frais de livraison'), 'amount' => $shipping, 'sign' => 1];
                }
                $discount = (float) $active_cart->getOrderTotal(true, Cart::ONLY_DISCOUNTS);
                if ($discount > 0) {
                    $order_fees[] = ['label' => $this->module->l('Remise'), 'amount' => $discount, 'sign' => -1];
                }
                $wrapping = (float) $active_cart->getOrderTotal(true, Cart::ONLY_WRAPPING);
                if ($wrapping > 0) {
                    $order_fees[] = ['label' => $this->module->l('Emballage cadeau'), 'amount' => $wrapping, 'sign' => 1];
                }
            }
        }

        // Pre-fill birthday from customer profile
        $birthday = '';
        if ($this->context->customer->birthday && $this->context->customer->birthday !== '0000-00-00') {
            $birthday = $this->context->customer->birthday;
        }

        // Read and clear the error cookie so JS can display it
        $errors_json = '';
        if (!empty($this->context->cookie->pf_errors)) {
            $errors_json = $this->context->cookie->pf_errors;
            unset($this->context->cookie->pf_errors);
        }

        $this->context->smarty->assign([
            'pf_id_order'             => $id_order,
            'pf_id_cart'              => $id_cart,
            'pf_addresses'            => $addresses,
            'pf_selected_address_id'  => $selected_address_id,
            'pf_organisations'        => $organisations,
            'pf_min_amount'           => $min_amount,
            'pf_max_amount'           => $max_amount,
            'pf_default_amount'       => $order_amount ?: 1150,
            'pf_order_items'          => $order_items,
            'pf_order_fees'           => $order_fees,
            'pf_order_amount'         => $order_amount,
            'pf_birthday'             => $birthday,
            'pf_form_action'          => $this->context->link->getModuleLink('paiementfacilite', 'request', [], true),
            'pf_ajax_url'             => $this->context->link->getModuleLink('paiementfacilite', 'request', ['ajax' => 1], true),
            'pf_is_from_checkout'     => $order_amount > 0,
            'customer_firstname'      => $this->context->customer->firstname,
            'customer_lastname'       => $this->context->customer->lastname,
            'customer_email'          => $this->context->customer->email,
            'pf_errors_json'          => $errors_json,
        ]);

        $this->setTemplate('module:paiementfacilite/views/templates/front/request.tpl');
    }

    // -------------------------------------------------------------------------
    // FORM PROCESSING
    // -------------------------------------------------------------------------

    private function processForm()
    {
        $errors = [];
        $id_customer = (int) $this->context->customer->id;
        $id_lang     = (int) $this->context->language->id;

        // --- Basic fields ---
        $is_company   = (int) (bool) Tools::getValue('is_company');
        $is_retired   = $is_company ? 0 : (int) (bool) Tools::getValue('is_retired');
        $id_address   = (int) Tools::getValue('id_address');
        $id_order     = (int) Tools::getValue('id_order');

        // Validate address belongs to customer
        $customer_addresses = $this->context->customer->getAddresses($id_lang);
        $address_ids        = array_column($customer_addresses, 'id_address');
        if (!in_array($id_address, $address_ids)) {
            // Partner org members skipped steps 3/4 — auto-assign their first address
            if ($belongs_to_partner && !empty($address_ids)) {
                $id_address = (int) $address_ids[0];
            } else {
                $errors[] = $this->module->l('Adresse invalide.');
            }
        }

        // --- Organisation ---
        $id_organisation    = (int) Tools::getValue('id_organisation');
        $organisation_autre = Tools::getValue('organisation_autre');
        $belongs_to_partner = false;

        if ($id_organisation > 0) {
            $org = new PaiementFaciliteOrganisation($id_organisation);
            if (Validate::isLoadedObject($org)) {
                $belongs_to_partner = true;
            } else {
                $id_organisation = 0;
                $errors[] = $this->module->l('Organisme invalide.');
            }
        } elseif ($id_organisation == -1) {
            // "Autre"
            $id_organisation = null;
            if (empty(trim($organisation_autre))) {
                $errors[] = $this->module->l('Veuillez préciser le nom de l\'organisme.');
            }
        } else {
            // "N'appartient à aucun organisme"
            $id_organisation = null;
        }

        // --- Personal info (individuals only, non-partner) ---
        $date_naissance = ($is_company || $belongs_to_partner) ? null : Tools::getValue('date_naissance');
        $fonction       = ($is_company || $belongs_to_partner) ? null : Tools::getValue('fonction');
        $cin            = ($is_company || $belongs_to_partner) ? null : Tools::getValue('cin');

        if (!$is_company && !$belongs_to_partner) {
            if (empty($date_naissance) || !Validate::isDate($date_naissance)) {
                $errors[] = $this->module->l('Date de naissance invalide.');
            }
            if (empty($fonction)) {
                $errors[] = $this->module->l('La fonction est obligatoire.');
            }
            if (empty($cin)) {
                $errors[] = $this->module->l('Le numéro de CIN est obligatoire.');
            }
        }

        // --- Société fields ---
        $raison_sociale        = null;
        $date_naissance_gerant = null;
        $representant_legal    = null;
        $cin_gerant            = null;
        $telephone_gerant      = null;
        $email_gerant          = null;

        if ($is_company && !$belongs_to_partner) {
            $raison_sociale        = Tools::getValue('raison_sociale');
            $representant_legal    = Tools::getValue('representant_legal');
            $date_naissance_gerant = Tools::getValue('date_naissance_gerant');
            $telephone_gerant      = Tools::getValue('telephone_gerant');
            $email_gerant          = Tools::getValue('email_gerant');
            $cin_gerant            = Tools::getValue('cin_gerant');

            if (empty($raison_sociale)) {
                $errors[] = $this->module->l('La raison sociale est obligatoire.');
            }
            if (empty($representant_legal)) {
                $errors[] = $this->module->l('Le représentant légal est obligatoire.');
            }
            if (empty($date_naissance_gerant) || !Validate::isDate($date_naissance_gerant)) {
                $errors[] = $this->module->l('Date de naissance du gérant invalide.');
            }
            if (empty($telephone_gerant)) {
                $errors[] = $this->module->l('Le numéro de téléphone du gérant est obligatoire.');
            }
            if (empty($email_gerant) || !Validate::isEmail($email_gerant)) {
                $errors[] = $this->module->l('Adresse email du gérant invalide.');
            }
            if (empty($cin_gerant)) {
                $errors[] = $this->module->l('Le numéro de CIN du gérant est obligatoire.');
            }
        }

        // --- Credit details ---
        $premiere_tranche = (float) Tools::getValue('premiere_tranche');
        $nb_mois          = (int) Tools::getValue('nb_mois') ?: 12;
        $commentaire      = Tools::getValue('commentaire');

        if ($nb_mois < 2 || $nb_mois > 12) {
            $nb_mois = 6;
        }

        // When initiated from checkout, lock credit_amount to the cart total
        $credit_amount  = 0.0;
        $id_cart_posted = (int) Tools::getValue('id_cart');

        if ($id_cart_posted) {
            $submitted_cart = new Cart($id_cart_posted);
            if (Validate::isLoadedObject($submitted_cart) && (int) $submitted_cart->id_customer === $id_customer) {
                $credit_amount = (float) $submitted_cart->getOrderTotal(true, Cart::BOTH);
            }
        }

        // Standalone request: read and validate freely
        if ($credit_amount <= 0) {
            $credit_amount = (float) Tools::getValue('credit_amount');
            $min_amount    = (float) (Configuration::get('PF_MIN_AMOUNT') ?: 300);
            $max_amount    = (float) (Configuration::get('PF_MAX_AMOUNT') ?: 3000);
            if ($credit_amount < $min_amount || $credit_amount > $max_amount) {
                $errors[] = $this->module->l('Montant du crédit invalide.');
            }
        }

        $min_tranche = round($credit_amount * 0.20, 2);
        if ($premiere_tranche < $min_tranche) {
            $errors[] = $this->module->l('La 1ère tranche doit être au minimum 20% du montant.');
        }

        $mensualite = ($credit_amount > 0 && $premiere_tranche < $credit_amount)
            ? round(($credit_amount - $premiere_tranche) / $nb_mois, 2)
            : 0;

        // --- Documents (only if not partner org) ---
        if (!$belongs_to_partner && !$errors) {
            // We'll save docs after request creation
        }

        if ($errors) {
            $this->redirectWithErrors($errors);
            return;
        }

        // --- Save request ---
        $request = new PaiementFaciliteRequest();
        $request->id_customer           = $id_customer;
        $request->id_address            = $id_address;
        $request->is_company            = $is_company;
        $request->is_retired            = $is_retired;
        $request->belongs_to_partner    = (int) $belongs_to_partner;
        $request->id_organisation       = $id_organisation ?: null;
        $request->organisation_autre    = ($id_organisation === null && !$belongs_to_partner)
            ? pSQL($organisation_autre)
            : null;
        $request->date_naissance        = pSQL($date_naissance);
        $request->fonction              = pSQL($fonction);
        $request->cin                   = pSQL($cin);
        $request->raison_sociale        = $raison_sociale ? pSQL($raison_sociale) : null;
        $request->representant_legal    = $representant_legal ? pSQL($representant_legal) : null;
        $request->date_naissance_gerant = $date_naissance_gerant ? pSQL($date_naissance_gerant) : null;
        $request->telephone_gerant      = $telephone_gerant ? pSQL($telephone_gerant) : null;
        $request->email_gerant          = $email_gerant ? pSQL($email_gerant) : null;
        $request->cin_gerant            = $cin_gerant ? pSQL($cin_gerant) : null;
        $request->credit_amount      = $credit_amount;
        $request->premiere_tranche   = $premiere_tranche;
        $request->mensualite         = $mensualite;
        $request->nb_mois            = $nb_mois;
        $request->commentaire           = pSQL($commentaire);
        $request->status                = 'pending';

        if (!$request->add()) {
            $this->redirectWithErrors([$this->module->l('Une erreur s\'est produite. Veuillez réessayer.')]);
            return;
        }

        // --- Validate order from cart (if coming from checkout) ---
        $cart = $this->context->cart;
        if ($cart && $cart->id && $cart->nbProducts() > 0) {
            $id_order = $this->validateCartAsOrder($request->id, $cart);
        }

        // --- Link order to request ---
        $request->linkOrder($id_order ?: null);

        // --- Process document uploads ---
        if (!$belongs_to_partner) {
            $this->processDocumentUploads($request->id, $is_company, $is_retired);
        }

        // --- Send emails ---
        // $this->module->sendConfirmationEmail($request->id);

        // --- Redirect to confirmation ---
        Tools::redirect(
            $this->context->link->getModuleLink(
                'paiementfacilite',
                'request',
                ['confirmed' => 1, 'id_request' => (int) $request->id],
                true
            )
        );
    }

    /**
     * Call validateOrder() to convert the active cart into a PS order
     * with the "pending" state, and embed the request reference.
     *
     * @return int Created order ID, or 0 on failure.
     */
    private function validateCartAsOrder($id_request, Cart $cart)
    {
        $id_pending_state = (int) Configuration::get('PF_OS_PENDING');
        if (!$id_pending_state) {
            // Fallback to PS "Awaiting bank wire payment" if our state isn't installed
            $id_pending_state = (int) Configuration::get('PS_OS_BANKWIRE');
        }

        $amount  = (float) $cart->getOrderTotal(true, Cart::BOTH);
        $message = $this->module->l('Demande de paiement par facilité #') . $id_request;

        try {
            $this->module->validateOrder(
                (int) $cart->id,
                $id_pending_state,
                $amount,
                $this->module->displayName,
                $message,
                ['transaction_id' => 'PF-' . $id_request],
                null,
                false,
                $this->context->customer->secure_key
            );
            return (int) $this->module->currentOrder;
        } catch (Exception $e) {
            PrestaShopLogger::addLog(
                'PaiementFacilite: validateOrder failed for request #' . $id_request . ' — ' . $e->getMessage(),
                3, null, 'PaiementFaciliteRequest', $id_request
            );
            return 0;
        }
    }

    private function processDocumentUploads($id_request, $is_company, $is_retired)
    {
        if ($is_company) {
            // Company single-file uploads
            // cin_gerant_recto / cin_gerant_verso are saved under the standard cin type constants
            $singles = [
                'copie_rne'        => PaiementFaciliteDocument::TYPE_COPIE_RNE,
                'cin_gerant_recto' => PaiementFaciliteDocument::TYPE_CIN_RECTO,
                'cin_gerant_verso' => PaiementFaciliteDocument::TYPE_CIN_VERSO,
                'rib'              => PaiementFaciliteDocument::TYPE_RIB,
            ];
            foreach ($singles as $input => $type) {
                if (!empty($_FILES[$input]['name']) && $_FILES[$input]['error'] === UPLOAD_ERR_OK) {
                    PaiementFaciliteDocument::saveUpload($id_request, $type, $_FILES[$input]);
                }
            }
            // Company multi-file uploads
            $this->saveMultiUpload($id_request, 'releve_bancaire', PaiementFaciliteDocument::TYPE_RELEVE_BANCAIRE, 3);
        } else {
            // Individual single-file uploads
            $singles = [
                'cin_recto'   => PaiementFaciliteDocument::TYPE_CIN_RECTO,
                'cin_verso'   => PaiementFaciliteDocument::TYPE_CIN_VERSO,
                'rib'         => PaiementFaciliteDocument::TYPE_RIB,
                'facture_steg' => PaiementFaciliteDocument::TYPE_FACTURE_STEG,
            ];
            if ($is_retired) {
                $singles['attestation_retraite'] = PaiementFaciliteDocument::TYPE_ATTESTATION;
            }
            foreach ($singles as $input => $type) {
                if (!empty($_FILES[$input]['name']) && $_FILES[$input]['error'] === UPLOAD_ERR_OK) {
                    PaiementFaciliteDocument::saveUpload($id_request, $type, $_FILES[$input]);
                }
            }
            // Individual multi-file uploads
            $this->saveMultiUpload($id_request, 'releve_bancaire', PaiementFaciliteDocument::TYPE_RELEVE_BANCAIRE, 3);
            if (!$is_retired) {
                $this->saveMultiUpload($id_request, 'fiche_paie', PaiementFaciliteDocument::TYPE_FICHE_PAIE, 3);
            }
        }
    }

    private function saveMultiUpload($id_request, $input_name, $type, $max)
    {
        if (empty($_FILES[$input_name]) || !is_array($_FILES[$input_name]['name'])) {
            return;
        }
        $count = count($_FILES[$input_name]['name']);
        for ($i = 0; $i < min($count, $max); $i++) {
            if ($_FILES[$input_name]['error'][$i] === UPLOAD_ERR_OK) {
                PaiementFaciliteDocument::saveUpload($id_request, $type, [
                    'name'     => $_FILES[$input_name]['name'][$i],
                    'type'     => $_FILES[$input_name]['type'][$i],
                    'tmp_name' => $_FILES[$input_name]['tmp_name'][$i],
                    'error'    => $_FILES[$input_name]['error'][$i],
                    'size'     => $_FILES[$input_name]['size'][$i],
                ]);
            }
        }
    }

    private function redirectWithErrors(array $errors)
    {
        $this->context->cookie->pf_errors = json_encode($errors);
        Tools::redirect($this->context->link->getModuleLink('paiementfacilite', 'request', [], true));
    }

    // -------------------------------------------------------------------------
    // AJAX HANDLERS
    // -------------------------------------------------------------------------

    private function handleAjax()
    {
        $action = Tools::getValue('action');

        switch ($action) {
            case 'saveAddress':
                $this->ajaxSaveAddress();
                break;
            case 'getAddresses':
                $this->ajaxGetAddresses();
                break;
            default:
                $this->ajaxReturn(['success' => false, 'error' => 'Unknown action']);
        }
    }

    private function ajaxSaveAddress()
    {
        $id_customer = (int) $this->context->customer->id;
        $id_lang     = (int) $this->context->language->id;

        $address = new Address();
        $address->id_customer  = $id_customer;
        $address->alias        = pSQL(Tools::getValue('alias', 'Mon adresse'));
        $address->firstname    = pSQL(Tools::getValue('firstname'));
        $address->lastname     = pSQL(Tools::getValue('lastname'));
        $address->address1     = pSQL(Tools::getValue('address1'));
        $address->postcode     = pSQL(Tools::getValue('postcode'));
        $address->city         = pSQL(Tools::getValue('city'));
        $address->phone        = pSQL(Tools::getValue('phone'));
        $address->id_country   = (int) Configuration::get('PS_COUNTRY_DEFAULT');

        // Validate required fields
        if (empty($address->firstname) || empty($address->lastname) ||
            empty($address->address1) || empty($address->city)) {
            $this->ajaxReturn(['success' => false, 'error' => 'Champs obligatoires manquants.']);
            return;
        }

        if (!$address->add()) {
            $this->ajaxReturn(['success' => false, 'error' => 'Impossible de sauvegarder l\'adresse.']);
            return;
        }

        // Return updated address list
        $addresses = $this->context->customer->getAddresses($id_lang);
        $this->ajaxReturn([
            'success'    => true,
            'id_address' => (int) $address->id,
            'addresses'  => $addresses,
        ]);
    }

    private function ajaxGetAddresses()
    {
        $id_lang   = (int) $this->context->language->id;
        $addresses = $this->context->customer->getAddresses($id_lang);
        $this->ajaxReturn(['success' => true, 'addresses' => $addresses]);
    }

    private function ajaxReturn(array $data)
    {
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    // -------------------------------------------------------------------------
    // CONFIRMATION PAGE
    // -------------------------------------------------------------------------

    public function initContentConfirmation()
    {
        $id_request = (int) Tools::getValue('id_request');
        $request    = new PaiementFaciliteRequest($id_request);

        if (!Validate::isLoadedObject($request) || (int) $request->id_customer !== (int) $this->context->customer->id) {
            Tools::redirect($this->context->link->getPageLink('index'));
        }

        $linked = $request->getLinkedOrder();

        $this->context->smarty->assign([
            'pf_request'   => $request,
            'pf_id_order'  => $linked ? (int) $linked['id_order'] : 0,
            'pf_order_url' => $linked
                ? $this->context->link->getPageLink('order-detail', true, null, ['id_order' => (int) $linked['id_order']])
                : '',
        ]);

        $this->setTemplate('module:paiementfacilite/views/templates/front/confirmation.tpl');
    }

    public function setMedia()
    {
        parent::setMedia();
        $this->addCSS($this->module->getPathUri() . 'views/css/paiementfacilite.css');
        $this->addJS($this->module->getPathUri() . 'views/js/paiementfacilite.js');
    }

    /**
     * Override to handle confirmed state from the same controller.
     */
    public function postProcess()
    {
        if (Tools::getValue('confirmed') && Tools::getValue('id_request')) {
            $this->initContentConfirmation();
            // Prevent default initContent from running
            $this->template_vars_set = true;
        }
    }
}
