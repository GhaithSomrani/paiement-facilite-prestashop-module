<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

/**
 * Per-month configuration: minimum credit amount to unlock + interest rate.
 *
 * Each row covers one value of nb_mois (2–12).
 * A month button is shown only when credit >= min_amount.
 * interest_rate is a flat rate on the financed amount:
 *   mensualité = (credit - tranche) * (1 + rate/100) / nb_mois
 */
class PaiementFaciliteMonthConfig extends ObjectModel
{
    public $nb_mois;
    public $min_amount;
    public $interest_rate;
    public $active;
    public $date_add;
    public $date_upd;

    public static $definition = [
        'table'   => 'pf_month_configs',
        'primary' => 'id_config',
        'fields'  => [
            'nb_mois'       => ['type' => self::TYPE_INT,   'validate' => 'isUnsignedInt', 'required' => true],
            'min_amount'    => ['type' => self::TYPE_FLOAT, 'validate' => 'isPrice',       'required' => true],
            'interest_rate' => ['type' => self::TYPE_FLOAT, 'validate' => 'isFloat',       'required' => true],
            'active'        => ['type' => self::TYPE_BOOL,  'validate' => 'isBool'],
            'date_add'      => ['type' => self::TYPE_DATE,  'validate' => 'isDate'],
            'date_upd'      => ['type' => self::TYPE_DATE,  'validate' => 'isDate'],
        ],
    ];

    /**
     * Return the active config for a given month count, or null if none.
     */
    public static function getByMonths($nb_mois)
    {
        $row = Db::getInstance()->getRow(
            'SELECT `id_config` FROM `' . _DB_PREFIX_ . 'pf_month_configs`
             WHERE `nb_mois` = ' . (int) $nb_mois . ' AND `active` = 1
             '
        );
        if (!$row) {
            return null;
        }
        return new self((int) $row['id_config']);
    }

    /**
     * All active configs keyed by nb_mois, for the frontend JS config object.
     * Returns an object: { "6": {minAmount, interestRate}, ... }
     */
    public static function getAllConfigsForJs()
    {
        $rows = Db::getInstance()->executeS(
            'SELECT `nb_mois`, `min_amount`, `interest_rate`
             FROM `' . _DB_PREFIX_ . 'pf_month_configs`
             WHERE `active` = 1
             ORDER BY `nb_mois` ASC'
        );
        if (!$rows) {
            return new stdClass();
        }
        $out = [];
        foreach ($rows as $r) {
            $out[(int) $r['nb_mois']] = [
                'minAmount'    => (float) $r['min_amount'],
                'interestRate' => (float) $r['interest_rate'],
            ];
        }
        return $out;
    }
}
