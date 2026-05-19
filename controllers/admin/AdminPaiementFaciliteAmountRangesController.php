<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteMonthConfig.php';

/**
 * Manages per-month configurations:
 * minimum credit amount to unlock a month option + interest rate for that month.
 */
class AdminPaiementFaciliteAmountRangesController extends ModuleAdminController
{
    public function __construct()
    {
        $this->table      = 'pf_month_configs';
        $this->className  = 'PaiementFaciliteMonthConfig';
        $this->identifier = 'id_config';
        $this->bootstrap  = true;

        parent::__construct();

        $this->module = Module::getInstanceByName('paiementfacilite');

        $this->fields_list = [
            'id_config' => [
                'title' => $this->l('ID'),
                'align' => 'center',
                'class' => 'fixed-width-xs',
            ],
            'nb_mois' => [
                'title'  => $this->l('Nombre de mois'),
                'align'  => 'center',
                'suffix' => ' mois',
            ],
            'min_amount' => [
                'title' => $this->l('Montant min (DT)'),
                'align' => 'right',
                'type'  => 'price',
            ],
            'interest_rate' => [
                'title'  => $this->l('Taux d\'intérêt (%)'),
                'align'  => 'right',
                'suffix' => ' %',
            ],
            'active' => [
                'title'  => $this->l('Actif'),
                'active' => 'status',
                'type'   => 'bool',
                'align'  => 'center',
            ],
        ];

        $monthOptions = [];
        for ($m = 2; $m <= 12; $m++) {
            $monthOptions[] = ['id' => $m, 'name' => $m . ' ' . $this->l('mois')];
        }

        $this->fields_form = [
            'legend' => [
                'title' => $this->l('Configuration par nombre de mois'),
                'icon'  => 'icon-calendar',
            ],
            'input' => [
                [
                    'type'     => 'select',
                    'label'    => $this->l('Nombre de mois'),
                    'name'     => 'nb_mois',
                    'required' => true,
                    'options'  => [
                        'query' => $monthOptions,
                        'id'    => 'id',
                        'name'  => 'name',
                    ],
                    'desc' => $this->l('Le bouton de ce nombre de mois s\'affiche uniquement si le montant du crédit est supérieur ou égal au montant minimum.'),
                ],
                [
                    'type'     => 'text',
                    'label'    => $this->l('Montant minimum (DT)'),
                    'name'     => 'min_amount',
                    'required' => true,
                    'class'    => 'input-small',
                    'desc'     => $this->l('Le crédit doit atteindre ce montant pour que cette option de mensualités soit disponible.'),
                ],
                [
                    'type'     => 'text',
                    'label'    => $this->l('Taux d\'intérêt (%)'),
                    'name'     => 'interest_rate',
                    'required' => true,
                    'class'    => 'input-small',
                    'desc'     => $this->l('Appliqué sur le montant financé quand le client choisit ce nombre de mois. Ex : 5.5 pour 5,5 %. Saisir 0 pour aucun intérêt.'),
                ],
                [
                    'type'   => 'switch',
                    'label'  => $this->l('Actif'),
                    'name'   => 'active',
                    'values' => [
                        ['id' => 'active_on',  'value' => 1, 'label' => $this->l('Oui')],
                        ['id' => 'active_off', 'value' => 0, 'label' => $this->l('Non')],
                    ],
                ],
            ],
            'submit' => ['title' => $this->l('Enregistrer')],
        ];

        $this->addRowAction('edit');
        $this->addRowAction('delete');
    }

    public function getList($id_lang, $order_by = null, $order_way = null, $start = 0, $limit = null, $id_lang_shop = false)
    {
        parent::getList($id_lang, 'nb_mois', 'ASC', $start, $limit, $id_lang_shop);
    }

    public function postProcess()
    {
        if (Tools::isSubmit('submitAdd' . $this->table)) {
            $mois = (int)   Tools::getValue('nb_mois');
            $min  = (float) Tools::getValue('min_amount');
            $rate = (float) Tools::getValue('interest_rate');

            if ($mois < 2 || $mois > 12) {
                $this->errors[] = $this->l('Le nombre de mois doit être compris entre 2 et 12.');
                return;
            }
            if ($min < 0) {
                $this->errors[] = $this->l('Le montant minimum ne peut pas être négatif.');
                return;
            }
            if ($rate < 0 || $rate > 100) {
                $this->errors[] = $this->l('Le taux d\'intérêt doit être compris entre 0 et 100.');
                return;
            }
        }

        parent::postProcess();
    }
}
