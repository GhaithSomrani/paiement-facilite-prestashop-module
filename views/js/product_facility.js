/**
 * Copied from modules/pragmaproductsfacilities/views/js/dist/front.dev.js
 * (the body#product-scoped part only — the cart/checkout ajax refresh in
 * pragma's front.js depends on their own ajax controller, which this module
 * doesn't have).
 */
$(document).ready(function () {
  // Delegated (not bound once at ready) so it still works after the widget's
  // markup is replaced by refreshFacility().
  $(document).on('click', 'body#product .product-facilities-info input:radio', function () {
    if ($('body#product .product-price .product-discount').length > 0) {
      $('body#product .product-price .product-discount').hide();
    }

    $('body#product .product-price .current-price span').text($('#price_' + $(this).attr('id')).val());
  });

  if (typeof prestashop === 'undefined' || !$('body#product .pf-product-facility-wrapper').length) {
    return;
  }

  // PrestaShop core emits 'updatedProduct' after every combination change, with the
  // resolved id_product_attribute — the classic product form has no hidden input
  // holding it, so reading it from the DOM would send 0 (base product price).
  prestashop.on('updatedProduct', function (event) {
    var $wrapper = $('body#product .pf-product-facility-wrapper');
    if (!$wrapper.length || !$wrapper.data('pf-ajax-url')) {
      return;
    }

    $.get($wrapper.data('pf-ajax-url'), {
      id_product: parseInt($wrapper.data('pf-product-id'), 10) || 0,
      id_product_attribute: (event && parseInt(event.id_product_attribute, 10)) || 0
    }, function (resp) {
      if (resp && resp.success) {
        $('body#product .pf-product-facility-wrapper').replaceWith(resp.html);
      }
    }, 'json');
  });
});
