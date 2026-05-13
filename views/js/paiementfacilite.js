/**
 * paiementfacilite.js
 * Multi-step form logic, credit slider, address modal, document uploads
 */
(function ($) {
  'use strict';

  /* ──────────────────────────────────────────
     STATE
  ────────────────────────────────────────── */
  var PF = {
    currentStep: 1,
    totalSteps: 6,
    isCompany: false,
    isRetired: false,
    belongsToPartner: false,
    selectedAddressId: 0,
  };

  /* ──────────────────────────────────────────
     INIT
  ────────────────────────────────────────── */
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

  /* ──────────────────────────────────────────
     ERRORS (from cookie on previous submit)
  ────────────────────────────────────────── */
  function initErrors() {
    if (typeof PF_CONFIG === 'undefined') return;
    var raw = PF_CONFIG.errorsJson;
    if (!raw) return;
    try {
      var errors = JSON.parse(raw);
      if (errors && errors.length) {
        showAlerts(errors, 'danger');
        // Clear the cookie
        document.cookie = 'pf_errors=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
      }
    } catch (e) {}
  }

  /* ──────────────────────────────────────────
     STEP 1 — CLIENT TYPE
  ────────────────────────────────────────── */
  function initTypePicker() {
    $('.pf-type-card').on('click', function () {
      $('.pf-type-card').removeClass('selected');
      $(this).addClass('selected');
      var val = $(this).data('value');
      $(this).find('input[type=radio]').prop('checked', true);
      PF.isCompany = (val == 1);
      toggleRetiredBlock();
      toggleCompanyFields();
    });

    $('input[name=is_retired]').on('change', function () {
      PF.isRetired = $(this).val() == 1;
      toggleDocBlocks();
    });
  }

  function toggleRetiredBlock() {
    if (PF.isCompany) {
      $('#pf-retired-block').hide();
    } else {
      $('#pf-retired-block').show();
    }
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

  /* ──────────────────────────────────────────
     STEP 2 — ORGANISATION
  ────────────────────────────────────────── */
  function initOrgDropdown() {
    $('#pf-org-select').on('change', function () {
      var val = parseInt($(this).val(), 10);
      if (val === -1) {
        // "Autre"
        $('#pf-org-autre-block').show();
        $('#pf-partner-notice').hide();
        PF.belongsToPartner = false;
      } else if (val > 0) {
        // Partner org
        $('#pf-org-autre-block').hide();
        $('#pf-partner-notice').show();
        PF.belongsToPartner = true;
      } else {
        // "N'appartient à aucun"
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
      // Hide all upload widgets, show bypass message
      $('.pf-doc-group').hide();
      $('#pf-docs-bypass').show();
      // Remove required from file inputs
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

  /* ──────────────────────────────────────────
     STEP 3 — ADDRESS
  ────────────────────────────────────────── */
  function initAddressStep() {
    // Sync dropdown to hidden input
    $('#pf-address-select').on('change', function () {
      var id = parseInt($(this).val(), 10);
      PF.selectedAddressId = id;
      $('#pf_id_address_hidden').val(id);
    });

    // Trigger initial sync
    var initialId = parseInt($('#pf-address-select').val(), 10);
    if (initialId) {
      PF.selectedAddressId = initialId;
      $('#pf_id_address_hidden').val(initialId);
    }

    // If no addresses → open modal immediately when reaching step 3
    if (PF_CONFIG && !PF_CONFIG.hasAddresses) {
      $(document).on('pf:stepChanged', function (e, step) {
        if (step === 3) {
          $('#pf-address-modal').modal('show');
        }
      });
    }
  }

  /* ──────────────────────────────────────────
     STEP 5 — CREDIT SLIDER
  ────────────────────────────────────────── */
  function initCreditSlider() {
    var $slider   = $('#pf-credit-slider');
    var $display  = $('#pf-amount-display');
    var $tranche  = $('#pf-tranche');
    var $mensual  = $('#pf-mensualite');
    var $mDisplay = $('#pf-mensualite-display');
    var $tDisplay = $('#pf-total-display');

    function recalc() {
      var amount  = parseFloat($slider.val()) || 0;
      var minTr   = Math.ceil(amount * 0.20 * 100) / 100;
      var tranche = parseFloat($tranche.val()) || 0;

      $display.text(amount.toFixed(0) + ' DT');
      $tDisplay.text(amount.toFixed(2) + ' DT');

      // Enforce minimum tranche
      $tranche.attr('min', minTr.toFixed(2));
      if (tranche < minTr || !$tranche.data('user-edited')) {
        $tranche.val(minTr.toFixed(2));
        tranche = minTr;
      }

      var mensualite = (amount - tranche) / 12;
      mensualite = mensualite > 0 ? Math.round(mensualite * 100) / 100 : 0;
      $mensual.val(mensualite.toFixed(2));
      $mDisplay.text(mensualite.toFixed(2) + ' DT');
    }

    $slider.on('input change', recalc);
    $tranche.on('input', function () {
      $(this).data('user-edited', true);
      recalc();
    });

    // Init
    recalc();
  }

  /* ──────────────────────────────────────────
     STEP 6 — DOCUMENT UPLOADS
  ────────────────────────────────────────── */
  function initDocumentUploads() {
    var MAX_SIZE = 5 * 1024 * 1024;

    $('input[type=file]').each(function () {
      var $input   = $(this);
      var $zone    = $input.closest('.pf-upload-zone');
      var listId   = $input.attr('id');
      var $list    = $zone.find('.pf-file-list');
      var maxFiles = parseInt($input.data('max-files'), 10) || 1;

      // Drag-and-drop
      $zone.on('dragover', function (e) {
        e.preventDefault();
        $(this).addClass('dragover');
      }).on('dragleave drop', function (e) {
        e.preventDefault();
        $(this).removeClass('dragover');
        if (e.type === 'drop') {
          var files = e.originalEvent.dataTransfer.files;
          renderFiles($list, files, maxFiles, MAX_SIZE);
        }
      });

      $input.on('change', function () {
        renderFiles($list, this.files, maxFiles, MAX_SIZE);
      });
    });

    function renderFiles($list, files, maxFiles, maxSize) {
      $list.empty();
      var count = 0;
      for (var i = 0; i < files.length && count < maxFiles; i++) {
        var f = files[i];
        var ok = true;
        var msg = '';
        if (f.size > maxSize) {
          ok = false;
          msg = ' (Trop grand — max 5 MB)';
        }
        var icon = ok ? '✓' : '✗';
        var cls  = ok ? 'text-success' : 'text-danger';
        $list.append(
          '<div class="pf-file-item ' + cls + '">' + icon + ' ' + escHtml(f.name) + msg + '</div>'
        );
        count++;
      }
    }

    function escHtml(s) {
      return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
  }

  /* ──────────────────────────────────────────
     NAVIGATION BUTTONS
  ────────────────────────────────────────── */
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

    // Skip docs step if partner org
    if (step === 6 && PF.belongsToPartner) {
      // Still show step 6 but with bypass message — handled by updateDocsStep()
    }

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
    $('html, body').animate({ scrollTop: $('.pf-progress').offset().top - 80 }, 200);
  }

  function updateProgressBar() {
    var pct = Math.round((PF.currentStep / PF.totalSteps) * 100);
    $('#pf-progress-bar').css('width', pct + '%').attr('aria-valuenow', pct);
  }

  /* ──────────────────────────────────────────
     STEP VALIDATION
  ────────────────────────────────────────── */
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
        var orgVal = parseInt($('#pf-org-select').val(), 10);
        if (orgVal === -1 && !$('#pf-org-autre').val().trim()) {
          errors.push("Veuillez préciser le nom de l'organisme.");
        }
        break;

      case 3:
        if (!$('#pf_id_address_hidden').val()) {
          errors.push('Veuillez sélectionner ou ajouter une adresse.');
        }
        break;

      case 4:
        if (!$('#pf-date-naissance').val()) {
          errors.push('La date de naissance est obligatoire.');
        }
        if (!$('#pf-fonction').val().trim()) {
          errors.push('La fonction est obligatoire.');
        }
        if (!$('#pf-cin').val().trim()) {
          errors.push('Le numéro de CIN est obligatoire.');
        }
        if (PF.isCompany) {
          if (!$('#pf-raison-sociale').val().trim()) errors.push('La raison sociale est obligatoire.');
          if (!$('#pf-matricule-fiscal').val().trim()) errors.push('Le matricule fiscal est obligatoire.');
          if (!$('#pf-representant-legal').val().trim()) errors.push('Le représentant légal est obligatoire.');
          if (!$('#pf-cin-gerant').val().trim()) errors.push('Le CIN du gérant est obligatoire.');
          if (!$('#pf-date-naissance-gerant').val()) errors.push('La date de naissance du gérant est obligatoire.');
        }
        break;

      case 5:
        var amount = parseFloat($('#pf-credit-slider').val()) || 0;
        var tranche = parseFloat($('#pf-tranche').val()) || 0;
        var min = PF_CONFIG.minAmount;
        var max = PF_CONFIG.maxAmount;
        if (amount < min || amount > max) {
          errors.push('Le montant doit être entre ' + min + ' DT et ' + max + ' DT.');
        }
        if (tranche < amount * 0.20 - 0.01) {
          errors.push('La 1ère tranche doit représenter au minimum 20% du montant.');
        }
        break;

      case 6:
        if (!PF.belongsToPartner) {
          // Check mandatory single-file uploads
          var mandatory = ['cin_recto', 'cin_verso', 'rib', 'facture_steg'];
          mandatory.forEach(function (name) {
            var $inp = $('input[name="' + name + '"]');
            if ($inp.length && (!$inp[0].files || !$inp[0].files.length)) {
              errors.push('Le document "' + name.replace(/_/g, ' ') + '" est obligatoire.');
            }
          });
          // Fiches de paie OR attestation
          if (PF.isRetired) {
            var $att = $('input[name=attestation_retraite]');
            if (!$att[0].files || !$att[0].files.length) {
              errors.push("L'attestation de retraite est obligatoire.");
            }
          } else {
            var $fp = $('input[name="fiche_paie[]"]');
            if (!$fp[0].files || !$fp[0].files.length) {
              errors.push('Au moins une fiche de paie est obligatoire.');
            }
          }
        }
        break;
    }

    if (errors.length) {
      showAlerts(errors, 'danger');
      return false;
    }
    return true;
  }

  /* ──────────────────────────────────────────
     ADDRESS MODAL (AJAX)
  ────────────────────────────────────────── */
  function initAddressModal() {
    $('#pf-add-address-btn').on('click', function () {
      $('#pf-address-modal-form')[0].reset();
      $('#pf-address-modal-errors').hide().empty();
      $('#pf-address-modal').modal('show');
    });

    $('#pf-save-address-btn').on('click', function () {
      var $form   = $('#pf-address-modal-form');
      var $errBox = $('#pf-address-modal-errors');
      var $spinner = $('#pf-save-address-spinner');

      $errBox.hide().empty();

      // Client-side required check
      var missing = [];
      $form.find('[required]').each(function () {
        if (!$(this).val().trim()) {
          missing.push($(this).prev('label').text().replace(' *', '').trim());
        }
      });
      if (missing.length) {
        $errBox.html('Champs obligatoires : ' + missing.join(', ')).show();
        return;
      }

      $spinner.removeClass('d-none');
      $(this).prop('disabled', true);

      var data = $form.serialize() + '&action=saveAddress';

      $.post(PF_CONFIG.ajaxUrl, data, function (resp) {
        $spinner.addClass('d-none');
        $('#pf-save-address-btn').prop('disabled', false);

        if (resp.success) {
          // Rebuild address dropdown
          var $select = $('#pf-address-select');
          $select.empty();
          $.each(resp.addresses, function (i, addr) {
            var opt = $('<option>')
              .val(addr.id_address)
              .text(addr.alias + ' — ' + addr.address1 + ', ' + addr.city);
            if (addr.id_address == resp.id_address) opt.prop('selected', true);
            $select.append(opt);
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

  /* ──────────────────────────────────────────
     ALERT HELPERS
  ────────────────────────────────────────── */
  function showAlerts(messages, type) {
    var $box = $('#pf-alerts');
    var html = '<div class="alert alert-' + type + ' alert-dismissible"><ul class="mb-0">';
    messages.forEach(function (m) {
      html += '<li>' + m + '</li>';
    });
    html += '</ul><button type="button" class="close" data-dismiss="alert">&times;</button></div>';
    $box.html(html);
    $('html, body').animate({ scrollTop: $box.offset().top - 80 }, 200);
  }

  function clearAlerts() {
    $('#pf-alerts').empty();
  }

})(jQuery);
