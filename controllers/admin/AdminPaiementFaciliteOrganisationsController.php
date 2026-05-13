<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteOrganisation.php';

class AdminPaiementFaciliteOrganisationsController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap  = true;
        $this->table      = 'pf_organisations';
        $this->className  = 'PaiementFaciliteOrganisation';
        $this->identifier = 'id_organisation';
        $this->lang       = false;
        $this->allow_export = true;
        $this->_defaultOrderBy  = 'name';
        $this->_defaultOrderWay = 'ASC';

        parent::__construct();

        $this->module = Module::getInstanceByName('paiementfacilite');

        $this->fields_list = [
            'id_organisation' => [
                'title' => $this->l('ID'),
                'class' => 'fixed-width-xs',
                'align' => 'center',
            ],
            'logo' => [
                'title'    => $this->l('Logo'),
                'callback' => 'renderLogo',
                'orderby'  => false,
                'filter'   => false,
                'class'    => 'fixed-width-lg',
                'align'    => 'center',
            ],
            'name' => [
                'title' => $this->l('Organisme'),
            ],
            'contact_name' => [
                'title' => $this->l('Représentant'),
            ],
            'contact_email' => [
                'title' => $this->l('Email'),
            ],
            'contact_phone' => [
                'title' => $this->l('Téléphone'),
                'class' => 'fixed-width-lg',
            ],
            'active' => [
                'title'   => $this->l('Actif'),
                'active'  => 'status',
                'type'    => 'bool',
                'class'   => 'fixed-width-sm',
                'align'   => 'center',
                'orderby' => true,
            ],
        ];

        $this->bulk_actions = [
            'delete' => [
                'text'    => $this->l('Supprimer la sélection'),
                'confirm' => $this->l('Supprimer les organismes sélectionnés ?'),
                'icon'    => 'icon-trash',
            ],
            'enableSelection' => [
                'text' => $this->l('Activer la sélection'),
                'icon' => 'icon-power-off',
            ],
            'disableSelection' => [
                'text' => $this->l('Désactiver la sélection'),
                'icon' => 'icon-power-off',
            ],
        ];

        $this->addRowAction('edit');
        $this->addRowAction('delete');
    }

    // -------------------------------------------------------------------------
    // LIST CALLBACK
    // -------------------------------------------------------------------------

    public function renderLogo($value, $row)
    {
        if (!$value) {
            return '<span class="text-muted">—</span>';
        }
        $url = _MODULE_DIR_ . 'paiementfacilite/uploads/organisations/' . (int) $row['id_organisation'] . '/' . $value;
        return '<img src="' . htmlspecialchars($url) . '" alt="" style="height:36px;max-width:80px;object-fit:contain;">';
    }

    // -------------------------------------------------------------------------
    // FORM
    // -------------------------------------------------------------------------

    public function renderForm()
    {
        $logoPreview = '';
        if ($this->object && $this->object->logo) {
            $logoPreview = $this->object->getLogoUrl();
        }

        $this->fields_form = [
            'legend' => [
                'title' => $this->l('Organisme partenaire'),
                'icon'  => 'icon-building',
            ],
            'input' => [
                [
                    'type'     => 'text',
                    'label'    => $this->l('Nom de l\'organisme'),
                    'name'     => 'name',
                    'required' => true,
                    'col'      => 6,
                ],
                [
                    'type'  => 'text',
                    'label' => $this->l('Nom du représentant'),
                    'name'  => 'contact_name',
                    'col'   => 6,
                ],
                [
                    'type'  => 'text',
                    'label' => $this->l('Email du représentant'),
                    'name'  => 'contact_email',
                    'col'   => 5,
                ],
                [
                    'type'  => 'text',
                    'label' => $this->l('Téléphone du représentant'),
                    'name'  => 'contact_phone',
                    'col'   => 4,
                ],
                [
                    'type'  => 'text',
                    'label' => $this->l('Adresse'),
                    'name'  => 'address',
                    'col'   => 7,
                ],
                [
                    'type'  => 'file',
                    'label' => $this->l('Logo'),
                    'name'  => 'logo_upload',
                    'col'   => 6,
                    'desc'  => $this->l('Format JPG, PNG ou SVG. Taille max : 2 Mo.')
                        . ($logoPreview
                            ? '<br><img src="' . htmlspecialchars($logoPreview) . '" style="height:48px;margin-top:8px;object-fit:contain;">'
                            : ''),
                ],
                [
                    'type'    => 'switch',
                    'label'   => $this->l('Actif'),
                    'name'    => 'active',
                    'values'  => [
                        ['id' => 'active_on',  'value' => 1, 'label' => $this->l('Oui')],
                        ['id' => 'active_off', 'value' => 0, 'label' => $this->l('Non')],
                    ],
                ],
            ],
            'submit' => [
                'title' => $this->l('Enregistrer'),
            ],
        ];

        return parent::renderForm();
    }

    // -------------------------------------------------------------------------
    // LOGO UPLOAD HANDLING
    // -------------------------------------------------------------------------

    public function postProcess()
    {
        // Run parent first so $this->object is populated on add/update
        $result = parent::postProcess();

        if (
            (Tools::isSubmit('submitAdd' . $this->table) || Tools::isSubmit('submitAdd' . $this->table . 'AndStay'))
            && $this->object && Validate::isLoadedObject($this->object)
            && isset($_FILES['logo_upload']) && $_FILES['logo_upload']['error'] === UPLOAD_ERR_OK
        ) {
            $this->handleLogoUpload($this->object);
        }

        return $result;
    }

    private function handleLogoUpload(PaiementFaciliteOrganisation $org)
    {
        $file = $_FILES['logo_upload'];

        $allowedMimes = ['image/jpeg', 'image/png', 'image/svg+xml', 'image/gif', 'image/webp'];
        $allowedExts  = ['jpg', 'jpeg', 'png', 'svg', 'gif', 'webp'];
        $maxSize      = 2 * 1024 * 1024; // 2 MB

        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime  = $finfo->file($file['tmp_name']);
        $ext   = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));

        if (!in_array($mime, $allowedMimes) || !in_array($ext, $allowedExts)) {
            $this->errors[] = $this->l('Format de logo non autorisé (JPG, PNG, SVG uniquement).');
            return;
        }

        if ($file['size'] > $maxSize) {
            $this->errors[] = $this->l('Le logo dépasse la taille maximale de 2 Mo.');
            return;
        }

        $dir = _PS_MODULE_DIR_ . 'paiementfacilite/uploads/organisations/' . (int) $org->id . '/';
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        // Remove old logo file
        if ($org->logo && file_exists($dir . $org->logo)) {
            unlink($dir . $org->logo);
        }

        $filename = 'logo_' . uniqid() . '.' . $ext;
        if (!move_uploaded_file($file['tmp_name'], $dir . $filename)) {
            $this->errors[] = $this->l('Impossible de déplacer le fichier logo.');
            return;
        }

        $org->logo = $filename;
        $org->update();
    }
}
