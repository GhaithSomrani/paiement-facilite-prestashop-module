<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8" />
<style>
  * { box-sizing: border-box; }
  body {
    font-family: "Times New Roman", Times, serif;
    font-size: 12pt;
    color: #000;
    margin: 0;
    padding: 0;
  }
  table { border-collapse: collapse; }
  .w100 { width: 100%; }

  /* Field label / value pairs */
  .fl { white-space: nowrap; font-size: 11pt; padding-right: 3mm; vertical-align: bottom; }
  .fv { border-bottom: 1px dotted #777; font-size: 11pt; padding: 1mm 2mm; vertical-align: bottom; width: 100%; }

  /* Signature row */
  .sig { width: 25%; text-align: center; font-weight: bold; font-size: 11pt;
         letter-spacing: 0.5px; border-top: 1px solid #000; padding-top: 3mm; }

  /* Footer text */
  .ft { font-size: 9pt; color: #444; }
</style>
</head>
<body>

{* ═══════════════ HEADER ═══════════════ *}
<table class="w100" style="border-bottom: 2px solid #111; margin-bottom: 8mm; padding-bottom: 3mm;">
  <tr>
    <td style="width: 55%; vertical-align: middle;">
      {if $cs_logo_path}
      <img src="{$cs_logo_path|escape:'html'}" style="height:38px; vertical-align:middle; margin-right:10px;" />
      {/if}
      <span style="font-size: 16pt; font-weight: bold; letter-spacing: 1px; vertical-align: middle;">E-MARKET</span><br/>
      <span style="font-size: 9pt; color: #555; margin-left: 2mm;">Votre partenaire achats</span>
    </td>
    <td style="width: 45%; text-align: right; vertical-align: middle;">
      <span style="font-size: 14pt; font-weight: bold; text-transform: uppercase; letter-spacing: 1px;">Cession sur salaire</span><br/>
      <span style="font-size: 10pt; color: #555;">Engagement irrévocable</span>
    </td>
  </tr>
</table>

{* ═══════════════ REFERENCE ═══════════════ *}
<p style="text-align: right; font-weight: bold; font-size: 13pt; margin: 0 0 8mm 0;">
  N<sup>O</sup>&nbsp;&nbsp;{$cs_request->id|string_format:"%05d"}
</p>

{* ═══════════════ INTRO ═══════════════ *}
<p style="margin: 0 0 3mm 2mm; font-size: 12pt;">Je soussigné(e) (M, Mme, Mlle)</p>

{* ═══════════════ PERSONAL FIELDS ═══════════════ *}
<table class="w100" style="margin-bottom: 5mm;">
  <tr>
    <td style="width: 50%; padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Nom et Prénom :</td>
          <td class="fv">{$cs_customer->firstname|escape:'html'} {$cs_customer->lastname|escape:'html'}</td>
        </tr>
      </table>
    </td>
    <td style="width: 50%; padding-bottom: 3mm; padding-left: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- N° CIN :</td>
          <td class="fv">{$cs_cin|escape:'html'}</td>
        </tr>
      </table>
    </td>
  </tr>

  <tr>
    <td style="padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Organisme :</td>
          <td class="fv">{$cs_org_name|escape:'html'}</td>
        </tr>
      </table>
    </td>
    <td style="padding-bottom: 3mm; padding-left: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Matricule :</td>
          <td class="fv">{$cs_matricule|escape:'html'}</td>
        </tr>
      </table>
    </td>
  </tr>

  <tr>
    <td style="padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Emploi :</td>
          <td class="fv">{$cs_request->fonction|escape:'html'}</td>
        </tr>
      </table>
    </td>
    <td style="padding-bottom: 3mm; padding-left: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Téléphone :</td>
          <td class="fv">{$cs_address->phone|escape:'html'}</td>
        </tr>
      </table>
    </td>
  </tr>

  {* Address — 2 underlined lines *}
  <tr>
    <td colspan="2" style="padding-bottom: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl" style="vertical-align: top; padding-top: 2mm;">- Adresse :</td>
          <td>
            <table class="w100">
              <tr>
                <td class="fv">
                  {$cs_address->address1|escape:'html'}{if $cs_address->address2}, {$cs_address->address2|escape:'html'}{/if}
                </td>
              </tr>
              <tr>
                <td class="fv">
                  {$cs_address->postcode|escape:'html'} {$cs_address->city|escape:'html'}
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>

  <tr>
    <td style="padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Ville :</td>
          <td class="fv">{$cs_address->city|escape:'html'}</td>
        </tr>
      </table>
    </td>
    <td></td>
  </tr>
</table>

{* ═══════════════ BODY TEXT ═══════════════ *}
<p style="text-align: justify; margin: 3mm 0 4mm; font-size: 12pt;">
  Je m'engage et j'autorise d'une façon irrévocable et irréversible, la direction de la
  gestion de paie de mon employeur, la cession sur salaire suite aux achats que j'ai
  effectués, pour profit de la société E-Market, du montant de :
</p>

{* ═══════════════ CREDIT FIELDS ═══════════════ *}
<table class="w100" style="margin-bottom: 5mm;">
  <tr>
    <td style="width: 50%; padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Montant des achats :</td>
          <td class="fv">{$cs_request->credit_amount|string_format:"%.3f"} DT</td>
        </tr>
      </table>
    </td>
    <td style="width: 50%;"></td>
  </tr>

  <tr>
    <td style="padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Acompte :</td>
          <td class="fv">{$cs_request->premiere_tranche|string_format:"%.3f"} DT</td>
        </tr>
      </table>
    </td>
    <td style="padding-bottom: 3mm; padding-left: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl" style="white-space: nowrap;">- Crédit (Reste à payer) :</td>
          <td class="fv">{$cs_credit_reste|string_format:"%.3f"} DT</td>
        </tr>
      </table>
    </td>
  </tr>

  <tr>
    <td style="padding-bottom: 3mm; padding-right: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl">- Mensualité :</td>
          <td class="fv">{$cs_request->mensualite|string_format:"%.3f"} DT</td>
        </tr>
      </table>
    </td>
    <td style="padding-bottom: 3mm; padding-left: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl" style="white-space: nowrap;">- Nombre de mensualité(s) :</td>
          <td class="fv">{$cs_request->nb_mois|intval}</td>
        </tr>
      </table>
    </td>
  </tr>

  {* Period — full width *}
  <tr>
    <td colspan="2" style="padding-bottom: 3mm;">
      <table class="w100">
        <tr>
          <td class="fl" style="white-space: nowrap;">- Période (D'échéance) : Du :</td>
          <td class="fv">{$cs_period_start|escape:'html'} &nbsp;&nbsp; au : &nbsp;&nbsp; {$cs_period_end|escape:'html'}</td>
        </tr>
      </table>
    </td>
  </tr>
</table>

{* ═══════════════ DATE LINE ═══════════════ *}
<p style="text-align: center; margin: 8mm 0 18mm; font-size: 12pt;">
  Fait en trois exemplaires, à &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; le &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</p>

{* ═══════════════ SIGNATURES ═══════════════ *}
<table class="w100" style="margin-top: 8mm;">
  <tr>
    <td class="sig">CLIENT</td>
    <td class="sig">AMICALE</td>
    <td class="sig">DIRECTION DE PAIE</td>
    <td class="sig">E-MARKET</td>
  </tr>
  <tr>
    <td style="height: 28mm;"></td>
    <td style="height: 28mm;"></td>
    <td style="height: 28mm;"></td>
    <td style="height: 28mm;"></td>
  </tr>
</table>

{* ═══════════════ FOOTER ═══════════════ *}
<table class="w100" style="border-top: 2px solid #111; margin-top: 10mm; padding-top: 3mm;">
  <tr>
    <td style="width: 33%; vertical-align: top;" class="ft">
      <strong style="color: #111; letter-spacing: 0.5px;">{$cs_shop_name|escape:'html'} S.A.R.L.</strong>
    </td>
    <td style="width: 34%; text-align: center; vertical-align: top;" class="ft">
      {$cs_shop_address|escape:'html'|nl2br}<br/>
      {if $cs_shop_phone}Tél : {$cs_shop_phone|escape:'html'}{/if}
    </td>
    <td style="width: 33%; text-align: right; vertical-align: top;" class="ft">
      {if $cs_shop_rc}RC : {$cs_shop_rc|escape:'html'}<br/>{/if}
      Page 1 / 1
    </td>
  </tr>
</table>

</body>
</html>
