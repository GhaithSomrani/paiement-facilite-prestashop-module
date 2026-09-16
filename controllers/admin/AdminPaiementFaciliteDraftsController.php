<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteOrganisation.php';

/**
 * Read-only monitor for abandoned multi-step form drafts (pf_drafts).
 * No ObjectModel/add-edit form — this is a list + a raw-field detail view.
 */
class AdminPaiementFaciliteDraftsController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap  = true;
        $this->table      = 'pf_drafts';
        $this->identifier = 'id_customer';
        $this->lang       = false;
        $this->list_no_link = true;
        $this->_defaultOrderBy  = 'date_upd';
        $this->_defaultOrderWay = 'DESC';

        parent::__construct();

        $this->module = Module::getInstanceByName('paiementfacilite');

        $this->fields_list = [
            'id_customer' => [
                'title' => $this->l('ID client'),
                'class' => 'fixed-width-xs',
                'align' => 'center',
            ],
            'customer_name' => [
                'title'      => $this->l('Client'),
                'filter_key' => 'c!lastname',
            ],
            'customer_email' => [
                'title'      => $this->l('Email'),
                'filter_key' => 'c!email',
            ],
            'step' => [
                'title'    => $this->l('Étape atteinte'),
                'callback' => 'renderStep',
                'align'    => 'center',
                'orderby'  => true,
            ],
            'date_upd' => [
                'title'      => $this->l('Dernière activité'),
                'type'       => 'datetime',
                'filter_key' => 'a!date_upd',
            ],
        ];

        $this->addRowAction('view');
        $this->addRowAction('delete');
    }

    public function initToolbar()
    {
        parent::initToolbar();
        // No add-new form exists for this read-only list
        unset($this->toolbar_btn['new']);
    }

    public function getList($id_lang, $order_by = null, $order_way = null, $start = 0, $limit = null, $id_lang_shop = false)
    {
        $this->_select = '
            CONCAT(c.firstname, " ", c.lastname) AS customer_name,
            c.email AS customer_email
        ';

        $this->_join = '
            LEFT JOIN `' . _DB_PREFIX_ . 'customer` c ON (c.id_customer = a.id_customer)
        ';

        parent::getList($id_lang, $order_by, $order_way, $start, $limit, $id_lang_shop);
    }

    public function renderStep($value, $row)
    {
        return (int) $value . ' / 6';
    }

    public function renderView()
    {
        $id_customer = (int) Tools::getValue('id_customer');
        $row = Db::getInstance()->getRow(
            'SELECT d.*, CONCAT(c.firstname, " ", c.lastname) AS customer_name, c.email AS customer_email
             FROM `' . _DB_PREFIX_ . 'pf_drafts` d
             LEFT JOIN `' . _DB_PREFIX_ . 'customer` c ON (c.id_customer = d.id_customer)
             WHERE d.id_customer = ' . $id_customer
        );

        if (!$row) {
            $this->errors[] = $this->l('Brouillon introuvable.');
            return parent::renderList();
        }

        $data = json_decode($row['data'], true);
        if (!is_array($data)) {
            $data = [];
        }

        // Organisation (partner id, "autre" free text, or none)
        $id_org = isset($data['id_organisation']) ? (int) $data['id_organisation'] : 0;
        if ($id_org > 0) {
            $org = new PaiementFaciliteOrganisation($id_org);
            $organisation = Validate::isLoadedObject($org) ? $org->name : ('#' . $id_org);
        } elseif (!empty($data['organisation_autre'])) {
            $organisation = $data['organisation_autre'] . ' (' . $this->l('autre') . ')';
        } else {
            $organisation = $this->l('Aucun');
        }

        // Address label
        $id_address = isset($data['id_address']) ? (int) $data['id_address'] : 0;
        $address_label = '—';
        if ($id_address > 0) {
            $address = new Address($id_address);
            if (Validate::isLoadedObject($address)) {
                $address_label = $address->address1 . ($address->city ? ', ' . $address->city : '');
            }
        }

        $is_company = !empty($data['is_company']) && $data['is_company'] == 1;
        $get = function ($key) use ($data) {
            return isset($data[$key]) && $data[$key] !== '' ? $data[$key] : '—';
        };

        $fields = [
            $this->l('Type de client')       => $is_company ? $this->l('Société') : (!empty($data['is_retired']) && $data['is_retired'] == 1 ? $this->l('Retraité') : $this->l('Salarié')),
            $this->l('Organisme')            => $organisation,
            $this->l('Adresse')              => $address_label,
        ];

        if ($is_company) {
            $fields[$this->l('Raison sociale')]        = $get('raison_sociale');
            $fields[$this->l('Représentant légal')]    = $get('representant_legal');
            $fields[$this->l('Date de naissance gérant')] = $get('date_naissance_gerant');
            $fields[$this->l('Téléphone gérant')]      = $get('telephone_gerant');
            $fields[$this->l('Email gérant')]          = $get('email_gerant');
            $fields[$this->l('CIN gérant')]             = $get('cin_gerant');
        } else {
            $fields[$this->l('Date de naissance')] = $get('date_naissance');
            $fields[$this->l('CIN')]               = $get('cin');
            $fields[$this->l('Fonction')]          = $get('fonction');
        }

        $fields[$this->l('Montant du crédit (DT)')]  = $get('credit_amount');
        $fields[$this->l('1ère tranche (DT)')]        = $get('premiere_tranche');
        $fields[$this->l('Nombre de mensualités')]   = $get('nb_mois');
        $fields[$this->l('Mensualité (DT)')]          = $get('mensualite');
        $fields[$this->l('Commentaire')]              = $get('commentaire');

        $html = '<div class="panel">';
        $html .= '<div class="panel-heading">'
            . htmlspecialchars($row['customer_name']) . ' (' . htmlspecialchars($row['customer_email']) . ')'
            . ' &mdash; ' . $this->l('Étape') . ' ' . (int) $row['step'] . ' / 6'
            . '</div>';
        $html .= '<table class="table">';
        foreach ($fields as $label => $value) {
            $html .= '<tr><td style="width:280px;font-weight:600;">' . htmlspecialchars($label) . '</td>'
                . '<td>' . nl2br(htmlspecialchars((string) $value)) . '</td></tr>';
        }
        $html .= '</table>';
        $html .= '<div class="panel-footer">'
            . '<a class="btn btn-default" href="' . $this->context->link->getAdminLink('AdminPaiementFaciliteDrafts') . '">'
            . '<i class="icon-arrow-left"></i> ' . $this->l('Retour à la liste') . '</a>'
            . '</div>';
        $html .= '</div>';

        return $html;
    }

    public function processDelete()
    {
        $id_customer = (int) Tools::getValue('id_customer');
        if ($id_customer) {
            Db::getInstance()->delete('pf_drafts', 'id_customer = ' . $id_customer);
            $this->confirmations[] = $this->l('Brouillon supprimé.');
        }
        Tools::redirectAdmin(self::$currentIndex . '&token=' . $this->token);
    }
}
