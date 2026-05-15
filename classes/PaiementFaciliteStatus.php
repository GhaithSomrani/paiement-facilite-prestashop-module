<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class PaiementFaciliteStatus extends ObjectModel
{
    /** @var string */
    public $code;
    /** @var string */
    public $name;
    /** @var string */
    public $color = '#888888';
    /** @var int|null */
    public $id_order_state;
    /** @var int */
    public $sort_order = 0;
    /** @var string */
    public $date_add;
    /** @var string */
    public $date_upd;

    public static $definition = [
        'table'   => 'pf_statuses',
        'primary' => 'id_pf_status',
        'fields'  => [
            'code'           => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 32, 'required' => true],
            'name'           => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'size' => 128, 'required' => true],
            'color'          => ['type' => self::TYPE_STRING, 'validate' => 'isColor', 'size' => 16],
            'id_order_state' => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedId'],
            'sort_order'     => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedInt'],
            'date_add'       => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'date_upd'       => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
        ],
    ];

    /**
     * All statuses ordered by sort_order.
     */
    public static function getAll()
    {
        return Db::getInstance()->executeS(
            'SELECT * FROM `' . _DB_PREFIX_ . 'pf_statuses` ORDER BY sort_order ASC, id_pf_status ASC'
        );
    }

    /**
     * Get a single status row by its code (e.g. 'pending', 'approved_mode').
     */
    public static function getByCode($code)
    {
        return Db::getInstance()->getRow(
            'SELECT * FROM `' . _DB_PREFIX_ . 'pf_statuses` WHERE `code` = \'' . pSQL($code) . '\''
        );
    }

    /**
     * Returns [id_pf_status => name] map, useful for HelperList select filters.
     */
    public static function getAllForSelect()
    {
        $rows = self::getAll();
        $out  = [];
        foreach ($rows as $r) {
            $out[(int) $r['id_pf_status']] = $r['name'];
        }
        return $out;
    }

    /**
     * Returns [code => name] map.
     */
    public static function getCodeNameMap()
    {
        $rows = self::getAll();
        $out  = [];
        foreach ($rows as $r) {
            $out[$r['code']] = $r['name'];
        }
        return $out;
    }
}
