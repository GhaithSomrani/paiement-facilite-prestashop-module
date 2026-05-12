<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class PaiementFaciliteOrganisation extends ObjectModel
{
    /** @var string */
    public $name;
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
            'name'     => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 128],
            'active'   => ['type' => self::TYPE_BOOL,   'validate' => 'isBool'],
            'date_add' => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'date_upd' => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
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
}
