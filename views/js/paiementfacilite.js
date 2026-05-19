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

  var DRAFT_KEY = 'pf_draft';

  $(document).ready(function () {
    initErrors();
    initTypePicker();
    initOrgDropdown();
    initAddressStep();
    initCreditSlider();
    initDocumentUploads();
    initNavButtons();
    initAddressModal();
    initDraft();
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
      toggleDocBlocks();
      $('#pf-org-select').trigger('change');
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
      $('#pf-personal-fields').hide();
      $('#pf-company-fields').show();
      $('#pf-step4-title').text('Informations de la société');
    } else {
      $('#pf-personal-fields').show();
      $('#pf-company-fields').hide();
      $('#pf-step4-title').text('Informations personnelles');
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
        // val === 0 (Aucun) — for companies, still show the org-name field
        $('#pf-org-autre-block').toggle(PF.isCompany);
        $('#pf-partner-notice').hide();
        PF.belongsToPartner = false;
      }
      $('#pf_belongs_to_partner').val(PF.belongsToPartner ? 1 : 0);
      updateDocsStep();
      updatePartnerNavigation();
    });
  }

  function updatePartnerNavigation() {
    // All users including partner-org members now go through all steps
    $('#pf-step5-next').show();
    $('#pf-step5-submit').hide();
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
    if (PF.isCompany) {
      $('#pf-doc-salarie-block').hide();
      $('#pf-doc-retraite-block').hide();
      $('#pf-doc-individual-common').hide();
      $('#pf-doc-societe-block').show();
    } else {
      $('#pf-doc-societe-block').hide();
      $('#pf-doc-individual-common').show();
      if (PF.isRetired) {
        $('#pf-doc-salarie-block').hide();
        $('#pf-doc-retraite-block').show();
      } else {
        $('#pf-doc-salarie-block').show();
        $('#pf-doc-retraite-block').hide();
      }
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

  /* ── Step 5 — credit slider + month selector ── */
  function initCreditSlider() {
    var $slider   = $('#pf-credit-slider');
    var $display  = $('#pf-amount-display');
    var $tranche  = $('#pf-tranche');
    var $mensual  = $('#pf-mensualite');
    var $mDisp    = $('#pf-mensualite-display');
    var $moisDisp = $('#pf-mois-display');

    // monthConfigs is keyed by nb_mois (string): {minAmount, interestRate}
    var monthConfigs = (PF_CONFIG && PF_CONFIG.monthConfigs) ? PF_CONFIG.monthConfigs : {};

    function getNbMois() {
      var val = parseInt($('input[name=nb_mois]:checked').val(), 10);
      return val > 0 ? val : 12;
    }

    // Return config for nb_mois, or null if no config defined
    function getMonthConfig(nbMois) {
      return monthConfigs[String(nbMois)] || null;
    }

    // Enable/disable each month button: disabled when credit < min_amount for that month.
    // Auto-selects the first available month if the current selection becomes disabled.
    function updateMonthButtons(amount) {
      var currentMois  = getNbMois();
      var currentValid = true;

      $('#pf-mois-row .pf-toggle-btn').each(function () {
        var m   = parseInt($(this).data('mois'), 10);
        var cfg = getMonthConfig(m);
        var ok  = !cfg || (amount >= cfg.minAmount);

        if (ok) {
          $(this).removeClass('pf-mois-disabled').prop('disabled', false);
        } else {
          $(this).addClass('pf-mois-disabled').prop('disabled', true);
          if (m === currentMois) currentValid = false;
        }
      });

      // If selected month is no longer valid, pick the first available one
      if (!currentValid) {
        var $first = $('#pf-mois-row .pf-toggle-btn:not(.pf-mois-disabled)').first();
        if ($first.length) {
          $('#pf-mois-row .pf-toggle-btn').removeClass('is-selected');
          $first.addClass('is-selected');
          $first.find('input[type=radio]').prop('checked', true);
        }
      }
    }

    function recalc() {
      var amount  = parseFloat($slider.val()) || 0;
      var tranche = parseFloat($tranche.val()) || 0;

      // Update month button availability for this amount, then read selection
      updateMonthButtons(amount);
      var nbMois = getNbMois();

      // Interest rate comes from the selected month's config (0 for partner-org members)
      var cfg          = getMonthConfig(nbMois);
      var interestRate = (!PF.belongsToPartner && cfg) ? cfg.interestRate : 0;

      // Total cost = full credit × (1 + rate%)
      var totalWithInterest = Math.round(amount * (1 + interestRate / 100) * 10000) / 10000;

      // Minimum première tranche = total ÷ nb_mois
      var minTr = Math.round(totalWithInterest / nbMois * 100) / 100;

      // Update slider fill (range inputs only)
      if ($slider.attr('type') === 'range') {
        var pct = ((amount - parseFloat($slider.attr('min'))) /
                   (parseFloat($slider.attr('max')) - parseFloat($slider.attr('min')))) * 100;
        $slider.css('--fill', pct.toFixed(1) + '%');
      }

      $display.text(amount.toFixed(0));
      $moisDisp.text(nbMois - 1);

      $tranche.attr('min', minTr.toFixed(2));
      if (!$tranche.data('user-edited')) {
        $tranche.val(minTr.toFixed(2));
      }

      // Show inline error if tranche is below minimum, but don't override the value
      var trancheVal = parseFloat($tranche.val()) || 0;
      var $trancheErr = $('#pf-tranche-error');
      if ($tranche.data('user-edited') && trancheVal < minTr) {
        $trancheErr.text('Montant minimum : ' + minTr.toFixed(2) + ' DT').show();
        $tranche.css('border-color', '#c0392b');
        trancheVal = minTr; // use min for mensualité display only
      } else {
        $trancheErr.hide();
        $tranche.css('border-color', '');
      }

      var mensualite = (nbMois > 1)
        ? Math.round((totalWithInterest - trancheVal) / (nbMois - 1) * 100) / 100
        : 0;

      $mensual.val(mensualite.toFixed(2));
      $mDisp.text(mensualite.toFixed(2));

      // Interest info badge
      var $badge = $('#pf-interest-badge');
      if ($badge.length) {
        if (interestRate > 0) {
          var interestAmt = Math.round((totalWithInterest - amount) * 100) / 100;
          $badge
            .html('Total avec intérêts&nbsp;: <strong>' + totalWithInterest.toFixed(2) + ' DT</strong>' +
                  ' &mdash; Taux&nbsp;: <strong>' + interestRate.toFixed(2) + ' %</strong>' +
                  ' &mdash; Intérêts&nbsp;: <strong>' + interestAmt.toFixed(2) + ' DT</strong>')
            .show();
        } else {
          $badge.hide();
        }
      }

      // Store resolved rate for form submission (server re-validates independently)
      $('#pf-interest-rate').val(interestRate.toFixed(2));
    }

    $slider.on('input change', function () {
      $tranche.data('user-edited', false);
      recalc();
    });
    $tranche.on('input', function () {
      $(this).data('user-edited', true);
      recalc();
    });
    $('#pf-mois-row').on('click', '.pf-toggle-btn', function () {
      if ($(this).hasClass('pf-mois-disabled')) return false;
      $('#pf-mois-row .pf-toggle-btn').removeClass('is-selected');
      $(this).addClass('is-selected');
      $(this).find('input[type=radio]').prop('checked', true);
      $tranche.data('user-edited', false);
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
  function getNextStep(step) {
    var next = step + 1;
    if (PF_CONFIG.isFromCheckout && next === 3) next = 4;
    return next;
  }

  function getPrevStep(step) {
    var prev = step - 1;
    if (PF_CONFIG.isFromCheckout && prev === 3) prev = 2;
    return prev;
  }

  function initNavButtons() {
    $(document).on('click', '.pf-next-btn', function () {
      if (!validateStep(PF.currentStep)) return;
      var next = getNextStep(PF.currentStep);
      saveDraft(next);
      goTo(next);
    });
    $(document).on('click', '.pf-prev-btn', function () {
      goTo(getPrevStep(PF.currentStep));
    });
    // Clear draft on final submission
    $('#pf-form').on('submit', function () {
      try { localStorage.removeItem(DRAFT_KEY); } catch (e) {}
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
        if (PF.isCompany) {
          if (!$('#pf-raison-sociale').val().trim())      errors.push('La raison sociale est obligatoire.');
          if (!$('#pf-representant-legal').val().trim())  errors.push('Le représentant légal est obligatoire.');
          if (!$('#pf-date-naissance-gerant').val())      errors.push('La date de naissance du gérant est obligatoire.');
          if (!$('#pf-telephone-gerant').val().trim())    errors.push('Le numéro de téléphone est obligatoire.');
          if (!$('#pf-email-gerant').val().trim())        errors.push("L'adresse email est obligatoire.");
          if (!$('#pf-cin-gerant').val().trim())          errors.push("Le numéro de CIN du gérant est obligatoire.");
        } else {
          if (!$('#pf-date-naissance').val())  errors.push('La date de naissance est obligatoire.');
          if (!$('#pf-cin').val().trim())      errors.push('Le numéro de CIN est obligatoire.');
          if (!$('#pf-fonction').val().trim()) errors.push('La fonction / profession est obligatoire.');
        }
        break;

      case 5:
        var amount  = parseFloat($('#pf-credit-slider').val()) || 0;
        var tranche = parseFloat($('#pf-tranche').val()) || 0;
        var nbMoisV = parseInt($('input[name=nb_mois]:checked').val(), 10) || 12;
        var cfgV    = (PF_CONFIG.monthConfigs && PF_CONFIG.monthConfigs[String(nbMoisV)]) || null;
        var rateV   = cfgV ? cfgV.interestRate : 0;
        var totalV  = Math.round(amount * (1 + rateV / 100) * 10000) / 10000;
        // Only check min/max range for standalone (free-slider) requests
        if (!PF_CONFIG.isFromCheckout && (amount < PF_CONFIG.minAmount || amount > PF_CONFIG.maxAmount)) {
          errors.push('Le montant doit être entre ' + PF_CONFIG.minAmount + ' DT et ' + PF_CONFIG.maxAmount + ' DT.');
        }
        // Min tranche = total / nb_mois
        var minTrV = Math.round(totalV / nbMoisV * 100) / 100;
        if (tranche < minTrV - 0.01) {
          errors.push('La 1ère tranche minimum est ' + minTrV.toFixed(2) + ' DT (total ÷ ' + nbMoisV + ' mois).');
        }
        break;

      case 6:
        if (!PF.belongsToPartner) {
          // Common for everyone: rib + at least one relevé
          var $rib = $('input[name="rib"]');
          if ($rib.length && (!$rib[0].files || !$rib[0].files.length)) {
            errors.push("L'identité bancaire (RIB) est obligatoire.");
          }
          var $releve = $('input[name="releve_bancaire[]"]').first();
          if ($releve.length && (!$releve[0].files || !$releve[0].files.length)) {
            errors.push('Au moins un relevé bancaire est obligatoire.');
          }

          if (PF.isCompany) {
            var $rne = $('input[name="copie_rne"]');
            if ($rne.length && (!$rne[0].files || !$rne[0].files.length)) {
              errors.push('La copie du RNE est obligatoire.');
            }
            var $cgr = $('input[name="cin_gerant_recto"]');
            if ($cgr.length && (!$cgr[0].files || !$cgr[0].files.length)) {
              errors.push("La carte d'identité du gérant (recto) est obligatoire.");
            }
            var $cgv = $('input[name="cin_gerant_verso"]');
            if ($cgv.length && (!$cgv[0].files || !$cgv[0].files.length)) {
              errors.push("La carte d'identité du gérant (verso) est obligatoire.");
            }
          } else {
            // Individual: CIN + facture STEG
            var $cr = $('input[name="cin_recto"]');
            if ($cr.length && (!$cr[0].files || !$cr[0].files.length)) {
              errors.push('La CIN recto est obligatoire.');
            }
            var $cv = $('input[name="cin_verso"]');
            if ($cv.length && (!$cv[0].files || !$cv[0].files.length)) {
              errors.push('La CIN verso est obligatoire.');
            }
            var $fs = $('input[name="facture_steg"]');
            if ($fs.length && (!$fs[0].files || !$fs[0].files.length)) {
              errors.push('La facture STEG / SONEDE est obligatoire.');
            }
            if (PF.isRetired) {
              var $att = $('input[name="attestation_retraite"]');
              if ($att.length && (!$att[0].files || !$att[0].files.length)) {
                errors.push("L'attestation de retraite est obligatoire.");
              }
            } else {
              var $fp = $('input[name="fiche_paie[]"]').first();
              if ($fp.length && (!$fp[0].files || !$fp[0].files.length)) {
                errors.push('Au moins une fiche de paie est obligatoire.');
              }
            }
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

  /* ── Draft save / restore (localStorage) ── */

  function initDraft() {
    // Clear any draft when the user lands on the confirmation page
    if (window.location.search.indexOf('confirmed=1') !== -1) {
      try { localStorage.removeItem(DRAFT_KEY); } catch (e) {}
      return;
    }
    if (typeof PF_CONFIG === 'undefined') return;
    var raw;
    try { raw = localStorage.getItem(DRAFT_KEY); } catch (e) { return; }
    if (!raw) return;
    try {
      var draft = JSON.parse(raw);
      if (draft && parseInt(draft.current_step) > 1) {
        showDraftBanner(draft);
      } else {
        localStorage.removeItem(DRAFT_KEY);
      }
    } catch (e) {
      try { localStorage.removeItem(DRAFT_KEY); } catch (e2) {}
    }
  }

  function showDraftBanner(draft) {
    var $banner = $('#pf-draft-banner');
    if (!$banner.length) return;
    $banner.find('.pf-draft-step').text(draft.current_step);
    $banner.show();

    $('#pf-resume-btn').on('click', function () {
      restoreDraft(draft);
      $banner.slideUp();
    });

    $('#pf-restart-btn').on('click', function () {
      try { localStorage.removeItem(DRAFT_KEY); } catch (e) {}
      $banner.slideUp();
    });
  }

  function saveDraft(nextStep) {
    var data = {
      current_step:          nextStep,
      is_company:            $('input[name=is_company]:checked').val()  || '0',
      is_retired:            $('input[name=is_retired]:checked').val()   || '0',
      belongs_to_partner:    $('#pf_belongs_to_partner').val()           || '0',
      id_organisation:       $('#pf-org-select').val()                   || '0',
      organisation_autre:    $('#pf-org-autre').val()                    || '',
      id_address:            $('#pf_id_address_hidden').val()            || '0',
      date_naissance:        $('#pf-date-naissance').val()               || '',
      cin:                   $('#pf-cin').val()                          || '',
      fonction:              $('#pf-fonction').val()                     || '',
      raison_sociale:        $('#pf-raison-sociale').val()               || '',
      representant_legal:    $('#pf-representant-legal').val()           || '',
      date_naissance_gerant: $('#pf-date-naissance-gerant').val()        || '',
      telephone_gerant:      $('#pf-telephone-gerant').val()             || '',
      email_gerant:          $('#pf-email-gerant').val()                 || '',
      cin_gerant:            $('#pf-cin-gerant').val()                   || '',
      credit_amount:         $('#pf-credit-slider').val()                || '0',
      premiere_tranche:      $('#pf-tranche').val()                      || '0',
      nb_mois:               $('input[name=nb_mois]:checked').val()      || '6',
      mensualite:            $('#pf-mensualite').val()                   || '0',
      commentaire:           $('#pf-commentaire').val()                  || '',
    };
    try { localStorage.setItem(DRAFT_KEY, JSON.stringify(data)); } catch (e) {}
  }

  function restoreDraft(draft) {
    PF.isCompany        = draft.is_company == 1;
    PF.isRetired        = draft.is_retired == 1;
    PF.belongsToPartner = draft.belongs_to_partner == 1;

    // Step 1 — client type
    var typeVal = PF.isCompany ? '1' : '0';
    $('input[name=is_company][value="' + typeVal + '"]').prop('checked', true);
    $('.pf-client-card').removeClass('is-selected');
    $('.pf-client-card[data-value="' + typeVal + '"]').addClass('is-selected');
    toggleRetiredBlock();
    toggleCompanyFields();

    if (!PF.isCompany) {
      var retiredVal = PF.isRetired ? '1' : '0';
      $('input[name=is_retired][value="' + retiredVal + '"]').prop('checked', true);
      $('input[name=is_retired]').closest('.pf-toggle-row').find('.pf-toggle-btn').removeClass('is-selected');
      $('input[name=is_retired][value="' + retiredVal + '"]').closest('.pf-toggle-btn').addClass('is-selected');
    }
    toggleDocBlocks();

    // Step 2 — organisation
    var orgVal = draft.id_organisation || '0';
    $('#pf-org-select').val(orgVal);
    if (orgVal == '-1') {
      $('#pf-org-autre-block').show();
      $('#pf-org-autre').val(draft.organisation_autre || '');
      $('#pf-partner-notice').hide();
      PF.belongsToPartner = false;
    } else if (parseInt(orgVal) > 0) {
      $('#pf-org-autre-block').hide();
      $('#pf-partner-notice').show();
      PF.belongsToPartner = true;
    } else {
      $('#pf-org-autre-block').hide();
      $('#pf-partner-notice').hide();
      PF.belongsToPartner = false;
    }
    $('#pf_belongs_to_partner').val(PF.belongsToPartner ? '1' : '0');
    updatePartnerNavigation();
    updateDocsStep();

    // Step 3 — address
    var addrId = parseInt(draft.id_address) || 0;
    if (addrId > 0) {
      $('#pf-address-select').val(addrId);
      PF.selectedAddressId = addrId;
      $('#pf_id_address_hidden').val(addrId);
      PF_CONFIG.hasAddresses = true;
    }

    // Step 4 — personal / company fields
    if (draft.date_naissance)        $('#pf-date-naissance').val(draft.date_naissance);
    if (draft.cin)                    $('#pf-cin').val(draft.cin);
    if (draft.fonction)               $('#pf-fonction').val(draft.fonction);
    if (draft.raison_sociale)         $('#pf-raison-sociale').val(draft.raison_sociale);
    if (draft.representant_legal)     $('#pf-representant-legal').val(draft.representant_legal);
    if (draft.date_naissance_gerant)  $('#pf-date-naissance-gerant').val(draft.date_naissance_gerant);
    if (draft.telephone_gerant)       $('#pf-telephone-gerant').val(draft.telephone_gerant);
    if (draft.email_gerant)           $('#pf-email-gerant').val(draft.email_gerant);
    if (draft.cin_gerant)             $('#pf-cin-gerant').val(draft.cin_gerant);

    // Step 5 — credit
    if (parseFloat(draft.credit_amount) > 0) {
      $('#pf-credit-slider').val(draft.credit_amount);
    }
    if (parseFloat(draft.premiere_tranche) > 0) {
      $('#pf-tranche').val(draft.premiere_tranche).data('user-edited', true);
    }
    var nbMois = parseInt(draft.nb_mois) || 6;
    $('input[name=nb_mois]').prop('checked', false);
    $('input[name=nb_mois][value="' + nbMois + '"]').prop('checked', true);
    $('#pf-mois-row .pf-toggle-btn').removeClass('is-selected');
    $('input[name=nb_mois][value="' + nbMois + '"]').closest('.pf-toggle-btn').addClass('is-selected');
    if (draft.commentaire) $('#pf-commentaire').val(draft.commentaire);

    // Trigger slider recalculation
    $('#pf-credit-slider').trigger('change');

    // Jump to the saved step
    var step = parseInt(draft.current_step) || 1;
    if (step > 1) goTo(step);
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
