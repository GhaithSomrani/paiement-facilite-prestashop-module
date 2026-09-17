{if $pf_product_slices|@count > 0}
<div class="product-facilities-info">
    <div class="product-facilities-info-header">
        <h4>{l s='Paiement par facilité:' mod='paiementfacilite'}</h4>
        <a href="#" data-from="product" data-product-id="{$pf_product_id|intval}" data-product-attribute-id="{$pf_product_attribute_id|intval}" data-checked="false" type="button" class="view-all btn-simulator" data-bs-toggle="modal" data-bs-target="#kridipay-modal">
                <span>{l s='Comment ça marche' mod='paiementfacilite'}</span>
        </a>
    </div>
    <input id="number_payment_1" class="number_payment" type="radio" name="number_payment" value="1" checked>
        <label for="number_payment_1">
            {l s='COMPTANT' mod='paiementfacilite'}
        <span>
            {Tools::displayPrice($pf_product_price)}
        </span>
        </label>
    <input id="price_number_payment_1" type="hidden" name="price_number_payment_1" value="{Tools::displayPrice($pf_product_price)}">
    {foreach from=$pf_product_slices item=slice}
        <input id="number_payment_{$slice.nb_mois|intval}" class="number_payment" type="radio" name="number_payment" value="{$slice.nb_mois|intval}" disabled>
        <label for="number_payment_{$slice.nb_mois|intval}">
        <span>
            {Tools::displayPrice($slice.mensualite)}
        </span>
        X {$slice.nb_mois|intval} {l s='MOIS' mod='paiementfacilite'}
        </label>
        <input id="price_number_payment_{$slice.nb_mois|intval}" type="hidden" name="number_payment_{$slice.nb_mois|intval}" disabled value="{$slice.mensualite|floatval}">
    {/foreach}
    {if $pf_show_36_option}
    <input id="number_payment_36" class="number_payment" type="radio" name="number_payment" value="36" disabled>
    <label for="number_payment_36">
        {l s='Jusqu\'à 36 mois' mod='paiementfacilite'}
    </label>
    {/if}
</div>
{/if}
