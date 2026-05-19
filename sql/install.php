<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

$sql = [];

// Partner organisations
$sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_organisations` (
    `id_organisation` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `name`          varchar(128) NOT NULL,
    `contact_name`  varchar(128) DEFAULT NULL,
    `contact_email` varchar(128) DEFAULT NULL,
    `contact_phone` varchar(32)  DEFAULT NULL,
    `address`       varchar(255) DEFAULT NULL,
    `logo`          varchar(255) DEFAULT NULL,
    `active` tinyint(1) unsigned NOT NULL DEFAULT 1,
    `date_add` datetime NOT NULL,
    `date_upd` datetime NOT NULL,
    PRIMARY KEY (`id_organisation`)
) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

// Main requests table
$sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_requests` (
    `id_request` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `id_customer` int(10) unsigned NOT NULL,
    `id_address` int(10) unsigned NOT NULL,
    `is_company` tinyint(1) unsigned NOT NULL DEFAULT 0,
    `is_retired` tinyint(1) unsigned NOT NULL DEFAULT 0,
    `belongs_to_partner` tinyint(1) unsigned NOT NULL DEFAULT 0,
    `id_organisation` int(10) unsigned DEFAULT NULL,
    `organisation_autre` varchar(255) DEFAULT NULL,
    `date_naissance` date DEFAULT NULL,
    `fonction` varchar(128) DEFAULT NULL,
    `cin` varchar(32) DEFAULT NULL,
    `raison_sociale` varchar(255) DEFAULT NULL,
    `matricule_fiscal` varchar(64) DEFAULT NULL,
    `date_naissance_gerant` date DEFAULT NULL,
    `representant_legal` varchar(255) DEFAULT NULL,
    `cin_gerant` varchar(32) DEFAULT NULL,
    `telephone_gerant` varchar(32) DEFAULT NULL,
    `email_gerant` varchar(128) DEFAULT NULL,
    `credit_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
    `premiere_tranche` decimal(10,2) NOT NULL DEFAULT 0.00,
    `mensualite` decimal(10,2) NOT NULL DEFAULT 0.00,
    `nb_mois` tinyint(3) unsigned NOT NULL DEFAULT 6,
    `interest_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
    `commentaire` text DEFAULT NULL,
    `status` enum(\'pending\',\'approved_mode\',\'rejected_mode\',\'approved_emp\',\'rejected_emp\') NOT NULL DEFAULT \'pending\',
    `date_add` datetime NOT NULL,
    `date_upd` datetime NOT NULL,
    PRIMARY KEY (`id_request`),
    KEY `id_customer` (`id_customer`),
    KEY `id_address` (`id_address`),
    KEY `id_organisation` (`id_organisation`),
    KEY `status` (`status`)
) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

// Link requests to orders (nullable id_order for standalone)
$sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_request_orders` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `id_request` int(10) unsigned NOT NULL,
    `id_order` int(10) unsigned DEFAULT NULL,
    `date_add` datetime NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_request_order` (`id_request`, `id_order`),
    KEY `id_request` (`id_request`),
    KEY `id_order` (`id_order`)
) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

// Uploaded documents
$sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_documents` (
    `id_document` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `id_request` int(10) unsigned NOT NULL,
    `doc_type` varchar(64) NOT NULL,
    `filename` varchar(255) NOT NULL,
    `date_add` datetime NOT NULL,
    `date_upd` datetime NOT NULL,
    PRIMARY KEY (`id_document`),
    KEY `id_request` (`id_request`)
) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

// Configurable status definitions (links request statuses to PS order states)
$sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_statuses` (
    `id_pf_status`   int(10) unsigned NOT NULL AUTO_INCREMENT,
    `code`           varchar(32) NOT NULL,
    `name`           varchar(128) NOT NULL,
    `color`          varchar(16) NOT NULL DEFAULT \'#888888\',
    `id_order_state` int(10) unsigned DEFAULT NULL,
    `sort_order`     tinyint(3) unsigned NOT NULL DEFAULT 0,
    `date_add` datetime NOT NULL,
    `date_upd` datetime NOT NULL,
    PRIMARY KEY (`id_pf_status`),
    UNIQUE KEY `code` (`code`)
) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

// Per-month configuration: minimum credit amount to unlock + interest rate
$sql[] = 'CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'pf_month_configs` (
    `id_config`     int(10) unsigned NOT NULL AUTO_INCREMENT,
    `nb_mois`       tinyint(3) unsigned NOT NULL,
    `min_amount`    decimal(10,2) NOT NULL DEFAULT 0.00,
    `interest_rate` decimal(5,2)  NOT NULL DEFAULT 0.00,
    `active`        tinyint(1) unsigned NOT NULL DEFAULT 1,
    `date_add`      datetime NOT NULL,
    `date_upd`      datetime NOT NULL,
    PRIMARY KEY (`id_config`),
    UNIQUE KEY `nb_mois` (`nb_mois`)
) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4;';

// Seed the 5 workflow statuses (INSERT IGNORE — safe to re-run)
$sql[] = 'INSERT IGNORE INTO `' . _DB_PREFIX_ . 'pf_statuses`
    (`code`, `name`, `color`, `id_order_state`, `sort_order`, `date_add`, `date_upd`) VALUES
    (\'pending\',       \'En attente\',                       \'#f39c12\', NULL, 1, NOW(), NOW()),
    (\'approved_mode\', \'Validé par La Mode\',               \'#2980b9\', NULL, 2, NOW(), NOW()),
    (\'rejected_mode\', \'Rejeté par La Mode\',               \'#c0392b\', NULL, 3, NOW(), NOW()),
    (\'approved_emp\',  \'Validé par l\\\'employeur\',        \'#27ae60\', NULL, 4, NOW(), NOW()),
    (\'rejected_emp\',  \'Rejeté par l\\\'employeur\',        \'#c0392b\', NULL, 5, NOW(), NOW())';
