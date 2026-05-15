<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class PaiementFaciliteRequest extends ObjectModel
{
    /** @var int */
    public $id_customer;
    /** @var int */
    public $id_address;
    /** @var bool */
    public $is_company = false;
    /** @var bool */
    public $is_retired = false;
    /** @var bool */
    public $belongs_to_partner = false;
    /** @var int|null */
    public $id_organisation;
    /** @var string|null */
    public $organisation_autre;
    /** @var string|null */
    public $date_naissance;
    /** @var string|null */
    public $fonction;
    /** @var string|null */
    public $cin;
    /** @var string|null */
    public $raison_sociale;
    /** @var string|null */
    public $matricule_fiscal;
    /** @var string|null */
    public $date_naissance_gerant;
    /** @var string|null */
    public $representant_legal;
    /** @var string|null */
    public $cin_gerant;
    /** @var string|null */
    public $telephone_gerant;
    /** @var string|null */
    public $email_gerant;
    /** @var float */
    public $credit_amount = 0.00;
    /** @var float */
    public $premiere_tranche = 0.00;
    /** @var float */
    public $mensualite = 0.00;
    /** @var int */
    public $nb_mois = 6;
    /** @var string|null */
    public $commentaire;
    /** @var string */
    public $status = 'pending';
    /** @var string */
    public $date_add;
    /** @var string */
    public $date_upd;

    public static $definition = [
        'table'   => 'pf_requests',
        'primary' => 'id_request',
        'fields'  => [
            'id_customer'           => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedId',  'required' => true],
            'id_address'            => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedId',  'required' => true],
            'is_company'            => ['type' => self::TYPE_BOOL,   'validate' => 'isBool'],
            'is_retired'            => ['type' => self::TYPE_BOOL,   'validate' => 'isBool'],
            'belongs_to_partner'    => ['type' => self::TYPE_BOOL,   'validate' => 'isBool'],
            'id_organisation'       => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedId'],
            'organisation_autre'    => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 255],
            'date_naissance'        => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'fonction'              => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 128],
            'cin'                   => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 32],
            'raison_sociale'        => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 255],
            'matricule_fiscal'      => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 64],
            'date_naissance_gerant' => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'representant_legal'    => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 255],
            'cin_gerant'            => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 32],
            'telephone_gerant'      => ['type' => self::TYPE_STRING, 'validate' => 'isPhoneNumber',  'size' => 32],
            'email_gerant'          => ['type' => self::TYPE_STRING, 'validate' => 'isEmail',        'size' => 128],
            'credit_amount'         => ['type' => self::TYPE_FLOAT,  'validate' => 'isPrice'],
            'premiere_tranche'      => ['type' => self::TYPE_FLOAT,  'validate' => 'isPrice'],
            'mensualite'            => ['type' => self::TYPE_FLOAT,  'validate' => 'isPrice'],
            'nb_mois'               => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedInt'],
            'commentaire'           => ['type' => self::TYPE_STRING, 'validate' => 'isCleanHtml'],
            'status'                => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 16],
            'date_add'              => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'date_upd'              => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
        ],
    ];

    /**
     * Save the link to a PS order after the request is created.
     */
    public function linkOrder($id_order = null)
    {
        return Db::getInstance()->insert('pf_request_orders', [
            'id_request' => (int) $this->id,
            'id_order'   => $id_order ? (int) $id_order : null,
            'date_add'   => date('Y-m-d H:i:s'),
        ], false, true, Db::INSERT_IGNORE);
    }

    /**
     * Get the PS order linked to this request, if any.
     */
    public function getLinkedOrder()
    {
        return Db::getInstance()->getRow(
            'SELECT id_order FROM `' . _DB_PREFIX_ . 'pf_request_orders`
             WHERE id_request = ' . (int) $this->id
        );
    }

    /**
     * Return all documents for this request.
     */
    public function getDocuments()
    {
        return Db::getInstance()->executeS(
            'SELECT * FROM `' . _DB_PREFIX_ . 'pf_documents`
             WHERE id_request = ' . (int) $this->id . '
             ORDER BY doc_type, date_add'
        );
    }

    /**
     * Get all requests for a customer.
     */
    public static function getByCustomer($id_customer)
    {
        $query = new DbQuery();
        $query->select('r.*, ro.id_order');
        $query->from('pf_requests', 'r');
        $query->leftJoin('pf_request_orders', 'ro', 'ro.id_request = r.id_request');
        $query->where('r.id_customer = ' . (int) $id_customer);
        $query->orderBy('r.date_add DESC');

        return Db::getInstance()->executeS($query);
    }

    /**
     * Get requests for admin list with customer info.
     */
    public static function getRequestsForAdmin($filters = [], $start = 0, $limit = 50)
    {
        $query = new DbQuery();
        $query->select(
            'r.*, c.firstname, c.lastname, c.email,
             o.name AS organisation_name,
             ro.id_order,
             a.city'
        );
        $query->from('pf_requests', 'r');
        $query->leftJoin('customer', 'c', 'c.id_customer = r.id_customer');
        $query->leftJoin('pf_organisations', 'o', 'o.id_organisation = r.id_organisation');
        $query->leftJoin('pf_request_orders', 'ro', 'ro.id_request = r.id_request');
        $query->leftJoin('address', 'a', 'a.id_address = r.id_address');

        if (!empty($filters['status'])) {
            $query->where('r.status = \'' . pSQL($filters['status']) . '\'');
        }
        if (!empty($filters['id_customer'])) {
            $query->where('r.id_customer = ' . (int) $filters['id_customer']);
        }

        $query->orderBy('r.date_add DESC');
        $query->limit($limit, $start);

        return Db::getInstance()->executeS($query);
    }

    /**
     * Update status and optionally notify.
     */
    public function updateStatus($status)
    {
        $allowed = ['pending', 'approved_mode', 'rejected_mode', 'approved_emp', 'rejected_emp'];
        if (!in_array($status, $allowed)) {
            return false;
        }
        dump($this);
        $this->status = $status;
        return $this->update();
    }
}
