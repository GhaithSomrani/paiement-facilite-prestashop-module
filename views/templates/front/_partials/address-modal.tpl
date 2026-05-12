{* Address Modal — Bootstrap 4, AJAX save *}
<div class="modal fade" id="pf-address-modal" tabindex="-1" role="dialog"
     aria-labelledby="pfAddressModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="pfAddressModalLabel">
          {l s='Ajouter une adresse' mod='paiementfacilite'}
        </h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>

      <div class="modal-body">
        <div id="pf-address-modal-errors" class="alert alert-danger" style="display:none;"></div>
        <form id="pf-address-modal-form" novalidate>

          <div class="row">
            <div class="col-md-6 form-group">
              <label for="modal-alias">{l s='Alias (ex: Domicile, Bureau)' mod='paiementfacilite'} *</label>
              <input type="text" id="modal-alias" name="alias" class="form-control"
                     required maxlength="64" placeholder="{l s='Mon adresse' mod='paiementfacilite'}">
            </div>
          </div>

          <div class="row">
            <div class="col-md-6 form-group">
              <label for="modal-firstname">{l s='Prénom' mod='paiementfacilite'} *</label>
              <input type="text" id="modal-firstname" name="firstname" class="form-control"
                     required maxlength="255">
            </div>
            <div class="col-md-6 form-group">
              <label for="modal-lastname">{l s='Nom' mod='paiementfacilite'} *</label>
              <input type="text" id="modal-lastname" name="lastname" class="form-control"
                     required maxlength="255">
            </div>
          </div>

          <div class="form-group">
            <label for="modal-address1">{l s='Adresse' mod='paiementfacilite'} *</label>
            <input type="text" id="modal-address1" name="address1" class="form-control"
                   required maxlength="255">
          </div>

          <div class="row">
            <div class="col-md-4 form-group">
              <label for="modal-postcode">{l s='Code postal' mod='paiementfacilite'} *</label>
              <input type="text" id="modal-postcode" name="postcode" class="form-control"
                     required maxlength="12">
            </div>
            <div class="col-md-8 form-group">
              <label for="modal-city">{l s='Ville' mod='paiementfacilite'} *</label>
              <input type="text" id="modal-city" name="city" class="form-control"
                     required maxlength="64">
            </div>
          </div>

          <div class="form-group">
            <label for="modal-phone">{l s='Téléphone' mod='paiementfacilite'} *</label>
            <input type="tel" id="modal-phone" name="phone" class="form-control"
                   required maxlength="32" placeholder="+216 00 000 000">
          </div>

        </form>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">
          {l s='Annuler' mod='paiementfacilite'}
        </button>
        <button type="button" class="btn btn-primary" id="pf-save-address-btn">
          <span id="pf-save-address-spinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
          {l s='Enregistrer l\'adresse' mod='paiementfacilite'}
        </button>
      </div>

    </div>
  </div>
</div>
