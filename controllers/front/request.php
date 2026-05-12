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

        // Detect context: coming from checkout or standalone
        $id_order = (int) Tools::getValue('id_order');
        $id_cart  = (int) $this->context->cart->id;

        // Try to derive order from active cart if coming from payment step
        if (!$id_order && $id_cart) {
            $order_id_from_cart = Order::getIdByCartId($id_cart);
            if ($order_id_from_cart) {
                $id_order = (int) $order_id_from_cart;
            }
        }

        // Addresses
        $id_lang      = (int) $this->context->language->id;
        $id_customer  = (int) $this->context->customer->id;
        $addresses    = $this->context->customer->getAddresses($id_lang);
        $selected_address_id = 0;

        if ($id_order) {
            $order = new Order($id_order);
            if (Validate::isLoadedObject($order) && (int) $order->id_customer === $id_customer) {
                $selected_address_id = (int) $order->id_address_invoice;
            }
        }

        if (!$selected_address_id && !empty($addresses)) {
            $selected_address_id = (int) $addresses[0]['id_address'];
        }

        // Partner organisations
        $organisations = PaiementFaciliteOrganisation::getActiveOrganisations();

        // Credit limits
        $min_amount = (float) (Configuration::get('PF_MIN_AMOUNT') ?: 300);
        $max_amount = (float) (Configuration::get('PF_MAX_AMOUNT') ?: 3000);

        // Pre-fill birthday from customer profile
        $birthday = '';
        if ($this->context->customer->birthday && $this->context->customer->birthday !== '0000-00-00') {
            $birthday = $this->context->customer->birthday;
        }

        $this->context->smarty->assign([
            'pf_id_order'             => $id_order,
            'pf_id_cart'              => $id_cart,
            'pf_addresses'            => $addresses,
            'pf_selected_address_id'  => $selected_address_id,
            'pf_organisations'        => $organisations,
            'pf_min_amount'           => $min_amount,
            'pf_max_amount'           => $max_amount,
            'pf_default_amount'       => 1150,
            'pf_birthday'             => $birthday,
            'pf_form_action'          => $this->context->link->getModuleLink('paiementfacilite', 'request', [], true),
            'pf_ajax_url'             => $this->context->link->getModuleLink('paiementfacilite', 'request', ['ajax' => 1], true),
            'pf_is_from_checkout'     => (bool) $id_order,
            'customer_firstname'      => $this->context->customer->firstname,
            'customer_lastname'       => $this->context->customer->lastname,
            'customer_email'          => $this->context->customer->email,
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
        $address_ids = array_column($customer_addresses, 'id_address');
        if (!in_array($id_address, $address_ids)) {
            $errors[] = $this->module->l('Adresse invalide.');
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

        // --- Personal info ---
        $date_naissance = Tools::getValue('date_naissance');
        $fonction       = Tools::getValue('fonction');
        $cin            = Tools::getValue('cin');

        if (empty($date_naissance) || !Validate::isDate($date_naissance)) {
            $errors[] = $this->module->l('Date de naissance invalide.');
        }
        if (empty($fonction)) {
            $errors[] = $this->module->l('La fonction est obligatoire.');
        }
        if (empty($cin)) {
            $errors[] = $this->module->l('Le numéro de CIN est obligatoire.');
        }

        // --- Société fields ---
        $raison_sociale        = null;
        $matricule_fiscal      = null;
        $date_naissance_gerant = null;
        $representant_legal    = null;
        $cin_gerant            = null;

        if ($is_company) {
            $raison_sociale        = Tools::getValue('raison_sociale');
            $matricule_fiscal      = Tools::getValue('matricule_fiscal');
            $date_naissance_gerant = Tools::getValue('date_naissance_gerant');
            $representant_legal    = Tools::getValue('representant_legal');
            $cin_gerant            = Tools::getValue('cin_gerant');

            if (empty($raison_sociale)) {
                $errors[] = $this->module->l('La raison sociale est obligatoire.');
            }
            if (empty($matricule_fiscal)) {
                $errors[] = $this->module->l('Le matricule fiscal est obligatoire.');
            }
            if (empty($date_naissance_gerant) || !Validate::isDate($date_naissance_gerant)) {
                $errors[] = $this->module->l('Date de naissance du gérant invalide.');
            }
            if (empty($representant_legal)) {
                $errors[] = $this->module->l('Le représentant légal est obligatoire.');
            }
            if (empty($cin_gerant)) {
                $errors[] = $this->module->l('Le CIN du gérant est obligatoire.');
            }
        }

        // --- Credit details ---
        $credit_amount    = (float) Tools::getValue('credit_amount');
        $premiere_tranche = (float) Tools::getValue('premiere_tranche');
        $commentaire      = Tools::getValue('commentaire');

        $min_amount = (float) (Configuration::get('PF_MIN_AMOUNT') ?: 300);
        $max_amount = (float) (Configuration::get('PF_MAX_AMOUNT') ?: 3000);

        if ($credit_amount < $min_amount || $credit_amount > $max_amount) {
            $errors[] = $this->module->l('Montant du crédit invalide.');
        }

        $min_tranche = round($credit_amount * 0.20, 2);
        if ($premiere_tranche < $min_tranche) {
            $errors[] = $this->module->l('La 1ère tranche doit être au minimum 20% du montant.');
        }

        $mensualite = ($credit_amount > 0 && $premiere_tranche < $credit_amount)
            ? round(($credit_amount - $premiere_tranche) / 12, 2)
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
        $request->matricule_fiscal      = $matricule_fiscal ? pSQL($matricule_fiscal) : null;
        $request->date_naissance_gerant = $date_naissance_gerant ? pSQL($date_naissance_gerant) : null;
        $request->representant_legal    = $representant_legal ? pSQL($representant_legal) : null;
        $request->cin_gerant            = $cin_gerant ? pSQL($cin_gerant) : null;
        $request->credit_amount         = $credit_amount;
        $request->premiere_tranche      = $premiere_tranche;
        $request->mensualite            = $mensualite;
        $request->commentaire           = pSQL($commentaire);
        $request->status                = 'pending';

        if (!$request->add()) {
            $this->redirectWithErrors([$this->module->l('Une erreur s\'est produite. Veuillez réessayer.')]);
            return;
        }

        // --- Link order ---
        $request->linkOrder($id_order ?: null);

        // --- Process document uploads ---
        if (!$belongs_to_partner) {
            $this->processDocumentUploads($request->id);
        }

        // --- Send emails ---
        $this->module->sendConfirmationEmail($request->id);

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

    private function processDocumentUploads($id_request)
    {
        $doc_types_single = [
            PaiementFaciliteDocument::TYPE_CIN_RECTO,
            PaiementFaciliteDocument::TYPE_CIN_VERSO,
            PaiementFaciliteDocument::TYPE_RIB,
            PaiementFaciliteDocument::TYPE_FACTURE_STEG,
            PaiementFaciliteDocument::TYPE_ATTESTATION,
        ];
        $doc_types_multi = [
            PaiementFaciliteDocument::TYPE_FICHE_PAIE,
            PaiementFaciliteDocument::TYPE_RELEVE_BANCAIRE,
        ];

        foreach ($doc_types_single as $type) {
            if (!empty($_FILES[$type]['name']) && $_FILES[$type]['error'] === UPLOAD_ERR_OK) {
                PaiementFaciliteDocument::saveUpload($id_request, $type, $_FILES[$type]);
            }
        }

        foreach ($doc_types_multi as $type) {
            if (!empty($_FILES[$type]) && is_array($_FILES[$type]['name'])) {
                $count = count($_FILES[$type]['name']);
                $max   = ($type === PaiementFaciliteDocument::TYPE_FICHE_PAIE) ? 3 : 3;
                for ($i = 0; $i < min($count, $max); $i++) {
                    if ($_FILES[$type]['error'][$i] === UPLOAD_ERR_OK) {
                        $single = [
                            'name'     => $_FILES[$type]['name'][$i],
                            'type'     => $_FILES[$type]['type'][$i],
                            'tmp_name' => $_FILES[$type]['tmp_name'][$i],
                            'error'    => $_FILES[$type]['error'][$i],
                            'size'     => $_FILES[$type]['size'][$i],
                        ];
                        PaiementFaciliteDocument::saveUpload($id_request, $type, $single);
                    }
                }
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
