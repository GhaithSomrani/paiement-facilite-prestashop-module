<?php

/**
 * Module: paiementfacilite
 * Paiement par facilité / traite — PrestaShop 1.7/8.x
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once dirname(__FILE__) . '/classes/PaiementFaciliteRequest.php';
require_once dirname(__FILE__) . '/classes/PaiementFaciliteOrganisation.php';
require_once dirname(__FILE__) . '/classes/PaiementFaciliteDocument.php';

class PaiementFacilite extends PaymentModule
{
    public function __construct()
    {
        $this->name = 'paiementfacilite';
        $this->tab = 'payments_gateways';
        $this->version = '1.1.0';
        $this->author = 'Ghaith Somrani';
        $this->need_instance = 1;
        $this->ps_versions_compliancy = array('min' => '1.7', 'max' => '8.0');
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Paiement par facilité / traite');
        $this->description = $this->l('Acceptez les demandes de paiement par facilité ou traite pour vos clients.');
        $this->confirmUninstall = $this->l('Êtes-vous sûr de vouloir désinstaller ce module ?');
    }

    public function install()
    {
        if (!parent::install()) {
            return false;
        }

        if (!$this->installSql()) {
            return false;
        }

        if (!$this->installTab()) {
            return false;
        }

        $hooks = [
            'paymentOptions',
            'paymentReturn',
            'displayCustomerAccount',
            'displayBackOfficeHeader',
        ];

        foreach ($hooks as $hook) {
            if (!$this->registerHook($hook)) {
                return false;
            }
        }


        return true;
    }

    public function uninstall()
    {
        if (!parent::uninstall()) {
            return false;
        }

        // $this->uninstallSql();
        $this->uninstallTab();

        return true;
    }

    private function installSql()
    {
        $sql_file = dirname(__FILE__) . '/sql/install.php';
        if (!file_exists($sql_file)) {
            return false;
        }
        $sql = [];
        require $sql_file;
        foreach ($sql as $query) {
            if (!Db::getInstance()->execute($query)) {
                return false;
            }
        }
        return true;
    }

    private function uninstallSql()
    {
        $sql_file = dirname(__FILE__) . '/sql/uninstall.php';
        if (!file_exists($sql_file)) {
            return true;
        }
        $sql = [];
        require $sql_file;
        foreach ($sql as $query) {
            Db::getInstance()->execute($query);
        }
        return true;
    }

    private function installTab()
    {
        $id_parent_root = (int) Tab::getIdFromClassName('AdminParentPayment');
        if (!$id_parent_root) {
            $id_parent_root = (int) Tab::getIdFromClassName('AdminModules');
        }

        // Parent tab (menu group)
        $parent = new Tab();
        $parent->active     = 1;
        $parent->class_name = 'AdminPaiementFaciliteParent';
        $parent->module     = $this->name;
        $parent->id_parent  = $id_parent_root;
        foreach (Language::getLanguages() as $lang) {
            $parent->name[$lang['id_lang']] = 'Paiement Facilité';
        }
        if (!$parent->add()) {
            return false;
        }

        // Requests tab
        $tab1 = new Tab();
        $tab1->active     = 1;
        $tab1->class_name = 'AdminPaiementFaciliteRequests';
        $tab1->module     = $this->name;
        $tab1->id_parent  = (int) $parent->id;
        foreach (Language::getLanguages() as $lang) {
            $tab1->name[$lang['id_lang']] = 'Demandes de facilité';
        }
        if (!$tab1->add()) {
            return false;
        }

        // Organisations tab
        $tab2 = new Tab();
        $tab2->active     = 1;
        $tab2->class_name = 'AdminPaiementFaciliteOrganisations';
        $tab2->module     = $this->name;
        $tab2->id_parent  = (int) $parent->id;
        foreach (Language::getLanguages() as $lang) {
            $tab2->name[$lang['id_lang']] = 'Organismes partenaires';
        }
        if (!$tab2->add()) {
            return false;
        }

        return true;
    }

    private function uninstallTab()
    {
        foreach (['AdminPaiementFaciliteRequests', 'AdminPaiementFaciliteOrganisations', 'AdminPaiementFaciliteParent'] as $class) {
            $id_tab = (int) Tab::getIdFromClassName($class);
            if ($id_tab) {
                (new Tab($id_tab))->delete();
            }
        }
        return true;
    }



    // -------------------------------------------------------------------------
    // CONFIGURATION PAGE
    // -------------------------------------------------------------------------

    public function getContent()
    {
        $output = '';

        if (Tools::isSubmit('submit_pf_config')) {
            Configuration::updateValue('PF_ADMIN_EMAIL', Tools::getValue('PF_ADMIN_EMAIL'));
            Configuration::updateValue('PF_MIN_AMOUNT', (float) Tools::getValue('PF_MIN_AMOUNT'));
            Configuration::updateValue('PF_MAX_AMOUNT', (float) Tools::getValue('PF_MAX_AMOUNT'));
            $output .= $this->displayConfirmation($this->l('Configuration enregistrée.'));
        }

        return $output . $this->renderConfigForm();
    }

    private function renderConfigForm()
    {
        $fields_form = [
            'form' => [
                'legend' => ['title' => $this->l('Configuration'), 'icon' => 'icon-cogs'],
                'input'  => [
                    [
                        'type'     => 'text',
                        'label'    => $this->l('Email de notification admin'),
                        'name'     => 'PF_ADMIN_EMAIL',
                        'required' => false,
                        'desc'     => $this->l('Email destinataire des nouvelles demandes.'),
                    ],
                    [
                        'type'  => 'text',
                        'label' => $this->l('Montant minimum (DT)'),
                        'name'  => 'PF_MIN_AMOUNT',
                        'class' => 'input-small',
                    ],
                    [
                        'type'  => 'text',
                        'label' => $this->l('Montant maximum (DT)'),
                        'name'  => 'PF_MAX_AMOUNT',
                        'class' => 'input-small',
                    ],
                ],
                'submit' => ['title' => $this->l('Enregistrer')],
            ],
        ];

        $helper = new HelperForm();
        $helper->show_toolbar = false;
        $helper->module = $this;
        $helper->identifier = $this->identifier;
        $helper->submit_action = 'submit_pf_config';
        $helper->currentIndex = AdminController::$currentIndex . '&configure=' . $this->name;
        $helper->token = Tools::getAdminTokenLite('AdminModules');
        $helper->fields_value = [
            'PF_ADMIN_EMAIL' => Configuration::get('PF_ADMIN_EMAIL'),
            'PF_MIN_AMOUNT'  => Configuration::get('PF_MIN_AMOUNT') ?: 300,
            'PF_MAX_AMOUNT'  => Configuration::get('PF_MAX_AMOUNT') ?: 3000,
        ];

        return $helper->generateForm([$fields_form]);
    }

    // -------------------------------------------------------------------------
    // PAYMENT HOOKS
    // -------------------------------------------------------------------------

    public function hookPaymentOptions($params)
    {
        if (!$this->active) {
            return [];
        }

        $option = new PrestaShop\PrestaShop\Core\Payment\PaymentOption();
        $option->setCallToActionText($this->l('Paiement par facilité / traite'));
        $option->setAction($this->context->link->getModuleLink($this->name, 'request', [], true));
        $option->setAdditionalInformation(
            $this->context->smarty->fetch('module:paiementfacilite/views/templates/hook/payment_info.tpl')
        );

        if (file_exists($this->local_path . 'logo.png')) {
            $option->setLogo(Media::getMediaPath($this->local_path . 'logo.png'));
        }

        return [$option];
    }

    public function hookPaymentReturn($params)
    {
        if (!$this->active) {
            return '';
        }

        $order = $params['order'];
        $this->context->smarty->assign([
            'shop_name'  => $this->context->shop->name,
            'id_order'   => $order->id,
            'reference'  => $order->reference,
        ]);

        return $this->fetch('module:paiementfacilite/views/templates/hook/payment_return.tpl');
    }

    public function hookDisplayCustomerAccount($params)
    {
        return $this->fetch('module:paiementfacilite/views/templates/hook/customer_account.tpl');
    }

    public function hookDisplayBackOfficeHeader()
    {
        $controller = Tools::getValue('controller');
        $pfControllers = ['AdminPaiementFaciliteRequests', 'AdminPaiementFaciliteOrganisations'];

        if (
            Tools::getValue('configure') === $this->name
            || Tools::getValue('module_name') === $this->name
            || in_array($controller, $pfControllers)
        ) {
            $this->context->controller->addCSS($this->_path . 'views/css/paiementfacilite.css');
        }
    }

    // -------------------------------------------------------------------------
    // HELPERS
    // -------------------------------------------------------------------------

    public function sendConfirmationEmail($id_request)
    {
        $request = new PaiementFaciliteRequest($id_request);
        if (!Validate::isLoadedObject($request)) {
            return false;
        }

        $customer = new Customer($request->id_customer);
        if (!Validate::isLoadedObject($customer)) {
            return false;
        }

        $templateVars = [
            '{firstname}' => $customer->firstname,
            '{lastname}'  => $customer->lastname,
            '{id_request}' => $request->id,
            '{amount}'    => number_format($request->credit_amount, 2, ',', ' ') . ' DT',
            '{date}'      => date('d/m/Y'),
        ];

        Mail::Send(
            (int) Configuration::get('PS_LANG_DEFAULT'),
            'pf_confirmation',
            $this->l('Votre demande de paiement par facilité a été reçue'),
            $templateVars,
            $customer->email,
            $customer->firstname . ' ' . $customer->lastname,
            null,
            null,
            null,
            null,
            dirname(__FILE__) . '/mails/'
        );

        // Admin notification
        $adminEmail = Configuration::get('PF_ADMIN_EMAIL') ?: Configuration::get('PS_SHOP_EMAIL');
        if ($adminEmail) {
            Mail::Send(
                (int) Configuration::get('PS_LANG_DEFAULT'),
                'pf_admin_notification',
                $this->l('Nouvelle demande de paiement par facilité #') . $request->id,
                $templateVars,
                $adminEmail,
                'Admin',
                null,
                null,
                null,
                null,
                dirname(__FILE__) . '/mails/'
            );
        }

        return true;
    }
}
