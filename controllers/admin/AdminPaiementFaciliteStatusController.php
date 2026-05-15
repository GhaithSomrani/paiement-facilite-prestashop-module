<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteStatus.php';

class AdminPaiementFaciliteStatusController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap        = true;
        $this->table            = 'pf_statuses';
        $this->className        = 'PaiementFaciliteStatus';
        $this->identifier       = 'id_pf_status';
        $this->lang             = false;
        $this->_defaultOrderBy  = 'sort_order';
        $this->_defaultOrderWay = 'ASC';
        $this->allow_export     = false;

        parent::__construct();

        $this->module = Module::getInstanceByName('paiementfacilite');

        $this->fields_list = [
            'id_pf_status' => [
                'title' => $this->l('ID'),
                'class' => 'fixed-width-xs',
                'align' => 'center',
            ],
            'color' => [
                'title'    => $this->l('Statut'),
                'callback' => 'renderStatusBadge',
                'orderby'  => false,
                'search'   => false,
            ],
            'code' => [
                'title' => $this->l('Code interne'),
                'class' => 'fixed-width-lg',
            ],
            'order_state_name' => [
                'title'  => $this->l('État commande lié'),
                'orderby'=> false,
                'search' => false,
            ],
            'sort_order' => [
                'title' => $this->l('Ordre'),
                'class' => 'fixed-width-xs',
                'align' => 'center',
            ],
        ];

        $this->addRowAction('edit');
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
        $this->_select = '
            a.id_pf_status, a.code, a.name, a.color, a.sort_order,
            IFNULL(osl.name, \'—\') AS order_state_name
        ';

        $this->_join = '
            LEFT JOIN `' . _DB_PREFIX_ . 'order_state_lang` osl
                ON (osl.id_order_state = a.id_order_state
                    AND osl.id_lang = ' . (int) $id_lang . ')
        ';

        parent::getList($id_lang, $order_by, $order_way, $start, $limit, $id_lang_shop);
    }

    public function renderStatusBadge($value, $row)
    {
        $color = htmlspecialchars($row['color'] ?? '#888888');
        $name  = htmlspecialchars($row['name']  ?? '');
        return '<span style="display:inline-block;padding:3px 12px;border-radius:3px;'
            . 'background:' . $color . ';color:#fff;font-weight:700;font-size:12px;">'
            . $name . '</span>';
    }

    // -------------------------------------------------------------------------
    // FORM
    // -------------------------------------------------------------------------

    public function renderForm()
    {
        $id_lang = (int) $this->context->language->id;

        $orderStates = Db::getInstance()->executeS(
            'SELECT os.id_order_state, IFNULL(osl.name, os.id_order_state) AS name
             FROM `' . _DB_PREFIX_ . 'order_state` os
             LEFT JOIN `' . _DB_PREFIX_ . 'order_state_lang` osl
                ON (osl.id_order_state = os.id_order_state AND osl.id_lang = ' . $id_lang . ')
             WHERE os.deleted = 0
             ORDER BY osl.name ASC'
        );

        $osOptions = [
            ['id_order_state' => 0, 'name' => '— ' . $this->l('Aucun (pas de mise à jour automatique)') . ' —'],
        ];
        foreach ($orderStates as $os) {
            $osOptions[] = [
                'id_order_state' => (int) $os['id_order_state'],
                'name'           => $os['name'],
            ];
        }

        $this->fields_form = [
            'legend' => [
                'title' => $this->l('Statut de demande de facilité'),
                'icon'  => 'icon-flag',
            ],
            'input' => [
                [
                    'type'     => 'text',
                    'label'    => $this->l('Nom affiché'),
                    'name'     => 'name',
                    'required' => true,
                    'hint'     => $this->l('Libellé visible dans l\'interface admin.'),
                    'class'    => 'fixed-width-xxl',
                ],
                [
                    'type'     => 'text',
                    'label'    => $this->l('Code interne'),
                    'name'     => 'code',
                    'class'    => 'fixed-width-lg',
                    'hint'     => $this->l('Code système (ex: pending, approved_mode). Modification déconseillée.'),
                ],
                [
                    'type'  => 'color',
                    'label' => $this->l('Couleur du badge'),
                    'name'  => 'color',
                    'hint'  => $this->l('Couleur hexadécimale du badge (ex: #28a745).'),
                ],
                [
                    'type'    => 'select',
                    'label'   => $this->l('État commande PrestaShop'),
                    'name'    => 'id_order_state',
                    'options' => [
                        'query' => $osOptions,
                        'id'    => 'id_order_state',
                        'name'  => 'name',
                    ],
                    'hint' => $this->l(
                        'Quand ce statut est appliqué à une demande, la commande liée passera dans cet état PS.'
                    ),
                ],
                [
                    'type'  => 'text',
                    'label' => $this->l('Ordre d\'affichage'),
                    'name'  => 'sort_order',
                    'class' => 'fixed-width-xs',
                ],
            ],
            'submit' => ['title' => $this->l('Enregistrer')],
        ];

        return parent::renderForm();
    }

    // -------------------------------------------------------------------------
    // SAVE — preserve code to avoid breaking workflow
    // -------------------------------------------------------------------------

    public function processSave()
    {
        // If editing an existing status, do not allow changing the code
        $id = (int) Tools::getValue($this->identifier);
        if ($id) {
            $existing = new PaiementFaciliteStatus($id);
            if (Validate::isLoadedObject($existing)) {
                $_POST['code'] = $existing->code;
            }
        }

        // Ensure id_order_state is null (not 0) when unset, to satisfy ObjectModel INT validation
        $id_os = (int) Tools::getValue('id_order_state');
        if (!$id_os) {
            $_POST['id_order_state'] = null;
        }

        return parent::processSave();
    }
}
