<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class PaiementFaciliteOrganisation extends ObjectModel
{
    /** @var string */
    public $name;
    /** @var string */
    public $contact_name;
    /** @var string */
    public $contact_email;
    /** @var string */
    public $contact_phone;
    /** @var string */
    public $address;
    /** @var string */
    public $logo;
    /** @var bool */
    public $active = true;
    /** @var string */
    public $date_add;
    /** @var string */
    public $date_upd;

    public static $definition = [
        'table'   => 'pf_organisations',
        'primary' => 'id_organisation',
        'fields'  => [
            'name'         => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName',  'required' => true, 'size' => 128],
            'contact_name' => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName',  'size' => 128],
            'contact_email'=> ['type' => self::TYPE_STRING, 'validate' => 'isEmail',         'size' => 128],
            'contact_phone'=> ['type' => self::TYPE_STRING, 'validate' => 'isPhoneNumber',  'size' => 32],
            'address'      => ['type' => self::TYPE_STRING, 'validate' => 'isAddress',       'size' => 255],
            'logo'         => ['type' => self::TYPE_STRING, 'validate' => 'isFileName',      'size' => 255],
            'active'       => ['type' => self::TYPE_BOOL,   'validate' => 'isBool'],
            'date_add'     => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'date_upd'     => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
        ],
    ];

    /**
     * Return all active organisations for dropdown.
     */
    public static function getActiveOrganisations()
    {
        $query = new DbQuery();
        $query->select('id_organisation, name');
        $query->from('pf_organisations');
        $query->where('active = 1');
        $query->orderBy('name ASC');

        return Db::getInstance()->executeS($query);
    }

    /**
     * Absolute filesystem path to this organisation's logo directory.
     */
    public function getLogoDir()
    {
        return _PS_MODULE_DIR_ . 'paiementfacilite/uploads/organisations/' . (int) $this->id . '/';
    }

    /**
     * Absolute path to the logo file, or empty string if none.
     */
    public function getLogoPath()
    {
        if (!$this->logo) {
            return '';
        }
        return $this->getLogoDir() . $this->logo;
    }

    /**
     * Public URL to the logo, or empty string if none.
     */
    public function getLogoUrl()
    {
        if (!$this->logo || !file_exists($this->getLogoPath())) {
            return '';
        }
        return _MODULE_DIR_ . 'paiementfacilite/uploads/organisations/' . (int) $this->id . '/' . $this->logo;
    }
}
