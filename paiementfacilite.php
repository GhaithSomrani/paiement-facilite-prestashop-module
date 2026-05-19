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
require_once dirname(__FILE__) . '/classes/PaiementFaciliteStatus.php';
require_once dirname(__FILE__) . '/classes/PaiementFaciliteMonthConfig.php';

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

        if (!$this->installOrderStates()) {
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

    private function installOrderStates()
    {
        $states = [
            'PF_OS_PENDING' => [
                'name'    => 'En attente de validation facilité',
                'color'   => '#FF8C00',
                'paid'    => false,
                'invoice' => false,
                'logable' => false,
                'send_email' => false,
            ],
            'PF_OS_APPROVED' => [
                'name'    => 'Paiement facilité approuvé',
                'color'   => '#28a745',
                'paid'    => true,
                'invoice' => true,
                'logable' => true,
                'send_email' => false,
            ],
            'PF_OS_REJECTED' => [
                'name'    => 'Paiement facilité rejeté',
                'color'   => '#dc3545',
                'paid'    => false,
                'invoice' => false,
                'logable' => false,
                'send_email' => false,
            ],
        ];

        foreach ($states as $key => $data) {
            // Skip if already exists
            if ((int) Configuration::get($key) > 0) {
                continue;
            }

            $os = new OrderState();
            $os->color      = $data['color'];
            $os->paid       = $data['paid'];
            $os->invoice    = $data['invoice'];
            $os->logable    = $data['logable'];
            $os->send_email = $data['send_email'];
            $os->module_name = $this->name;
            foreach (Language::getLanguages() as $lang) {
                $os->name[$lang['id_lang']] = $data['name'];
            }
            if (!$os->add()) {
                return false;
            }
            Configuration::updateValue($key, (int) $os->id);
        }

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

        // Statuses tab
        $tab3 = new Tab();
        $tab3->active     = 1;
        $tab3->class_name = 'AdminPaiementFaciliteStatus';
        $tab3->module     = $this->name;
        $tab3->id_parent  = (int) $parent->id;
        foreach (Language::getLanguages() as $lang) {
            $tab3->name[$lang['id_lang']] = 'Statuts';
        }
        if (!$tab3->add()) {
            return false;
        }

        // Amount ranges tab
        $tab4 = new Tab();
        $tab4->active     = 1;
        $tab4->class_name = 'AdminPaiementFaciliteAmountRanges';
        $tab4->module     = $this->name;
        $tab4->id_parent  = (int) $parent->id;
        foreach (Language::getLanguages() as $lang) {
            $tab4->name[$lang['id_lang']] = 'Config. mensualités';
        }
        if (!$tab4->add()) {
            return false;
        }

        return true;
    }

    private function uninstallTab()
    {
        foreach (['AdminPaiementFaciliteRequests', 'AdminPaiementFaciliteOrganisations', 'AdminPaiementFaciliteStatus', 'AdminPaiementFaciliteAmountRanges', 'AdminPaiementFaciliteParent'] as $class) {
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

    // -------------------------------------------------------------------------
    // UPGRADE / MIGRATION
    // -------------------------------------------------------------------------

    /**
     * Idempotent migrations for existing installations.
     * Called from getContent() so it runs whenever the admin visits config.
     */
    private function runUpgrades()
    {
        $version = (string) Configuration::get('PF_VERSION');

        // 1.1.0 — add interest_rate to requests + admin tab
        if (version_compare($version, '1.1.0', '<')) {
            $cols = Db::getInstance()->executeS(
                'SHOW COLUMNS FROM `' . _DB_PREFIX_ . 'pf_requests` LIKE "interest_rate"'
            );
            if (!$cols) {
                Db::getInstance()->execute(
                    'ALTER TABLE `' . _DB_PREFIX_ . 'pf_requests`
                     ADD COLUMN `interest_rate` decimal(5,2) NOT NULL DEFAULT 0.00 AFTER `nb_mois`'
                );
            }

            if (!Tab::getIdFromClassName('AdminPaiementFaciliteAmountRanges')) {
                $parentId = (int) Tab::getIdFromClassName('AdminPaiementFaciliteParent');
                if ($parentId) {
                    $tab = new Tab();
                    $tab->active     = 1;
                    $tab->class_name = 'AdminPaiementFaciliteAmountRanges';
                    $tab->module     = $this->name;
                    $tab->id_parent  = $parentId;
                    foreach (Language::getLanguages() as $lang) {
                        $tab->name[$lang['id_lang']] = 'Config. mensualités';
                    }
                    $tab->add();
                }
            }

            Configuration::updateValue('PF_VERSION', '1.1.0');
            $version = '1.1.0';
        }

        // 1.2.0 — replace pf_amount_ranges with pf_month_configs
        if (version_compare($version, '1.2.0', '<')) {
            // Drop the old table if it exists
            Db::getInstance()->execute(
                'DROP TABLE IF EXISTS `' . _DB_PREFIX_ . 'pf_amount_ranges`'
            );

            // Create the per-month config table (min amount to unlock + interest rate)
            Db::getInstance()->execute(
                'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_month_configs` (
                    `id_config`     int(10) unsigned NOT NULL AUTO_INCREMENT,
                    `nb_mois`       tinyint(3) unsigned NOT NULL,
                    `min_amount`    decimal(10,2) NOT NULL DEFAULT 0.00,
                    `interest_rate` decimal(5,2)  NOT NULL DEFAULT 0.00,
                    `active`        tinyint(1) unsigned NOT NULL DEFAULT 1,
                    `date_add`      datetime NOT NULL,
                    `date_upd`      datetime NOT NULL,
                    PRIMARY KEY (`id_config`),
                    UNIQUE KEY `nb_mois` (`nb_mois`)
                ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4'
            );

            // Drop max_amount column if it was added by a previous version
            $cols = Db::getInstance()->executeS(
                'SHOW COLUMNS FROM `' . _DB_PREFIX_ . 'pf_month_configs` LIKE "max_amount"'
            );
            if ($cols) {
                Db::getInstance()->execute(
                    'ALTER TABLE `' . _DB_PREFIX_ . 'pf_month_configs` DROP COLUMN `max_amount`'
                );
            }

            // Update the tab label to reflect the new purpose
            $tabId = (int) Tab::getIdFromClassName('AdminPaiementFaciliteAmountRanges');
            if ($tabId) {
                $tab = new Tab($tabId);
                foreach (Language::getLanguages() as $lang) {
                    $tab->name[$lang['id_lang']] = 'Config. mensualités';
                }
                $tab->save();
            }

            Configuration::updateValue('PF_VERSION', '1.2.0');
        }
    }

    public function getContent()
    {
        $this->runUpgrades();

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

        $id_cart = $params['cart']->id;
        $option = new PrestaShop\PrestaShop\Core\Payment\PaymentOption();
        $option->setCallToActionText($this->l('Paiement par facilité / traite'));
        $option->setAction($this->context->link->getModuleLink($this->name, 'request', ['id_cart' => $id_cart], true));


        $option->setAdditionalInformation(
            $this->context->smarty->fetch('module:paiementfacilite/views/templates/hook/payment_info.tpl', [
                'min_amount' => Configuration::get('PF_MIN_AMOUNT') ?: 300,
                'max_amount' => Configuration::get('PF_MAX_AMOUNT') ?: 3000,
            ])
        );

        if (file_exists($this->local_path . 'logo.png')) {
            $option->setLogo(Media::getMediaPath($this->local_path . 'logo.png'));
        }
        $cart = new Cart($id_cart);
        $minprice = Configuration::get('PF_MIN_AMOUNT') ?: 300;
        if ($cart->getOrderTotal(true, Cart::BOTH) < $minprice) {
            return [];
        }
        return [$option];
    }

    public function hookPaymentReturn($params)
    {
        if (!$this->active) {
            return '';
        }

        $order = $params['order'];

        // Load the linked paiementfacilite request for this order
        require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteRequest.php';
        $pf_request = null;
        $row = Db::getInstance()->getRow(
            'SELECT id_request FROM `' . _DB_PREFIX_ . 'pf_request_orders`
             WHERE id_order = ' . (int) $order->id
        );
        if ($row) {
            $candidate = new PaiementFaciliteRequest((int) $row['id_request']);
            if (Validate::isLoadedObject($candidate)) {
                $pf_request = $candidate;
            }
        }

        $pdf_url = '';
        if ($pf_request) {
            $pdf_url = $this->context->link->getModuleLink(
                'paiementfacilite',
                'request',
                ['download_pdf' => 1, 'id_request' => (int) $pf_request->id],
                true
            );
        }

        $admin_email = Configuration::get('PF_ADMIN_EMAIL') ?: Configuration::get('PS_SHOP_EMAIL');

        $this->context->smarty->assign([
            'shop_name'      => $this->context->shop->name,
            'id_order'       => $order->id,
            'reference'      => $order->reference,
            'pf_request'     => $pf_request,
            'pf_pdf_url'     => $pdf_url,
            'pf_admin_email' => $admin_email,
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
        $pfControllers = ['AdminPaiementFaciliteRequests', 'AdminPaiementFaciliteOrganisations', 'AdminPaiementFaciliteStatus', 'AdminPaiementFaciliteAmountRanges'];

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
            '{firstname}'  => $customer->firstname,
            '{lastname}'   => $customer->lastname,
            '{id_request}' => $request->id,
            '{amount}'     => number_format($request->credit_amount, 2, ',', ' ') . ' DT',
            '{date}'       => date('d/m/Y'),
        ];

        // Generate PDF attachment
        $fileAttachment = null;
        try {
            require_once dirname(__FILE__) . '/classes/pdf/HTMLTemplateCessionSalairePDF.php';
            $pdfTemplate    = new HTMLTemplateCessionSalairePDF($request, $this->context->smarty);
            $fileAttachment = [
                'content' => $pdfTemplate->getPdfContent(),
                'name'    => 'cession-salaire-' . (int) $request->id . '.pdf',
                'mime'    => 'application/pdf',
            ];
        } catch (Exception $e) {
            PrestaShopLogger::addLog(
                'PaiementFacilite: PDF generation failed for request #' . $id_request . ' — ' . $e->getMessage(),
                2, null, 'PaiementFaciliteRequest', $id_request
            );
        }

        // Customer confirmation with PDF attached
        Mail::Send(
            (int) Configuration::get('PS_LANG_DEFAULT'),
            'pf_confirmation',
            $this->l('Votre demande de paiement par facilité a été reçue'),
            $templateVars,
            $customer->email,
            $customer->firstname . ' ' . $customer->lastname,
            null,
            null,
            $fileAttachment,
            null,
            dirname(__FILE__) . '/mails/'
        );

        // Admin notification (no attachment needed)
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
