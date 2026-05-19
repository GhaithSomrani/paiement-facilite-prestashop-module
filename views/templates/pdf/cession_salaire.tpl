<!DOCTYPE html>
<html lang="fr">

<head>
  <meta charset="UTF-8" />
</head>

<body style="font-family: Arial, Helvetica, sans-serif; font-size: 11pt; color: #000; margin: 0; padding: 0;">

  {* ── HEADER ── *}
  <table style="width: 100%;" cellpadding="0" cellspacing="0">
    <tr>
      <td style="width: 50%; vertical-align: middle;">
        {if $cs_logo_path}
          <img src="{$cs_logo_path}" style="max-height: 60px; max-width: 180px;" />
        {else}
          <span
            style="font-size: 24pt; font-weight: bold; letter-spacing: 2px;">{$cs_shop_name|upper|escape:'html'}</span>
        {/if}
      </td>
      <td style="width: 50%; text-align: right; vertical-align: middle; font-size: 9pt; color: #333; line-height: 2.0;">
        www.lamode.tn<br />
        hello@lamode.tn<br />
        70 284 274 | 71 889 699
      </td>
    </tr>
  </table>

  <hr style="border: 0; border-top: 1.5px solid #000; margin: 3mm 0 4mm;" />

  {* ── TITLE ── *}
  <p style="text-align: center; font-size: 22pt; font-weight: bold; margin: 0 0 3mm; letter-spacing: 1px;">CESSION SUR
    SALAIRE</p>

  {* Decorative short lines flanking below title *}
  <table cellpadding="0" cellspacing="0" style="width: 100%; margin: 0 0 3mm;">
    <tr>
      <td style="width: 30%; border-bottom: 1px solid #000; padding-bottom: 0;"></td>
      <td style="width: 40%;"></td>
      <td style="width: 30%; border-bottom: 1px solid #000; padding-bottom: 0;"></td>
    </tr>
  </table>

  <p style="text-align: center; font-size: 11pt; margin: 0 0 4mm;">NO{$cs_request->id}</p>

  {* spacer *}
  <br />

  {* ── INTRO ── *}
  <p style="font-weight: bold; margin: 0 0 3mm; font-size: 11pt;">Je soussigné (M,Mme,Mlle)</p>

  {* ── PERSONAL INFO ── *}
  <table style="width: 100%; font-size: 11pt;" cellpadding="0" cellspacing="0">
    <tr>
      <td style="width: 50%; padding: 2mm 4mm 2mm 0; vertical-align: top;">
        - Nom et Prénom : <b>{$cs_customer->firstname|escape:'html'} {$cs_customer->lastname|escape:'html'}</b>
      </td>
      <td style="width: 50%; padding: 2mm 0 2mm 4mm; vertical-align: top;">
        - N° CIN : <b>{$cs_cin|escape:'html'}</b>
      </td>
    </tr>
    <tr>
      <td style="padding: 2mm 4mm 2mm 0; vertical-align: top;">
        - Organisme : <b>{$cs_org_name|escape:'html'}</b>
      </td>
      <td style="padding: 2mm 0 2mm 4mm; vertical-align: top;">
        - Matricule : <b>{$cs_matricule|escape:'html'}</b>
      </td>
    </tr>
    <tr>
      <td style="padding: 2mm 4mm 2mm 0; vertical-align: top;">
        - Emploi : <b>{$cs_request->fonction|escape:'html'}</b>
      </td>
      <td style="padding: 2mm 0 2mm 4mm; vertical-align: top;">
        - Téléphone : <b>{$cs_address->phone|escape:'html'}</b>
      </td>
    </tr>
    <tr>
      <td style="padding: 2mm 4mm 2mm 0; vertical-align: top;">
        - Adresse : <b>{$cs_address->address1|escape:'html'}{if $cs_address->address2},
            {$cs_address->address2|escape:'html'}{/if}{if $cs_address->postcode}
          {$cs_address->postcode|escape:'html'}{/if}</b>
      </td>
      <td style="padding: 2mm 0 2mm 4mm; vertical-align: top;">
        - Ville : <b>{$cs_address->city|escape:'html'}</b>
      </td>
    </tr>
  </table>

  {* spacer *}
  <br />

  {* ── BODY TEXT ── *}
  <p style="font-weight: bold; text-align: justify; margin: 0; font-size: 11pt; line-height: 1.7;">
    Je m'engage et j'autorise d'une façon irrévocable et irréversible, la direction de la gestion de paie
    de mon employeur, la cession sur salaire suite aux achats que j'ai effectués, pour
  </p>

  {* spacer *}
  <br />

  {* ── CREDIT DETAILS ── *}
  <table style="width: 100%; font-size: 11pt;" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="2" style="padding: 2mm 0;">
        - Montant des achats : <b>{$cs_request->credit_amount|string_format:"%.3f"} DT</b>
      </td>
    </tr>
    <tr>
      <td style="width: 50%; padding: 2mm 4mm 2mm 0;">
        - Acompte : <b>{$cs_request->premiere_tranche|string_format:"%.3f"} DT</b>
      </td>
      <td style="width: 50%; padding: 2mm 0 2mm 4mm;">
        - Crédit (Reste à payer) : <b>{$cs_credit_reste|string_format:"%.3f"} DT</b>
      </td>
    </tr>
    <tr>
      <td style="padding: 2mm 4mm 2mm 0;">
        - Mensualité : <b>{$cs_request->mensualite|string_format:"%.3f"} DT</b>
      </td>
      <td style="padding: 2mm 0 2mm 4mm;">
        - Nombre de mensualité(s) : <b>{$cs_request->nb_mois|intval}</b>
      </td>
    </tr>
    <tr>
      <td colspan="2" style="padding: 2mm 0;">
        - Période (D'échéance) : Du&nbsp;: <b>{$cs_period_start|escape:'html'}</b> &nbsp;&nbsp; Au&nbsp;:
        <b>{$cs_period_end|escape:'html'}</b>
      </td>
    </tr>
  </table>

  {* spacer *}
  <br /><br />

  {* ── DATE LINE ── *}
  <p style="text-align: center; color: #000; margin: 0; font-size: 11pt;">
    Fait en trois exemplaires, à {$cs_shop_city|escape:'html'} le {$cs_date}
  </p>

  {* spacer *}
  <br /><br />

  {* ── SIGNATURES ── *}
  <table style="width: 100%;" cellpadding="2" cellspacing="0">
    <tr>
      <td
        style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 28mm; vertical-align: top;">
        CLIENT</td>
      <td
        style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 28mm; vertical-align: top;">
        AMICALE</td>
      <td
        style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 28mm; vertical-align: top;">
        DIRECTION DE PAIE</td>
      <td
        style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 28mm; vertical-align: top;">
        {$cs_shop_name|upper|escape:'html'}</td>
    </tr>
  </table>

  {* ── FOOTER ── *}
  <hr style="border: 0; border-top: 1px solid #000; margin: 2mm 0 0;" />
  {if $cs_shop_address}
  <p style="text-align: center; font-size: 9pt; color: #444; margin: 2mm 0 1mm;">
    {$cs_shop_address|escape:'html'}
    </p>
  {/if}
  <p style="text-align: center; font-size: 8pt; color: #555; margin: 0;">
    LaMode, enseigne du groupe E-Market, Matriculé sous le N°1381766S, au capital de 325000 dinars
  </p>

</body>

</html>