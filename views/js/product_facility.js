/**
 * Copied from modules/pragmaproductsfacilities/views/js/dist/front.dev.js
 * (the body#product-scoped part only — the cart/checkout ajax refresh in
 * pragma's front.js depends on their own ajax controller, which this module
 * doesn't have).
 */
$(document).ready(function () {
  // Set right before our own click handler edits .current-price (a mensualité
  // preview, not a real price change) so the MutationObserver below ignores the
  // mutation it causes instead of treating it as a variant-driven price change.
  var suppressNextPriceMutation = false;

  // Delegated (not bound once at ready) so it still works after refreshFacility()
  // replaces the widget's markup with a freshly rendered version.
  $(document).on('click', 'body#product .product-facilities-info input:radio', function () {
    if ($('body#product .product-price .product-discount').length > 0) {
      $('body#product .product-price .product-discount').hide();
    }

    suppressNextPriceMutation = true;
    $('body#product .product-price .current-price span').text($('#price_' + $(this).attr('id')).val());
  });

  // Re-render the facility widget whenever the displayed price changes (e.g. the
  // customer switches a variant/combination) so the amounts don't stay frozen on
  // whatever combination was selected when the page first loaded.
  //
  // Observed on body#product itself rather than on .current-price directly: most
  // themes re-render the whole price block (replacing .current-price with a new
  // node) instead of just editing its text, and a MutationObserver bound to a node
  // that gets detached from the DOM stops firing — watching a stable ancestor with
  // subtree:true still catches that replacement.
  var priceRoot = document.querySelector('body#product');
  if (!priceRoot) {
    return;
  }

  var $wrapper = $('body#product .pf-product-facility-wrapper');
  if (!$wrapper.length || !$wrapper.data('pf-ajax-url')) {
    return;
  }

  var idProduct = parseInt($wrapper.data('pf-product-id'), 10) || 0;
  var ajaxUrl = $wrapper.data('pf-ajax-url');
  var debounceTimer = null;

  function getPriceText() {
    var $p = $('body#product .product-price .current-price');
    return $p.length ? $.trim($p.text()) : null;
  }

  var lastPriceText = getPriceText();

  function getCurrentAttributeId() {
    var $combo = $('#idCombination, input[name="id_product_attribute"]').first();
    return $combo.length ? (parseInt($combo.val(), 10) || 0) : 0;
  }

  function refreshFacility() {
    // Our own AJAX swap of .pf-product-facility-wrapper is itself a mutation inside
    // body#product, so re-check the price actually changed before firing another
    // request — otherwise this would refresh in an endless loop.
    var currentPriceText = getPriceText();
    if (currentPriceText === lastPriceText) {
      return;
    }
    lastPriceText = currentPriceText;

    $.get(ajaxUrl, {
      id_product: idProduct,
      id_product_attribute: getCurrentAttributeId()
    }, function (resp) {
      if (resp && resp.success) {
        $('body#product .pf-product-facility-wrapper').replaceWith(resp.html);
      }
    }, 'json');
  }

  new MutationObserver(function () {
    if (suppressNextPriceMutation) {
      suppressNextPriceMutation = false;
      return;
    }
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(refreshFacility, 150);
  }).observe(priceRoot, { childList: true, characterData: true, subtree: true });
});
