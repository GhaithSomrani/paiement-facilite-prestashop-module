<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteSupplierSetting.php';
require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteMonthConfig.php';

/**
 * Standard ObjectModel CRUD on `pf_supplier_settings`: one row = one supplier
 * allowed to show "Paiement par facilité", with its own max-months cap for the
 * product page. The "add/edit" supplier dropdown excludes suppliers that
 * already have a row (the unique key on id_supplier would refuse it anyway;
 * filtering it out of the dropdown just stops the failed-submit round-trip).
 */
class AdminPaiementFaciliteProductSettingsController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap        = true;
        $this->table            = 'pf_supplier_settings';
        $this->className        = 'PaiementFaciliteSupplierSetting';
        $this->identifier       = 'id_supplier_setting';
        $this->lang             = false;
        $this->allow_export     = false;

        parent::__construct();

        $this->module = Module::getInstanceByName('paiementfacilite');

        $this->fields_list = [
            'id_supplier_setting' => [
                'title' => $this->l('ID'),
                'class' => 'fixed-width-xs',
                'align' => 'center',
            ],
            'supplier_name' => [
                'title'   => $this->l('Fournisseur'),
                'orderby' => false,
                'search'  => false,
            ],
            'max_months' => [
                'title' => $this->l('Mois max sur la fiche produit'),
                'class' => 'fixed-width-lg',
                'align' => 'center',
            ],
        ];

        $this->addRowAction('edit');
        $this->addRowAction('delete');
    }

    // -------------------------------------------------------------------------
    // LIST
    // -------------------------------------------------------------------------

    public function getList(
        $id_lang,
        $order_by = null,
        $order_way = null,
        $start = 0,
        $limit = null,
        $id_lang_shop = false
    ) {
        $this->_select = 'a.id_supplier_setting, a.id_supplier, a.max_months, s.name AS supplier_name';
        $this->_join = 'LEFT JOIN `' . _DB_PREFIX_ . 'supplier` s ON s.id_supplier = a.id_supplier';

        parent::getList($id_lang, $order_by, $order_way, $start, $limit, $id_lang_shop);
    }

    // -------------------------------------------------------------------------
    // FORM — custom template: type-ahead supplier search (same pattern as
    // AdminPaiementFaciliteRequestsController's customer search), not a
    // dropdown, since the supplier list can be long.
    // -------------------------------------------------------------------------

    public function renderForm()
    {
        /** @var PaiementFaciliteSupplierSetting $obj */
        $obj = $this->loadObject(true);
        $is_add = !Validate::isLoadedObject($obj);

        $supplierName = '';
        if (!$is_add && $obj->id_supplier) {
            $supplier = new Supplier((int) $obj->id_supplier);
            if (Validate::isLoadedObject($supplier)) {
                $supplierName = $supplier->name;
            }
        }

        $monthOptions = [0 => $this->l('Illimité (toutes les mensualités configurées)')];
        foreach (array_keys((array) PaiementFaciliteMonthConfig::getAllConfigsForJs()) as $nbMois) {
            $monthOptions[(int) $nbMois] = (int) $nbMois . ' ' . $this->l('mois');
        }

        $this->context->smarty->assign([
            'pf_obj'           => $obj,
            'pf_is_add'        => $is_add,
            'pf_supplier_name' => $supplierName,
            'pf_month_options' => $monthOptions,
            'pf_form_action'   => $this->context->link->getAdminLink('AdminPaiementFaciliteProductSettings'),
            'pf_ajax_url'      => $this->context->link->getAdminLink('AdminPaiementFaciliteProductSettings'),
        ]);

        return $this->context->smarty->fetch(
            _PS_MODULE_DIR_ . 'paiementfacilite/views/templates/admin/product_settings_form.tpl'
        );
    }

    // -------------------------------------------------------------------------
    // AJAX — supplier type-ahead (min 2 chars), same contract as
    // AdminPaiementFaciliteRequestsController::ajaxProcessSearchCustomers()
    // -------------------------------------------------------------------------

    public function ajaxProcessSearchSuppliers()
    {
        $q = trim(Tools::getValue('q', ''));
        if (Tools::strlen($q) < 2) {
            die(json_encode([]));
        }

        $currentSupplierId = 0;
        $id = (int) Tools::getValue('id_supplier_setting');
        if ($id) {
            $existing = new PaiementFaciliteSupplierSetting($id);
            if (Validate::isLoadedObject($existing)) {
                $currentSupplierId = (int) $existing->id_supplier;
            }
        }
        $used = array_diff(array_keys(PaiementFaciliteSupplierSetting::getAll()), [$currentSupplierId]);

        $like = '%' . pSQL($q) . '%';
        $rows = Db::getInstance()->executeS(
            'SELECT id_supplier, name FROM `' . _DB_PREFIX_ . 'supplier`
             WHERE active = 1 AND name LIKE \'' . $like . '\'
             ORDER BY name ASC
             LIMIT 20'
        );

        $out = [];
        foreach ($rows as $r) {
            if (in_array((int) $r['id_supplier'], $used, true)) {
                continue;
            }
            $out[] = ['id' => (int) $r['id_supplier'], 'label' => $r['name']];
        }

        die(json_encode($out));
    }
}
