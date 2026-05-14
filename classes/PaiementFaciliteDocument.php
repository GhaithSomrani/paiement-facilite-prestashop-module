<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class PaiementFaciliteDocument extends ObjectModel
{
    /** @var int */
    public $id_request;
    /** @var string */
    public $doc_type;
    /** @var string */
    public $filename;
    /** @var string */
    public $date_add;
    /** @var string */
    public $date_upd;

    public static $definition = [
        'table'   => 'pf_documents',
        'primary' => 'id_document',
        'fields'  => [
            'id_request' => ['type' => self::TYPE_INT,    'validate' => 'isUnsignedId', 'required' => true],
            'doc_type'   => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 64],
            'filename'   => ['type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 255],
            'date_add'   => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
            'date_upd'   => ['type' => self::TYPE_DATE,   'validate' => 'isDate'],
        ],
    ];

    // Document type constants — individual
    const TYPE_FICHE_PAIE          = 'fiche_paie';
    const TYPE_ATTESTATION         = 'attestation_retraite';
    // Document type constants — company
    const TYPE_COPIE_RNE           = 'copie_rne';
    const TYPE_REGISTRE_COMMERCE   = 'registre_commerce';
    const TYPE_STATUTS             = 'statuts_societe';
    // Document type constants — common
    const TYPE_CIN_RECTO           = 'cin_recto';
    const TYPE_CIN_VERSO           = 'cin_verso';
    const TYPE_RIB                 = 'rib';
    const TYPE_RELEVE_BANCAIRE     = 'releve_bancaire';
    const TYPE_FACTURE_STEG        = 'facture_steg';

    public static $allowed_types = [
        self::TYPE_FICHE_PAIE,
        self::TYPE_ATTESTATION,
        self::TYPE_COPIE_RNE,
        self::TYPE_REGISTRE_COMMERCE,
        self::TYPE_STATUTS,
        self::TYPE_CIN_RECTO,
        self::TYPE_CIN_VERSO,
        self::TYPE_RIB,
        self::TYPE_RELEVE_BANCAIRE,
        self::TYPE_FACTURE_STEG,
    ];

    /**
     * Handle an uploaded file, move to uploads dir, persist to DB.
     *
     * @param int    $id_request
     * @param string $doc_type
     * @param array  $file  $_FILES element
     *
     * @return PaiementFaciliteDocument|false
     */
    public static function saveUpload($id_request, $doc_type, array $file)
    {
        if ($file['error'] !== UPLOAD_ERR_OK) {
            return false;
        }

        $allowed_mime = ['image/jpeg', 'image/png', 'application/pdf'];
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($file['tmp_name']);

        if (!in_array($mime, $allowed_mime)) {
            return false;
        }

        if ($file['size'] > 5 * 1024 * 1024) {
            return false;
        }

        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $safe_ext = strtolower($ext);
        if (!in_array($safe_ext, ['jpg', 'jpeg', 'png', 'pdf'])) {
            return false;
        }

        $upload_dir = _PS_MODULE_DIR_ . 'paiementfacilite/uploads/' . (int) $id_request . '/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }

        $filename = $doc_type . '_' . uniqid() . '.' . $safe_ext;
        $dest = $upload_dir . $filename;

        if (!move_uploaded_file($file['tmp_name'], $dest)) {
            return false;
        }

        $doc = new PaiementFaciliteDocument();
        $doc->id_request = (int) $id_request;
        $doc->doc_type   = $doc_type;
        $doc->filename   = $filename;

        return $doc->add() ? $doc : false;
    }

    /**
     * Absolute path to this document's file.
     */
    public function getFilePath()
    {
        return _PS_MODULE_DIR_ . 'paiementfacilite/uploads/' . (int) $this->id_request . '/' . $this->filename;
    }
}
