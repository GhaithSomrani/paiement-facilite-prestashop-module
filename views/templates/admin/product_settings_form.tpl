{* Admin — Create / Edit per-supplier "Paiement par facilité" setting *}

<form id="pf-supplier-setting-form" method="post" action="{$pf_form_action|escape:'html'}" class="form-horizontal">

  <input type="hidden" name="submitAddpf_supplier_settings" value="1">
  {if !$pf_is_add}
  <input type="hidden" name="id_supplier_setting" value="{$pf_obj->id|intval}">
  {/if}

  <div class="panel">
    <div class="panel-heading">
      <i class="icon-truck"></i>&nbsp;
      {if $pf_is_add}
        {l s='Nouveau fournisseur autorisé' mod='paiementfacilite'}
      {else}
        {l s='Modifier le fournisseur autorisé' mod='paiementfacilite'}
      {/if}
    </div>
    <div class="panel-body">

      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='Fournisseur' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-6" style="position:relative;">
          <input type="text" id="pf-supplier-search" class="form-control"
                 autocomplete="off"
                 placeholder="{l s='Tapez au moins 2 lettres…' mod='paiementfacilite'}"
                 value="{$pf_supplier_name|escape:'html'}">
          <input type="hidden" name="id_supplier" id="pf-id-supplier" value="{$pf_obj->id_supplier|intval}">
          <div id="pf-supplier-dropdown"></div>
        </div>
      </div>

      <div class="form-group">
        <label class="control-label col-lg-3">
          {l s='Mois max sur la fiche produit' mod='paiementfacilite'} <span class="required">*</span>
        </label>
        <div class="col-lg-3">
          <select name="max_months" class="form-control">
            {foreach $pf_month_options as $val => $label}
            <option value="{$val|intval}" {if $pf_obj->max_months == $val}selected="selected"{/if}>
              {$label|escape:'html'}
            </option>
            {/foreach}
          </select>
        </div>
      </div>

    </div>
    <div class="panel-footer">
      <button type="submit" name="submitAddpf_supplier_settings" class="btn btn-default pull-right">
        <i class="process-icon-save"></i> {l s='Enregistrer' mod='paiementfacilite'}
      </button>
    </div>
  </div>
</form>

<style>
#pf-supplier-dropdown {
  position: absolute; top: 100%; left: 0; right: 0; z-index: 9999;
  background: #fff; border: 1px solid #ccc; border-top: none;
  border-radius: 0 0 4px 4px; max-height: 260px; overflow-y: auto;
  box-shadow: 0 4px 10px rgba(0,0,0,.12); display: none;
}
#pf-supplier-dropdown .pf-ac-item {
  padding: 8px 12px; cursor: pointer; font-size: 13px;
  border-bottom: 1px solid #f0f0f0;
}
#pf-supplier-dropdown .pf-ac-item:last-child { border-bottom: none; }
#pf-supplier-dropdown .pf-ac-item:hover { background: #eef3ff; }
#pf-supplier-dropdown .pf-ac-loading { padding: 10px 12px; color: #999; font-style: italic; }
</style>

<script>
(function ($) {
  'use strict';

  var ajaxUrl = '{$pf_ajax_url|escape:"javascript"}';
  var currentSettingId = {$pf_obj->id|intval};
  var searchTimer = null;

  $('#pf-supplier-search').on('input', function () {
    var q = $(this).val().trim();
    $('#pf-id-supplier').val(0);
    clearTimeout(searchTimer);
    if (q.length < 2) {
      $('#pf-supplier-dropdown').hide().empty();
      return;
    }
    searchTimer = setTimeout(function () { doSearch(q); }, 300);
  }).on('focus', function () {
    if ($(this).val().trim().length >= 2) doSearch($(this).val().trim());
  });

  function doSearch(q) {
    var $dd = $('#pf-supplier-dropdown');
    $dd.html('<div class="pf-ac-loading">{l s='Recherche…' mod='paiementfacilite' js=1}</div>').show();
    $.getJSON(ajaxUrl + '&ajax=1&action=searchSuppliers', { q: q, id_supplier_setting: currentSettingId }, function (rows) {
      $dd.empty();
      if (!rows.length) {
        $dd.html('<div class="pf-ac-loading">{l s='Aucun résultat.' mod='paiementfacilite' js=1}</div>');
        return;
      }
      $.each(rows, function (i, r) {
        $('<div class="pf-ac-item">').text(r.label).data('row', r).appendTo($dd);
      });
    });
  }

  $(document).on('click', '#pf-supplier-dropdown .pf-ac-item', function () {
    var r = $(this).data('row');
    $('#pf-supplier-search').val(r.label);
    $('#pf-id-supplier').val(r.id);
    $('#pf-supplier-dropdown').hide().empty();
  });

  $(document).on('click', function (e) {
    if (!$(e.target).closest('#pf-supplier-search, #pf-supplier-dropdown').length) {
      $('#pf-supplier-dropdown').hide();
    }
  });
})(jQuery);
</script>
