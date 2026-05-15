<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8" />
</head>
<body style="font-family: 'Times New Roman', Times, serif; font-size: 11pt; color: #000; margin: 0; padding: 0;">

{* ── HEADER ── *}
<table style="width: 100%;">
  <tr>
    <td style="width: 50%; vertical-align: top; padding-bottom: 0;">
      {if $cs_logo_path}
        <img src="{$cs_logo_path}" style="max-height: 55px; max-width: 170px;" />
      {else}
        <span style="font-size: 22pt; font-weight: bold;">{$cs_shop_name|escape:'html'}</span>
      {/if}
    </td>
    <td style="width: 50%; text-align: right; vertical-align: top; font-size: 9pt; color: #333; line-height: 2.0;">
      www.lamode.tn<br/>
      hello@lamode.tn<br/>
      70 284 274 | 71 889 699
    </td>
  </tr>
</table>

{* spacer *}
<br/><br/>

{* ── TITLE ── *}
<p style="text-align: center; font-size: 22pt; font-weight: bold; margin: 0 0 3mm;">CESSION SUR SALAIRE</p>
<hr style="border: 0; border-top: 1px solid #000; margin: 0 0 6mm;" />
<p style="text-align: center; font-size: 11pt; margin: 0 0 0;">NO{$cs_request->id}</p>

{* spacer *}
<br/>

{* ── INTRO ── *}
<p style="font-weight: bold; margin: 0 0 2mm; font-size: 11pt;">Je soussigné (M,Mme,Mlle)</p>
<br/>

{* ── PERSONAL INFO ── *}
<table style="width: 100%; font-size: 11pt;">
  <tr>
    <td style="width: 50%; padding: 2.5mm 4mm 2.5mm 0; vertical-align: top;">
      - Nom et Prénom : {$cs_customer->firstname|escape:'html'} {$cs_customer->lastname|escape:'html'}
    </td>
    <td style="width: 50%; padding: 2.5mm 0 2.5mm 4mm; vertical-align: top;">
      - N° CIN : {$cs_cin|escape:'html'}
    </td>
  </tr>
  <tr>
    <td style="padding: 2.5mm 4mm 2.5mm 0; vertical-align: top;">
      - Organisme : {$cs_org_name|escape:'html'}
    </td>
    <td style="padding: 2.5mm 0 2.5mm 4mm; vertical-align: top;">
      - Matricule : {$cs_matricule|escape:'html'}
    </td>
  </tr>
  <tr>
    <td style="padding: 2.5mm 4mm 2.5mm 0; vertical-align: top;">
      - Emploi : {$cs_request->fonction|escape:'html'}
    </td>
    <td style="padding: 2.5mm 0 2.5mm 4mm; vertical-align: top;">
      - Téléphone : {$cs_address->phone|escape:'html'}
    </td>
  </tr>
  <tr>
    <td style="padding: 2.5mm 4mm 2.5mm 0; vertical-align: top;">
      - Adresse : {$cs_address->address1|escape:'html'}
      {if $cs_address->address2}<br/>{$cs_address->address2|escape:'html'}{/if}
      {if $cs_address->postcode}<br/>{$cs_address->postcode|escape:'html'}{/if}
    </td>
    <td style="padding: 2.5mm 0 2.5mm 4mm; vertical-align: top;">
      - Ville : {$cs_address->city|escape:'html'}
    </td>
  </tr>
</table>

{* spacer *}
<br/>

{* ── BODY TEXT ── *}
<p style="font-weight: bold; text-align: justify; margin: 0; font-size: 11pt; line-height: 1.6;">
  Je m'engage et j'autorise d'une façon irrévocable et irréversible, la direction de la gestion de paie
  de mon employeur, la cession sur salaire suite aux achats que j'ai effectués, pour profit de la
  société {$cs_shop_name|escape:'html'}, du montant de :
</p>

{* spacer *}
<br/>

{* ── CREDIT DETAILS ── *}
<table style="width: 100%; font-size: 11pt;">
  <tr>
    <td colspan="2" style="padding: 2.5mm 0;">
      - Montant des achats : {$cs_request->credit_amount|string_format:"%.3f"}
    </td>
  </tr>
  <tr>
    <td style="width: 50%; padding: 2.5mm 4mm 2.5mm 0;">
      - Acompte : {$cs_request->premiere_tranche|string_format:"%.3f"}
    </td>
    <td style="width: 50%; padding: 2.5mm 0 2.5mm 4mm;">
      - Crédit (Reste à payer) : {$cs_credit_reste|string_format:"%.3f"}
    </td>
  </tr>
  <tr>
    <td style="padding: 2.5mm 4mm 2.5mm 0;">
      - Mensualité : {$cs_request->mensualite|string_format:"%.3f"}
    </td>
    <td style="padding: 2.5mm 0 2.5mm 4mm;">
      - Nombre de mensualité (s) : {$cs_request->nb_mois|intval}
    </td>
  </tr>
  <tr>
    <td colspan="2" style="padding: 2.5mm 0;">
      - Période (D'échéance) : Du : {$cs_period_start|escape:'html'} &nbsp;&nbsp; Au : {$cs_period_end|escape:'html'}
    </td>
  </tr>
</table>

{* spacer *}
<br/><br/>

{* ── DATE LINE ── *}
<p style="text-align: center; color: #1a3d8f; margin: 0; font-size: 11pt;">
  Fait en trois exemplaires, à {$cs_shop_city|escape:'html'} le {$cs_date}
</p>

{* spacer *}
<br/><br/>

{* ── SIGNATURES ── *}
<table style="width: 100%;">
  <tr>
    <td style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 30mm; vertical-align: top;">CLIENT</td>
    <td style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 30mm; vertical-align: top;">AMICALE</td>
    <td style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 30mm; vertical-align: top;">DIRECTION DE PAIE</td>
    <td style="width: 25%; text-align: center; font-weight: bold; font-size: 11pt; height: 30mm; vertical-align: top;">{$cs_shop_name|upper|escape:'html'}</td>
  </tr>
</table>

{* ── FOOTER ── *}
<hr style="border: 0; border-top: 1px solid #000; margin: 0;" />
{if $cs_shop_address}
<p style="text-align: center; font-size: 9pt; color: #444; margin: 3mm 0 2mm;">
  — {$cs_shop_address|escape:'html'} —
</p>
{/if}
<p style="text-align: center; font-size: 8pt; color: #555; margin: 0;">
  LaMode, enseigne du groupe E-Market, Matriculé sous le N°1381766S, au capital de 325000 dinars
</p>

</body>
</html>
