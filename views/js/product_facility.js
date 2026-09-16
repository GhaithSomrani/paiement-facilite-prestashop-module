/**
 * Copied from modules/pragmaproductsfacilities/views/js/dist/front.dev.js
 * (the body#product-scoped part only — the cart/checkout ajax refresh in
 * pragma's front.js depends on their own ajax controller, which this module
 * doesn't have).
 */
$(document).ready(function () {
  $("body#product .product-facilities-info input:radio").click(function () {
    if ($("body#product .product-price .product-discount").length > 0) {
      $("body#product .product-price .product-discount").hide();
    }

    $("body#product .product-price .current-price span").text($("#price_" + $(this).attr('id')).val());
  });
});
