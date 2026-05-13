<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

/**
 * Upgrade 1.0.0 → 1.1.0
 * - Adds contact info + logo fields to pf_organisations
 * - Creates PF order states (pending / approved / rejected)
 */
function upgrade_module_1_1_0($module)
{
    $db = Db::getInstance();

    // ── Schema: new organisation columns ──────────────────────────────────────
    $sql = "ALTER TABLE `" . _DB_PREFIX_ . "pf_organisations`
        ADD COLUMN IF NOT EXISTS `contact_name`  varchar(128) DEFAULT NULL AFTER `name`,
        ADD COLUMN IF NOT EXISTS `contact_email` varchar(128) DEFAULT NULL AFTER `contact_name`,
        ADD COLUMN IF NOT EXISTS `contact_phone` varchar(32)  DEFAULT NULL AFTER `contact_email`,
        ADD COLUMN IF NOT EXISTS `address`       varchar(255) DEFAULT NULL AFTER `contact_phone`,
        ADD COLUMN IF NOT EXISTS `logo`          varchar(255) DEFAULT NULL AFTER `address`";

    if (!$db->execute($sql)) {
        return false;
    }

    // ── Order states ──────────────────────────────────────────────────────────
    $states = [
        'PF_OS_PENDING' => [
            'name'    => 'En attente de validation facilité',
            'color'   => '#FF8C00',
            'paid'    => false,
            'invoice' => false,
            'logable' => false,
            'send_email' => false,
        ],
        'PF_OS_APPROVED' => [
            'name'    => 'Paiement facilité approuvé',
            'color'   => '#28a745',
            'paid'    => true,
            'invoice' => true,
            'logable' => true,
            'send_email' => false,
        ],
        'PF_OS_REJECTED' => [
            'name'    => 'Paiement facilité rejeté',
            'color'   => '#dc3545',
            'paid'    => false,
            'invoice' => false,
            'logable' => false,
            'send_email' => false,
        ],
    ];

    foreach ($states as $key => $data) {
        if ((int) Configuration::get($key) > 0) {
            continue;
        }

        $os = new OrderState();
        $os->color       = $data['color'];
        $os->paid        = $data['paid'];
        $os->invoice     = $data['invoice'];
        $os->logable     = $data['logable'];
        $os->send_email  = $data['send_email'];
        $os->module_name = $module->name;
        foreach (Language::getLanguages() as $lang) {
            $os->name[$lang['id_lang']] = $data['name'];
        }
        if (!$os->add()) {
            return false;
        }
        Configuration::updateValue($key, (int) $os->id);
    }

    return true;
}
