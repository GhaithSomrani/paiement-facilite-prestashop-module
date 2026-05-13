/**
 * paiementfacilite.js
 * Multi-step form logic, credit slider, address modal, document uploads
 */
(function ($) {
  'use strict';

  var PF = {
    currentStep: 1,
    totalSteps: 6,
    isCompany: false,
    isRetired: false,
    belongsToPartner: false,
    selectedAddressId: 0,
  };

  $(document).ready(function () {
    initErrors();
    initTypePicker();
    initOrgDropdown();
    initAddressStep();
    initCreditSlider();
    initDocumentUploads();
    initNavButtons();
    initAddressModal();
    updateProgressBar();
  });

  /* ── Errors from cookie ── */
  function initErrors() {
    if (typeof PF_CONFIG === 'undefined' || !PF_CONFIG.errorsJson) return;
    try {
      var errors = JSON.parse(PF_CONFIG.errorsJson);
      if (errors && errors.length) {
        showAlerts(errors, 'danger');
        document.cookie = 'pf_errors=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
      }
    } catch (e) {}
  }

  /* ── Step 1 — client type ── */
  function initTypePicker() {
    $('.pf-client-card').on('click', function () {
      $('.pf-client-card').removeClass('is-selected');
      $(this).addClass('is-selected');
      var val = $(this).data('value');
      $(this).find('input[type=radio]').prop('checked', true);
      PF.isCompany = (val == 1);
      toggleRetiredBlock();
      toggleCompanyFields();
    });

    // Retired toggle buttons
    $(document).on('click', '.pf-toggle-btn', function () {
      $(this).closest('.pf-toggle-row').find('.pf-toggle-btn').removeClass('is-selected');
      $(this).addClass('is-selected');
    });

    $('input[name=is_retired]').on('change', function () {
      PF.isRetired = $(this).val() == 1;
      toggleDocBlocks();
    });
  }

  function toggleRetiredBlock() {
    $('#pf-retired-block').toggle(!PF.isCompany);
  }

  function toggleCompanyFields() {
    if (PF.isCompany) {
      $('#pf-company-fields').show();
      $('#pf-company-fields input').prop('required', true);
    } else {
      $('#pf-company-fields').hide();
      $('#pf-company-fields input').prop('required', false);
    }
  }

  /* ── Step 2 — organisation ── */
  function initOrgDropdown() {
    $('#pf-org-select').on('change', function () {
      var val = parseInt($(this).val(), 10);
      if (val === -1) {
        $('#pf-org-autre-block').show();
        $('#pf-partner-notice').hide();
        PF.belongsToPartner = false;
      } else if (val > 0) {
        $('#pf-org-autre-block').hide();
        $('#pf-partner-notice').show();
        PF.belongsToPartner = true;
      } else {
        $('#pf-org-autre-block').hide();
        $('#pf-partner-notice').hide();
        PF.belongsToPartner = false;
      }
      $('#pf_belongs_to_partner').val(PF.belongsToPartner ? 1 : 0);
      updateDocsStep();
    });
  }

  function updateDocsStep() {
    if (PF.belongsToPartner) {
      $('.pf-doc-group').hide();
      $('#pf-docs-bypass').show();
      $('#pf-docs-step input[type=file]').removeAttr('required');
    } else {
      $('.pf-doc-group').show();
      $('#pf-docs-bypass').hide();
      toggleDocBlocks();
    }
  }

  function toggleDocBlocks() {
    if (PF.isRetired) {
      $('#pf-doc-salarie-block').hide();
      $('#pf-doc-retraite-block').show();
    } else {
      $('#pf-doc-salarie-block').show();
      $('#pf-doc-retraite-block').hide();
    }
  }

  /* ── Step 3 — address ── */
  function initAddressStep() {
    $('#pf-address-select').on('change', function () {
      var id = parseInt($(this).val(), 10);
      PF.selectedAddressId = id;
      $('#pf_id_address_hidden').val(id);
    });

    var initialId = parseInt($('#pf-address-select').val(), 10);
    if (initialId) {
      PF.selectedAddressId = initialId;
      $('#pf_id_address_hidden').val(initialId);
    }

    if (PF_CONFIG && !PF_CONFIG.hasAddresses) {
      $(document).on('pf:stepChanged', function (e, step) {
        if (step === 3) $('#pf-address-modal').modal('show');
      });
    }
  }

  /* ── Step 5 — credit slider ── */
  function initCreditSlider() {
    var $slider  = $('#pf-credit-slider');
    var $display = $('#pf-amount-display');
    var $tranche = $('#pf-tranche');
    var $mensual = $('#pf-mensualite');
    var $mDisp   = $('#pf-mensualite-display');

    function recalc() {
      var amount  = parseFloat($slider.val()) || 0;
      var minTr   = Math.ceil(amount * 0.20 * 100) / 100;
      var tranche = parseFloat($tranche.val()) || 0;

      // Update slider visual fill
      var pct = ((amount - $slider.attr('min')) / ($slider.attr('max') - $slider.attr('min'))) * 100;
      $slider.css('--fill', pct.toFixed(1) + '%');

      $display.text(amount.toFixed(0));

      $tranche.attr('min', minTr.toFixed(2));
      if (tranche < minTr || !$tranche.data('user-edited')) {
        $tranche.val(minTr.toFixed(2));
        tranche = minTr;
      }

      var mensualite = (amount - tranche) / 12;
      mensualite = mensualite > 0 ? Math.round(mensualite * 100) / 100 : 0;
      $mensual.val(mensualite.toFixed(2));
      $mDisp.text(mensualite.toFixed(2));
    }

    $slider.on('input change', recalc);
    $tranche.on('input', function () {
      $(this).data('user-edited', true);
      recalc();
    });

    recalc();
  }

  /* ── Step 6 — file pickers ── */
  function initDocumentUploads() {
    var MAX_SIZE = 5 * 1024 * 1024;

    // Wire existing file inputs
    wireFilePickers($('input[type=file]'), MAX_SIZE);

    // "+ Ajouter" clone buttons
    $(document).on('click', '.pf-add-more[data-target]', function () {
      var rowId  = $(this).data('target');
      var maxNum = parseInt($(this).data('max'), 10) || 3;
      var $row   = $('#' + rowId);
      if ($row.children('.pf-file-pick').length >= maxNum) return;

      var $first = $row.children('.pf-file-pick').first();
      var $clone = $first.clone();
      $clone.removeClass('has-file');
      $clone.find('.pf-file-btn').text('Choisir un fichier');
      $clone.find('.pf-file-name').text('');
      var $inp = $clone.find('input[type=file]');
      $inp.val('');
      $row.append($clone);
      wireFilePickers($inp, MAX_SIZE);
    });
  }

  function wireFilePickers($inputs, maxSize) {
    $inputs.on('change', function () {
      var $pick = $(this).closest('.pf-file-pick');
      var $btn  = $pick.find('.pf-file-btn');
      var $name = $pick.find('.pf-file-name');
      var file  = this.files && this.files[0];
      if (file) {
        if (file.size > maxSize) {
          $pick.addClass('has-file');
          $btn.text('Trop grand');
          $name.text(file.name + ' (max 5 MB)');
        } else {
          $pick.addClass('has-file');
          $btn.text('Fichier sélectionné');
          $name.text(file.name);
        }
      } else {
        $pick.removeClass('has-file');
        $btn.text('Choisir un fichier');
        $name.text('');
      }
    });
  }

  /* ── Navigation ── */
  function initNavButtons() {
    $(document).on('click', '.pf-next-btn', function () {
      if (!validateStep(PF.currentStep)) return;
      goTo(PF.currentStep + 1);
    });
    $(document).on('click', '.pf-prev-btn', function () {
      goTo(PF.currentStep - 1);
    });
  }

  function goTo(step) {
    if (step < 1 || step > PF.totalSteps) return;

    $('.pf-step-panel').removeClass('active');
    $('.pf-step-panel[data-step="' + step + '"]').addClass('active');
    $('.pf-step').removeClass('active completed');
    for (var i = 1; i < step; i++) {
      $('.pf-step[data-step="' + i + '"]').addClass('completed');
    }
    $('.pf-step[data-step="' + step + '"]').addClass('active');

    PF.currentStep = step;
    updateProgressBar();
    $(document).trigger('pf:stepChanged', [step]);
    $('html, body').animate({ scrollTop: $('.pf-stepper').offset().top - 80 }, 200);
  }

  function updateProgressBar() {
    var pct = Math.round((PF.currentStep / PF.totalSteps) * 100);
    $('#pf-progress-bar').css('width', pct + '%');
  }

  /* ── Step validation ── */
  function validateStep(step) {
    clearAlerts();
    var errors = [];

    switch (step) {
      case 1:
        if (!$('input[name=is_company]:checked').length) {
          errors.push('Veuillez sélectionner votre statut (Salarié/Retraité ou Société).');
        }
        break;

      case 2:
        if (parseInt($('#pf-org-select').val(), 10) === -1 && !$('#pf-org-autre').val().trim()) {
          errors.push("Veuillez préciser le nom de l'organisme.");
        }
        break;

      case 3:
        if (!$('#pf_id_address_hidden').val()) {
          errors.push('Veuillez sélectionner ou ajouter une adresse.');
        }
        break;

      case 4:
        if (!$('#pf-date-naissance').val())    errors.push('La date de naissance est obligatoire.');
        if (!$('#pf-fonction').val().trim())   errors.push('La fonction est obligatoire.');
        if (!$('#pf-cin').val().trim())        errors.push('Le numéro de CIN est obligatoire.');
        if (PF.isCompany) {
          if (!$('#pf-raison-sociale').val().trim())    errors.push('La raison sociale est obligatoire.');
          if (!$('#pf-matricule-fiscal').val().trim())  errors.push('Le matricule fiscal est obligatoire.');
          if (!$('#pf-representant-legal').val().trim())errors.push('Le représentant légal est obligatoire.');
          if (!$('#pf-cin-gerant').val().trim())        errors.push('Le CIN du gérant est obligatoire.');
          if (!$('#pf-date-naissance-gerant').val())    errors.push('La date de naissance du gérant est obligatoire.');
        }
        break;

      case 5:
        var amount  = parseFloat($('#pf-credit-slider').val()) || 0;
        var tranche = parseFloat($('#pf-tranche').val()) || 0;
        if (amount < PF_CONFIG.minAmount || amount > PF_CONFIG.maxAmount) {
          errors.push('Le montant doit être entre ' + PF_CONFIG.minAmount + ' DT et ' + PF_CONFIG.maxAmount + ' DT.');
        }
        if (tranche < amount * 0.20 - 0.01) {
          errors.push('La 1ère tranche doit représenter au minimum 20% du montant.');
        }
        break;

      case 6:
        if (!PF.belongsToPartner) {
          ['cin_recto', 'cin_verso', 'rib', 'facture_steg'].forEach(function (name) {
            var $inp = $('input[name="' + name + '"]');
            if ($inp.length && (!$inp[0].files || !$inp[0].files.length)) {
              errors.push('Le document "' + name.replace(/_/g, ' ') + '" est obligatoire.');
            }
          });
          if (PF.isRetired) {
            var $att = $('input[name=attestation_retraite]');
            if (!$att[0].files || !$att[0].files.length) errors.push("L'attestation de retraite est obligatoire.");
          } else {
            var $fp = $('input[name="fiche_paie[]"]').first();
            if (!$fp[0].files || !$fp[0].files.length) errors.push('Au moins une fiche de paie est obligatoire.');
          }
        }
        break;
    }

    if (errors.length) { showAlerts(errors, 'danger'); return false; }
    return true;
  }

  /* ── Address modal (AJAX) ── */
  function initAddressModal() {
    $('#pf-add-address-btn').on('click', function () {
      $('#pf-address-modal-form')[0].reset();
      $('#pf-address-modal-errors').hide().empty();
      $('#pf-address-modal').modal('show');
    });

    $('#pf-save-address-btn').on('click', function () {
      var $form    = $('#pf-address-modal-form');
      var $errBox  = $('#pf-address-modal-errors');
      var $spinner = $('#pf-save-address-spinner');
      $errBox.hide().empty();

      var missing = [];
      $form.find('[required]').each(function () {
        if (!$(this).val().trim()) missing.push($(this).prev('label').text().replace(' *','').trim());
      });
      if (missing.length) { $errBox.html('Champs obligatoires : ' + missing.join(', ')).show(); return; }

      $spinner.removeClass('d-none');
      $(this).prop('disabled', true);

      $.post(PF_CONFIG.ajaxUrl, $form.serialize() + '&action=saveAddress', function (resp) {
        $spinner.addClass('d-none');
        $('#pf-save-address-btn').prop('disabled', false);
        if (resp.success) {
          var $sel = $('#pf-address-select');
          $sel.empty();
          $.each(resp.addresses, function (i, addr) {
            var $opt = $('<option>').val(addr.id_address).text(addr.alias + ' — ' + addr.address1 + ', ' + addr.city);
            if (addr.id_address == resp.id_address) $opt.prop('selected', true);
            $sel.append($opt);
          });
          PF.selectedAddressId = resp.id_address;
          $('#pf_id_address_hidden').val(resp.id_address);
          $('#pf-address-modal').modal('hide');
          PF_CONFIG.hasAddresses = true;
        } else {
          $errBox.text(resp.error || 'Erreur inconnue.').show();
        }
      }, 'json').fail(function () {
        $spinner.addClass('d-none');
        $('#pf-save-address-btn').prop('disabled', false);
        $errBox.text('Erreur de connexion. Veuillez réessayer.').show();
      });
    });
  }

  /* ── Alert helpers ── */
  function showAlerts(messages, type) {
    var $box = $('#pf-alerts');
    var html = '<div class="pf-alert pf-alert-' + type + '"><ul style="margin:0;padding-left:18px;">';
    messages.forEach(function (m) { html += '<li>' + m + '</li>'; });
    html += '</ul></div>';
    $box.html(html);
    $('html, body').animate({ scrollTop: $box.offset().top - 80 }, 200);
  }

  function clearAlerts() { $('#pf-alerts').empty(); }

})(jQuery);
