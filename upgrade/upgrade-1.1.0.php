<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

/**
 * Upgrade 1.0.0 → 1.1.0
 * Adds contact info + logo fields to pf_organisations.
 */
function upgrade_module_1_1_0($module)
{
    $db = Db::getInstance();

    $alterations = [
        "ALTER TABLE `" . _DB_PREFIX_ . "pf_organisations`
            ADD COLUMN IF NOT EXISTS `contact_name`  varchar(128) DEFAULT NULL AFTER `name`,
            ADD COLUMN IF NOT EXISTS `contact_email` varchar(128) DEFAULT NULL AFTER `contact_name`,
            ADD COLUMN IF NOT EXISTS `contact_phone` varchar(32)  DEFAULT NULL AFTER `contact_email`,
            ADD COLUMN IF NOT EXISTS `address`       varchar(255) DEFAULT NULL AFTER `contact_phone`,
            ADD COLUMN IF NOT EXISTS `logo`          varchar(255) DEFAULT NULL AFTER `address`",
    ];

    foreach ($alterations as $sql) {
        if (!$db->execute($sql)) {
            return false;
        }
    }

    return true;
}
