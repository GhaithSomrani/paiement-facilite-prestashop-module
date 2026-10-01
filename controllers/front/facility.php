<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

/**
 * Re-renders the product_facility widget for a given product/combination.
 * Called by views/js/product_facility.js whenever the displayed price changes
 * (e.g. the customer switches variant) so the facility amounts stay in sync —
 * no login required, same as any other product-page price display.
 */
class PaiementFaciliteFacilityModuleFrontController extends ModuleFrontController
{
    public $ssl = true;

    public function initContent()
    {
        $id_product = (int) Tools::getValue('id_product');
        $id_product_attribute = (int) Tools::getValue('id_product_attribute');

        header('Content-Type: application/json');

        if (!$id_product || !Validate::isLoadedObject(new Product($id_product))) {
            die(json_encode(['success' => false]));
        }

        $price = Product::getPriceStatic($id_product, true, $id_product_attribute ?: null);

        die(json_encode([
            'success' => true,
            'html'    => $this->module->renderProductFacility($id_product, $id_product_attribute, $price),
        ]));
    }
}
