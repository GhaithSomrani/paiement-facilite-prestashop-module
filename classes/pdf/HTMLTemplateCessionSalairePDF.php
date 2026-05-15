<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteRequest.php';
require_once _PS_MODULE_DIR_ . 'paiementfacilite/classes/PaiementFaciliteOrganisation.php';

class HTMLTemplateCessionSalairePDF
{
    /** @var PaiementFaciliteRequest */
    protected $request;
    /** @var Smarty */
    protected $smarty;
    /** @var Context */
    protected $context;

    public function __construct(PaiementFaciliteRequest $request, Smarty $smarty)
    {
        $this->request = $request;
        $this->smarty  = $smarty;
        $this->context = Context::getContext();
    }

    public function getContent()
    {
        $request  = $this->request;
        $customer = new Customer((int) $request->id_customer);
        $address  = new Address((int) $request->id_address);

        // Organisation label
        $org_name = '';
        if ($request->id_organisation) {
            $org = new PaiementFaciliteOrganisation((int) $request->id_organisation);
            if (Validate::isLoadedObject($org)) {
                $org_name = $org->name;
            }
        } elseif ($request->organisation_autre) {
            $org_name = $request->organisation_autre;
        }

        // CIN field — use gérant's CIN for companies
        $cin = $request->is_company ? $request->cin_gerant : $request->cin;

        // Matricule — fiscal for companies, empty for individuals
        $matricule = $request->is_company ? $request->matricule_fiscal : '';

        // Credit calculations
        $credit_reste = round((float) $request->credit_amount - (float) $request->premiere_tranche, 3);

        // Repayment period: 1st of next month → 1st of month nb_mois later
        $nb_mois = max(1, (int) $request->nb_mois);
        $start   = new DateTime('first day of next month');
        $end     = clone $start;
        $end->modify('+' . ($nb_mois - 1) . ' months');

        $period_start = $start->format('01/m/Y');
        $period_end   = $end->format('01/m/Y');

        // Shop info
        $logo_file = _PS_IMG_DIR_ . Configuration::get('PS_LOGO');
        $logo_path = file_exists($logo_file) ? str_replace('\\', '/', $logo_file) : '';

        $shop_name    = Configuration::get('PS_SHOP_NAME');
        $shop_email   = Configuration::get('PS_SHOP_EMAIL') ?: '';
        $shop_phone   = Configuration::get('PS_SHOP_PHONE') ?: '';
        $shop_details = Configuration::get('PS_SHOP_DETAILS') ?: '';
        $shop_city    = Configuration::get('PS_SHOP_CITY') ?: '';
        $shop_domain  = Configuration::get('PS_SHOP_DOMAIN') ?: '';

        $addr1 = Configuration::get('PS_SHOP_ADDR1') ?: '';
        $addr2 = Configuration::get('PS_SHOP_ADDR2') ?: '';
        $shop_addr = $addr1 . ($addr2 ? ' | ' . $addr2 : '');

        $this->smarty->assign([
            'cs_request'       => $request,
            'cs_customer'      => $customer,
            'cs_address'       => $address,
            'cs_org_name'      => $org_name,
            'cs_cin'           => $cin,
            'cs_matricule'     => $matricule,
            'cs_credit_reste'  => $credit_reste,
            'cs_period_start'  => $period_start,
            'cs_period_end'    => $period_end,
            'cs_logo_path'     => $logo_path,
            'cs_shop_name'     => $shop_name,
            'cs_shop_email'    => $shop_email,
            'cs_shop_phone'    => $shop_phone,
            'cs_shop_city'     => $shop_city,
            'cs_shop_domain'   => $shop_domain,
            'cs_shop_address'  => $shop_addr,
            'cs_shop_rc'       => $shop_details,
            'cs_date'          => date('d/m/Y'),
        ]);

        $tpl_path = _PS_MODULE_DIR_ . 'paiementfacilite/views/templates/pdf/cession_salaire.tpl';

        return $this->smarty->fetch($tpl_path);
    }

    public function getFilename()
    {
        return 'cession-salaire-' . (int) $this->request->id . '.pdf';
    }

    /**
     * Render and stream the PDF to the browser as a download.
     */
    public function render()
    {
        $html = $this->getContent();

        $tcpdf_path = _PS_ROOT_DIR_ . '/vendor/tecnickcom/tcpdf/tcpdf.php';
        if (!file_exists($tcpdf_path)) {
            $tcpdf_path = _PS_TOOL_DIR_ . 'tcpdf/tcpdf.php';
        }
        if (!class_exists('TCPDF')) {
            require_once $tcpdf_path;
        }

        $pdf = new TCPDF('P', 'mm', 'A4', true, 'UTF-8', false);
        $pdf->setPrintHeader(false);
        $pdf->setPrintFooter(false);
        // Leave 15 mm margins all around; bottom margin needs space for our footer table
        $pdf->SetMargins(15, 15, 15);
        $pdf->SetAutoPageBreak(true, 15);
        $pdf->SetFont('times', '', 12);
        $pdf->AddPage();
        $pdf->writeHTML($html, true, false, true, false, '');
        $pdf->Output($this->getFilename(), 'D');
        exit;
    }
}
