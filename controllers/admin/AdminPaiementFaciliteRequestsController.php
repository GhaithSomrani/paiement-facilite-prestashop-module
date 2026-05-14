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
