<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteRequest.php';
require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteOrganisation.php';
require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteDocument.php';

class AdminPaiementFaciliteRequestsController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap  = true;
        $this->table      = 'pf_requests';
        $this->className  = 'PaiementFaciliteRequest';
        $this->identifier = 'id_request';
        $this->lang       = false;
        $this->allow_export = true;
        $this->_defaultOrderBy  = 'id_request';
        $this->_defaultOrderWay = 'DESC';

        parent::__construct();

        $this->module = Module::getInstanceByName('paiementfacilite');

        $this->fields_list = [
            'id_request' => [
                'title' => $this->l('ID'),
                'class' => 'fixed-width-xs',
                'align' => 'center',
            ],
            'customer_name' => [
                'title'      => $this->l('Client'),
                'filter_key' => 'c!lastname',
            ],
            'is_company' => [
                'title'    => $this->l('Type client'),
                'callback' => 'renderClientType',
                'filter_key' => 'a!is_company',
                'align'    => 'center',
            ],
            'organisation_name' => [
                'title'    => $this->l('Organisme'),
                'callback' => 'renderOrganisation',
            ],
            'credit_amount' => [
                'title'    => $this->l('Montant (DT)'),
                'type'     => 'price',
                'align'    => 'right',
                'filter_key' => 'a!credit_amount',
            ],
            'linked_order_id' => [
                'title'    => $this->l('Commande'),
                'callback' => 'renderOrderLink',
                'orderby'  => false,
                'filter'   => false,
            ],
            'status' => [
                'title'         => $this->l('Statut'),
                'type'          => 'select',
                'list'          => [
                    'pending'  => $this->l('En attente'),
                    'approved' => $this->l('Approuvé'),
                    'rejected' => $this->l('Rejeté'),
                ],
                'badge_success' => ['approved'],
                'badge_warning' => ['pending'],
                'badge_danger'  => ['rejected'],
                'filter_key'    => 'a!status',
            ],

            'date_add' => [
                'title'      => $this->l('Date'),
                'type'       => 'datetime',
                'filter_key' => 'a!date_add',
            ],
        ];

        $this->bulk_actions = [
            'approve' => [
                'text'    => $this->l('Approuver'),
                'confirm' => $this->l('Approuver les demandes sélectionnées ?'),
            ],
            'reject' => [
                'text'    => $this->l('Rejeter'),
                'confirm' => $this->l('Rejeter les demandes sélectionnées ?'),
            ],
        ];

        $this->addRowAction('view');
        $this->addRowAction('edit');
    }

    // -------------------------------------------------------------------------
    // JOINS for list
    // -------------------------------------------------------------------------

    public function getList($id_lang, $order_by = null, $order_way = null, $start = 0, $limit = null, $id_lang_shop = false)
    {
        $this->_select = '
            CONCAT(c.firstname, " ", c.lastname) AS customer_name,
            a.is_company,
            a.id_organisation,
            o.name AS organisation_name,
            a.organisation_autre,
            a.belongs_to_partner,
            ro.id_order AS linked_order_id
        ';

        $this->_join = '
            LEFT JOIN `' . _DB_PREFIX_ . 'customer` c ON (c.id_customer = a.id_customer)
            LEFT JOIN `' . _DB_PREFIX_ . 'pf_organisations` o ON (o.id_organisation = a.id_organisation)
            LEFT JOIN `' . _DB_PREFIX_ . 'pf_request_orders` ro ON (ro.id_request = a.id_request)
        ';

        parent::getList($id_lang, $order_by, $order_way, $start, $limit, $id_lang_shop);
    }

    // -------------------------------------------------------------------------
    // CALLBACKS
    // -------------------------------------------------------------------------

    public function renderClientType($value, $row)
    {
        if ($row['is_company']) {
            return '<span class="badge" style="background:#17A2B8;color:#fff;">' . $this->l('Société') . '</span>';
        }
        return '<span class="badge" style="background:#6C757D;color:#fff;">' . $this->l('Salarié/Retraité') . '</span>';
    }

    public function renderOrganisation($value, $row)
    {
        if ($row['belongs_to_partner'] && $row['organisation_name']) {
            return '<strong>' . htmlspecialchars($row['organisation_name']) . '</strong>';
        }
        if ($row['organisation_autre']) {
            return htmlspecialchars($row['organisation_autre']);
        }
        return '<em>' . $this->l('Aucun') . '</em>';
    }

    public function renderOrderLink($value, $row)
    {
        $id_order = (int) $row['linked_order_id'];
        if ($id_order) {

            $orderLink = Context::getContext()->link->getAdminLink('AdminOrders', true, [], [
                'id_order' => $id_order,
                'vieworder' => 1
            ]);
            return '<a href="' . $orderLink . '" target="_blank">#' . $id_order . ' <i class="icon-external-link"></i></a>';
        }
        return '<em>' . $this->l('Aucune') . '</em>';
    }

    // -------------------------------------------------------------------------
    // VIEW (detail)
    // -------------------------------------------------------------------------


    public function renderView()
    {
        $id_request = (int) Tools::getValue('id_request');
        $request    = new PaiementFaciliteRequest($id_request);

        if (!Validate::isLoadedObject($request)) {
            $this->errors[] = $this->l('Demande introuvable.');
            return parent::renderList();
        }

        $customer = new Customer($request->id_customer);
        $address  = new Address($request->id_address);
        $linked   = $request->getLinkedOrder();
        $docs     = $request->getDocuments();
        $org      = null;
        if ($request->id_organisation) {
            $org = new PaiementFaciliteOrganisation($request->id_organisation);
        }

        $order_url = '';
        if ($linked && $linked['id_order']) {
            $order_url = $this->context->link->getAdminLink('AdminOrders') . '&vieworder&id_order=' . (int) $linked['id_order'];
        }

        $upload_base = _PS_MODULE_DIR_ . 'paiementfacilite/uploads/' . $id_request . '/';

        $this->context->smarty->assign([
            'pf_request'    => $request,
            'pf_customer'   => $customer,
            'pf_address'    => $address,
            'pf_org'        => $org,
            'pf_docs'       => $docs,
            'pf_upload_base' => $upload_base,
            'pf_linked_order_id' => $linked ? (int) $linked['id_order'] : 0,
            'pf_order_url'  => $order_url,
            'pf_approve_url' => $this->context->link->getAdminLink('AdminPaiementFaciliteRequests')
                . '&id_request=' . $id_request . '&action=approve&token=' . Tools::getAdminToken('AdminPaiementFaciliteRequests'),
            'pf_reject_url' => $this->context->link->getAdminLink('AdminPaiementFaciliteRequests')
                . '&id_request=' . $id_request . '&action=reject&token=' . Tools::getAdminToken('AdminPaiementFaciliteRequests'),
            'pf_back_url'   => $this->context->link->getAdminLink('AdminPaiementFaciliteRequests'),
            'doc_labels'    => $this->getDocLabels(),
        ]);

        return $this->context->smarty->fetch(_PS_MODULE_DIR_ . 'paiementfacilite/views/templates/admin/view_request.tpl');
    }

    private function getDocLabels()
    {
        return [
            PaiementFaciliteDocument::TYPE_FICHE_PAIE        => $this->l('Fiche(s) de paie'),
            PaiementFaciliteDocument::TYPE_ATTESTATION       => $this->l('Attestation retraite'),
            PaiementFaciliteDocument::TYPE_COPIE_RNE         => $this->l('Copie du RNE'),
            PaiementFaciliteDocument::TYPE_REGISTRE_COMMERCE => $this->l('Registre de commerce / Patente'),
            PaiementFaciliteDocument::TYPE_STATUTS           => $this->l('Statuts de la société'),
            PaiementFaciliteDocument::TYPE_CIN_RECTO         => $this->l('CIN / CIN gérant (Recto)'),
            PaiementFaciliteDocument::TYPE_CIN_VERSO         => $this->l('CIN / CIN gérant (Verso)'),
            PaiementFaciliteDocument::TYPE_RIB               => $this->l('RIB / Identité bancaire'),
            PaiementFaciliteDocument::TYPE_RELEVE_BANCAIRE   => $this->l('Relevé(s) bancaire(s)'),
            PaiementFaciliteDocument::TYPE_FACTURE_STEG      => $this->l('Facture STEG / SONEDE'),
        ];
    }

    // -------------------------------------------------------------------------
    // ACTIONS
    // -------------------------------------------------------------------------

    public function processApprove()
    {
        $id_request = (int) Tools::getValue('id_request');
        $request    = new PaiementFaciliteRequest($id_request);
        if (!Validate::isLoadedObject($request)) {
            $this->errors[] = $this->l('Demande introuvable.');
            return;
        }
        if ($request->updateStatus('approved')) {
            $this->updateLinkedOrderState($request, 'approved');
            $this->sendStatusEmail($request, 'approved');
            $this->confirmations[] = $this->l('Demande approuvée.');
        } else {
            $this->errors[] = $this->l('Impossible de mettre à jour le statut.');
        }
    }

    public function processReject()
    {
        $id_request = (int) Tools::getValue('id_request');
        $request    = new PaiementFaciliteRequest($id_request);
        if (!Validate::isLoadedObject($request)) {
            $this->errors[] = $this->l('Demande introuvable.');
            return;
        }
        if ($request->updateStatus('rejected')) {
            $this->updateLinkedOrderState($request, 'rejected');
            $this->sendStatusEmail($request, 'rejected');
            $this->confirmations[] = $this->l('Demande rejetée.');
        } else {
            $this->errors[] = $this->l('Impossible de mettre à jour le statut.');
        }
    }

    public function processBulkApprove()
    {
        foreach (Tools::getValue($this->table . 'Box', []) as $id) {
            $request = new PaiementFaciliteRequest((int) $id);
            if (Validate::isLoadedObject($request)) {
                $request->updateStatus('approved');
                $this->updateLinkedOrderState($request, 'approved');
                $this->sendStatusEmail($request, 'approved');
            }
        }
        $this->confirmations[] = $this->l('Demandes approuvées.');
    }

    public function processBulkReject()
    {
        foreach (Tools::getValue($this->table . 'Box', []) as $id) {
            $request = new PaiementFaciliteRequest((int) $id);
            if (Validate::isLoadedObject($request)) {
                $request->updateStatus('rejected');
                $this->updateLinkedOrderState($request, 'rejected');
                $this->sendStatusEmail($request, 'rejected');
            }
        }
        $this->confirmations[] = $this->l('Demandes rejetées.');
    }

    /**
     * Move the linked PS order to the approved or rejected order state.
     */
    private function updateLinkedOrderState(PaiementFaciliteRequest $request, $decision)
    {
        $linked = $request->getLinkedOrder();
        if (!$linked || !(int) $linked['id_order']) {
            return;
        }
        $id_order = (int) $linked['id_order'];
        $order    = new Order($id_order);
        if (!Validate::isLoadedObject($order)) {
            return;
        }

        $config_key = ($decision === 'approved') ? 'PF_OS_APPROVED' : 'PF_OS_REJECTED';
        $id_state   = (int) Configuration::get($config_key);
        if (!$id_state) {
            return;
        }

        $history              = new OrderHistory();
        $history->id_order    = $id_order;
        $history->id_employee = isset($this->context->employee->id)
            ? (int) $this->context->employee->id
            : 0;
        $history->changeIdOrderState($id_state, $order);

        $message = ($decision === 'approved')
            ? $this->l('Demande de facilité #') . $request->id . ' ' . $this->l('approuvée.')
            : $this->l('Demande de facilité #') . $request->id . ' ' . $this->l('rejetée.');

        $history->addWithemail(true, ['employee_firstname' => '', 'employee_lastname' => '']);

        // Add an order message visible in back-office
        $msg              = new Message();
        $msg->id_order    = $id_order;
        $msg->message     = $message;
        $msg->private     = true;
        $msg->add();
    }

    private function sendStatusEmail(PaiementFaciliteRequest $request, $status)
    {
        $customer = new Customer($request->id_customer);
        if (!Validate::isLoadedObject($customer)) {
            return;
        }

        $label = ($status === 'approved') ? 'approuvée' : 'rejetée';
        $templateVars = [
            '{firstname}'  => $customer->firstname,
            '{lastname}'   => $customer->lastname,
            '{id_request}' => $request->id,
            '{status}'     => $label,
            '{amount}'     => number_format($request->credit_amount, 2, ',', ' ') . ' DT',
        ];

        $template = ($status === 'approved') ? 'pf_approved' : 'pf_rejected';
        $subject  = ($status === 'approved')
            ? 'Votre demande de paiement par facilité a été approuvée'
            : 'Votre demande de paiement par facilité a été rejetée';

        Mail::Send(
            (int) Configuration::get('PS_LANG_DEFAULT'),
            $template,
            $subject,
            $templateVars,
            $customer->email,
            $customer->firstname . ' ' . $customer->lastname,
            null,
            null,
            null,
            null,
            _PS_MODULE_DIR_ . 'paiementfacilite/mails/'
        );
    }

    // -------------------------------------------------------------------------
    // CREATE / EDIT FORM
    // -------------------------------------------------------------------------

    public function renderForm()
    {
        /** @var PaiementFaciliteRequest $obj */
        $obj    = $this->loadObject(true);
        $is_add = !Validate::isLoadedObject($obj);

        $orgs = [['id_organisation' => 0, 'name' => $this->l('— Aucun —')]];
        foreach (PaiementFaciliteOrganisation::getActiveOrganisations() as $o) {
            $orgs[] = $o;
        }

        $pf_customer        = null;
        $pf_addresses       = [];
        $pf_orders          = [];
        $pf_linked_order_id = 0;
        if (!$is_add && $obj->id_customer) {
            $pf_customer = new Customer((int) $obj->id_customer);
            if (!Validate::isLoadedObject($pf_customer)) {
                $pf_customer = null;
            } else {
                $pf_addresses = $pf_customer->getAddresses((int) $this->context->language->id);
                $pf_orders    = $this->getCustomerOrdersForSelect((int) $obj->id_customer);
            }
            $linked = $obj->getLinkedOrder();
            $pf_linked_order_id = $linked ? (int) $linked['id_order'] : 0;
        }

        $docs = $is_add ? [] : $obj->getDocuments();
        foreach ($docs as &$doc) {
            $doc['file_ext']       = strtolower(pathinfo($doc['filename'], PATHINFO_EXTENSION));
            $doc['date_formatted'] = date('d/m/Y', strtotime($doc['date_add']));
        }
        unset($doc);

        $this->context->smarty->assign([
            'pf_obj'             => $obj,
            'pf_is_add'          => $is_add,
            'pf_organisations'   => $orgs,
            'pf_customer'        => $pf_customer,
            'pf_addresses'       => $pf_addresses,
            'pf_orders'          => $pf_orders,
            'pf_linked_order_id' => $pf_linked_order_id,
            'pf_docs'            => $docs,
            'pf_doc_count'       => count($docs),
            'doc_labels'         => $this->getDocLabels(),
            'pf_form_action'     => $this->context->link->getAdminLink('AdminPaiementFaciliteRequests'),
            'pf_back_url'        => $this->context->link->getAdminLink('AdminPaiementFaciliteRequests'),
            'pf_ajax_url'        => $this->context->link->getAdminLink('AdminPaiementFaciliteRequests'),
        ]);

        return $this->context->smarty->fetch(
            _PS_MODULE_DIR_ . 'paiementfacilite/views/templates/admin/request_form.tpl'
        );
    }

    public function processSave()
    {
        $nb_mois = (int) Tools::getValue('nb_mois');
        if ($nb_mois < 2 || $nb_mois > 12) {
            $_POST['nb_mois'] = 6;
        }

        $credit  = (float) Tools::getValue('credit_amount');
        $tranche = (float) Tools::getValue('premiere_tranche');
        $nb      = (int) ($_POST['nb_mois'] ?? $nb_mois);
        if ((float) Tools::getValue('mensualite') <= 0 && $credit > 0 && $tranche < $credit && $nb > 0) {
            $_POST['mensualite'] = round(($credit - $tranche) / $nb, 2);
        }

        if (!(int) Tools::getValue('id_organisation')) {
            $_POST['id_organisation'] = null;
        }

        parent::processSave();
    }

    public function processAdd()
    {
        $result = parent::processAdd();
        if ($result && Validate::isLoadedObject($this->object)) {
            $this->saveDocuments((int) $this->object->id);
            $this->saveOrderLink((int) $this->object->id, (int) Tools::getValue('id_order_link'));
        }
        return $result;
    }

    public function processUpdate()
    {
        $result = parent::processUpdate();
        if ($result !== false && Validate::isLoadedObject($this->object)) {
            $this->saveDocuments((int) $this->object->id);
            $this->saveOrderLink((int) $this->object->id, (int) Tools::getValue('id_order_link'));
        }
        return $result;
    }

    private function saveDocuments($id_request)
    {
        $is_company = (bool) $this->object->is_company;
        $is_retired = (bool) $this->object->is_retired;

        if ($is_company) {
            $singles = [
                'copie_rne'        => PaiementFaciliteDocument::TYPE_COPIE_RNE,
                'cin_gerant_recto' => PaiementFaciliteDocument::TYPE_CIN_RECTO,
                'cin_gerant_verso' => PaiementFaciliteDocument::TYPE_CIN_VERSO,
                'rib'              => PaiementFaciliteDocument::TYPE_RIB,
            ];
        } else {
            $singles = [
                'cin_recto'    => PaiementFaciliteDocument::TYPE_CIN_RECTO,
                'cin_verso'    => PaiementFaciliteDocument::TYPE_CIN_VERSO,
                'facture_steg' => PaiementFaciliteDocument::TYPE_FACTURE_STEG,
                'rib'          => PaiementFaciliteDocument::TYPE_RIB,
            ];
            if ($is_retired) {
                $singles['attestation_retraite'] = PaiementFaciliteDocument::TYPE_ATTESTATION;
            }
        }

        foreach ($singles as $input => $type) {
            if (!empty($_FILES[$input]['name']) && $_FILES[$input]['error'] === UPLOAD_ERR_OK) {
                $this->replaceSingleDoc($id_request, $type, $_FILES[$input]);
            }
        }

        if (!$is_company && !$is_retired && !empty($_FILES['fiche_paie']['name'])) {
            $this->saveMultiDoc($id_request, 'fiche_paie', PaiementFaciliteDocument::TYPE_FICHE_PAIE, 3);
        }

        if (!empty($_FILES['releve_bancaire']['name'])) {
            $this->saveMultiDoc($id_request, 'releve_bancaire', PaiementFaciliteDocument::TYPE_RELEVE_BANCAIRE, 3);
        }
    }

    private function saveOrderLink($id_request, $id_order)
    {
        Db::getInstance()->delete('pf_request_orders', 'id_request = ' . (int) $id_request);
        if ($id_order) {
            Db::getInstance()->insert('pf_request_orders', [
                'id_request' => (int) $id_request,
                'id_order'   => (int) $id_order,
                'date_add'   => date('Y-m-d H:i:s'),
            ]);
        }
    }

    private function getCustomerOrdersForSelect($id_customer)
    {

        $min_amout = Configuration::get('PF_MIN_AMOUNT');
        $query = new DbQuery();
        $query->select('o.id_order, o.reference, o.total_paid_tax_incl, o.date_add');
        $query->from('orders', 'o');
        $query->leftJoin('pf_request_orders', 'ro', 'ro.id_order = o.id_order');
        $query->where('o.id_customer = ' . (int) $id_customer);
        $query->where('o.id_order NOT IN (SELECT id_order FROM ' . _DB_PREFIX_ . 'pf_request_orders)');
        $query->where('o.total_paid_tax_incl >' .  (float)$min_amout);
        $query->orderBy('o.date_add DESC');
        $query->limit(50);
        $rows = Db::getInstance()->executeS($query);



        $out = [];
        foreach ($rows as $o) {
            $out[] = [
                'id_order' => (int) $o['id_order'],
                'label'    => '#' . $o['id_order'] . ' — ' . $o['reference']
                    . ' — ' . number_format((float) $o['total_paid_tax_incl'], 2, ',', ' ') . ' DT'
                    . ' (' . substr($o['date_add'], 0, 10) . ')',
                'total'    => (float) $o['total_paid_tax_incl'],
            ];
        }
        return $out;
    }

    private function replaceSingleDoc($id_request, $type, array $file)
    {
        $existing = Db::getInstance()->executeS(
            'SELECT id_document, filename FROM `' . _DB_PREFIX_ . 'pf_documents`
             WHERE id_request = ' . (int) $id_request . ' AND doc_type = \'' . pSQL($type) . '\''
        );
        foreach ($existing as $row) {
            $path = _PS_MODULE_DIR_ . 'paiementfacilite/uploads/' . (int) $id_request . '/' . $row['filename'];
            if (file_exists($path)) {
                @unlink($path);
            }
            Db::getInstance()->delete('pf_documents', 'id_document = ' . (int) $row['id_document']);
        }
        PaiementFaciliteDocument::saveUpload($id_request, $type, $file);
    }

    private function saveMultiDoc($id_request, $input_name, $doc_type, $max)
    {
        if (empty($_FILES[$input_name]['name']) || !is_array($_FILES[$input_name]['name'])) {
            return;
        }
        $count = 0;
        foreach ($_FILES[$input_name]['name'] as $i => $name) {
            if ($count >= $max) {
                break;
            }
            if (!empty($name) && $_FILES[$input_name]['error'][$i] === UPLOAD_ERR_OK) {
                PaiementFaciliteDocument::saveUpload($id_request, $doc_type, [
                    'name'     => $name,
                    'tmp_name' => $_FILES[$input_name]['tmp_name'][$i],
                    'error'    => $_FILES[$input_name]['error'][$i],
                    'size'     => $_FILES[$input_name]['size'][$i],
                ]);
                ++$count;
            }
        }
    }

    // -------------------------------------------------------------------------
    // AJAX ENDPOINTS
    // -------------------------------------------------------------------------

    public function ajaxProcessSearchCustomers()
    {
        $q = trim(Tools::getValue('q', ''));
        if (Tools::strlen($q) < 2) {
            die(json_encode([]));
        }
        $like = '%' . pSQL($q) . '%';
        $rows = Db::getInstance()->executeS(
            'SELECT c.id_customer, c.firstname, c.lastname, c.email,
                    (SELECT a.phone FROM `' . _DB_PREFIX_ . 'address` a
                     WHERE a.id_customer = c.id_customer AND a.deleted = 0
                     LIMIT 1) AS phone
             FROM `' . _DB_PREFIX_ . 'customer` c
             WHERE c.deleted = 0 AND c.active = 1
               AND (c.firstname LIKE \'' . $like . '\'
                 OR c.lastname  LIKE \'' . $like . '\'
                 OR c.email     LIKE \'' . $like . '\'
                 OR CONCAT(c.firstname,\' \',c.lastname) LIKE \'' . $like . '\'
                 OR EXISTS (
                     SELECT 1 FROM `' . _DB_PREFIX_ . 'address` a2
                     WHERE a2.id_customer = c.id_customer
                       AND a2.deleted = 0
                       AND a2.phone LIKE \'' . $like . '\'
                 ))
             ORDER BY c.lastname ASC
             LIMIT 20'
        );

        $out = [];
        foreach ($rows as $r) {
            $out[] = [
                'id'    => (int) $r['id_customer'],
                'label' => $r['firstname'] . ' ' . $r['lastname'] . ' — ' . $r['email']
                    . ($r['phone'] ? ' — ' . $r['phone'] : ''),
                'name'  => $r['firstname'] . ' ' . $r['lastname'],
                'email' => $r['email'],
            ];
        }
        die(json_encode($out));
    }

    public function ajaxProcessGetCustomerAddresses()
    {
        $id_customer = (int) Tools::getValue('id_customer');
        if (!$id_customer) {
            die(json_encode([]));
        }
        $customer = new Customer($id_customer);
        if (!Validate::isLoadedObject($customer)) {
            die(json_encode([]));
        }
        $addresses = $customer->getAddresses((int) $this->context->language->id);
        $out = [];
        foreach ($addresses as $a) {
            $out[] = [
                'id_address' => (int) $a['id_address'],
                'label'      => $a['alias'] . ' — ' . $a['address1'] . ', ' . $a['city'],
            ];
        }
        die(json_encode($out));
    }

    public function ajaxProcessSaveNewAddress()
    {
        $id_customer = (int) Tools::getValue('id_customer');
        if (!$id_customer) {
            die(json_encode(['success' => false, 'error' => 'Client invalide.']));
        }
        $customer = new Customer($id_customer);
        if (!Validate::isLoadedObject($customer)) {
            die(json_encode(['success' => false, 'error' => 'Client introuvable.']));
        }

        $alias     = trim(Tools::getValue('alias', ''));
        $firstname = trim(Tools::getValue('firstname', ''));
        $lastname  = trim(Tools::getValue('lastname', ''));
        $address1  = trim(Tools::getValue('address1', ''));
        $postcode  = trim(Tools::getValue('postcode', ''));
        $city      = trim(Tools::getValue('city', ''));

        if (!$alias || !$firstname || !$lastname || !$address1 || !$postcode || !$city) {
            die(json_encode(['success' => false, 'error' => 'Champs obligatoires manquants.']));
        }

        $address              = new Address();
        $address->id_customer = $id_customer;
        $address->alias       = pSQL($alias);
        $address->firstname   = pSQL($firstname);
        $address->lastname    = pSQL($lastname);
        $address->address1    = pSQL($address1);
        $address->postcode    = pSQL($postcode);
        $address->city        = pSQL($city);
        $address->phone       = pSQL(trim(Tools::getValue('phone', '')));
        $address->id_country  = (int) Configuration::get('PS_COUNTRY_DEFAULT');

        if (!$address->add()) {
            die(json_encode(['success' => false, 'error' => 'Erreur lors de la sauvegarde.']));
        }

        $addresses = $customer->getAddresses((int) $this->context->language->id);
        $out = [];
        foreach ($addresses as $a) {
            $out[] = [
                'id_address' => (int) $a['id_address'],
                'label'      => $a['alias'] . ' — ' . $a['address1'] . ', ' . $a['city'],
            ];
        }
        die(json_encode(['success' => true, 'id_address' => (int) $address->id, 'addresses' => $out]));
    }

    public function ajaxProcessGetCustomerOrders()
    {
        $id_customer = (int) Tools::getValue('id_customer');
        if (!$id_customer) {
            die(json_encode([]));
        }
        die(json_encode($this->getCustomerOrdersForSelect($id_customer)));
    }

    public function ajaxProcessDeleteDocument()
    {
        $id_document = (int) Tools::getValue('id_document');
        if (!$id_document) {
            die(json_encode(['success' => false, 'error' => 'ID invalide.']));
        }
        $doc = new PaiementFaciliteDocument($id_document);
        if (!Validate::isLoadedObject($doc)) {
            die(json_encode(['success' => false, 'error' => 'Document introuvable.']));
        }
        $path = $doc->getFilePath();
        if (file_exists($path)) {
            @unlink($path);
        }
        if ($doc->delete()) {
            die(json_encode(['success' => true]));
        }
        die(json_encode(['success' => false, 'error' => 'Erreur de suppression.']));
    }

    // -------------------------------------------------------------------------
    // DOCUMENT DOWNLOAD
    // -------------------------------------------------------------------------

    public function postProcess()
    {
        if (Tools::getValue('download_doc')) {
            $id_doc = (int) Tools::getValue('id_document');
            $doc    = new PaiementFaciliteDocument($id_doc);
            if (Validate::isLoadedObject($doc)) {
                $request = new PaiementFaciliteRequest($doc->id_request);
                if (Validate::isLoadedObject($request)) {
                    $path = $doc->getFilePath();
                    if (file_exists($path)) {
                        header('Content-Type: application/octet-stream');
                        header('Content-Disposition: attachment; filename="' . basename($path) . '"');
                        header('Content-Length: ' . filesize($path));
                        readfile($path);
                        exit;
                    }
                }
            }
            $this->errors[] = $this->l('Fichier introuvable.');
        }

        parent::postProcess();
    }
}
