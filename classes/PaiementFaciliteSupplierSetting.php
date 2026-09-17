<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

/**
 * Per-supplier "Paiement par facilité" display settings (table `pf_supplier_settings`).
 * A row = that supplier is allowed to show the payment method; max_months caps how many
 * months are shown on the product page for its products (0 = unlimited).
 * No rows at all in the table = no restriction configured, every supplier is allowed.
 */
class PaiementFaciliteSupplierSetting extends ObjectModel
{
    public $id_supplier;
    public $max_months;
    public $date_add;
    public $date_upd;

    public static $definition = [
        'table'   => 'pf_supplier_settings',
        'primary' => 'id_supplier_setting',
        'fields'  => [
            'id_supplier' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedId',  'required' => true],
            'max_months'  => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'date_add'    => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
            'date_upd'    => ['type' => self::TYPE_DATE, 'validate' => 'isDate'],
        ],
    ];

    public static function getByIdSupplier($id_supplier)
    {
        $id = (int) Db::getInstance()->getValue(
            'SELECT `id_supplier_setting` FROM `' . _DB_PREFIX_ . 'pf_supplier_settings`
             WHERE `id_supplier` = ' . (int) $id_supplier
        );

        return $id ? new self($id) : null;
    }

    /**
     * All settings keyed by id_supplier => max_months.
     */
    public static function getAll()
    {
        $rows = Db::getInstance()->executeS(
            'SELECT `id_supplier`, `max_months` FROM `' . _DB_PREFIX_ . 'pf_supplier_settings`'
        );

        $settings = [];
        foreach ($rows as $row) {
            $settings[(int) $row['id_supplier']] = (int) $row['max_months'];
        }

        return $settings;
    }

    public static function isAllowed($id_supplier, array $settings = null)
    {
        $settings = $settings ?? self::getAll();

        return empty($settings) || array_key_exists((int) $id_supplier, $settings);
    }

    /**
     * 0 = unlimited (no cap for this supplier, or no restriction configured at all).
     */
    public static function getMaxMonths($id_supplier, array $settings = null)
    {
        $settings = $settings ?? self::getAll();

        return $settings[(int) $id_supplier] ?? 0;
    }

    /**
     * Replace the whole allow-list in one go (the admin screen always saves the full
     * desired state, not per-row edits). Diffs against the current state with a single
     * read, then does the writes through ObjectModel::add()/update()/delete() — no
     * hand-written INSERT/UPDATE/DELETE.
     *
     * @param array $rows [ ['id_supplier' => int, 'max_months' => int], ... ]
     */
    public static function saveAll(array $rows)
    {
        $current = self::getAll();
        $desired = [];
        foreach ($rows as $row) {
            $desired[(int) $row['id_supplier']] = (int) $row['max_months'];
        }

        foreach ($desired as $id_supplier => $max_months) {
            $setting = self::getByIdSupplier($id_supplier) ?: new self();
            $setting->id_supplier = $id_supplier;
            $setting->max_months = $max_months;
            $setting->id ? $setting->update() : $setting->add();
        }

        foreach (array_diff_key($current, $desired) as $id_supplier => $max_months) {
            $setting = self::getByIdSupplier($id_supplier);
            if ($setting) {
                $setting->delete();
            }
        }
    }
}
