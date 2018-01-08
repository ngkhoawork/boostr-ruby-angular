FactoryBot.define do
  factory :email, class: Hash do
    initialize_with { attributes }

    # Assumes Griddler.configure.to is :hash (default)
    to ['to_user@email.com']
    from 'from_email@email.com'
    subject 'Boostr Email Activity'
    text 'Paranormal Activity. The truth is out there.'
    attachments {[]}

    trait :with_attachment do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/../fixtures/images/boostr.png")
        })
      ]}
    end

    trait :html_email do
      html {
<<-HTML_BODY
------=_Part_14745358_74550914.1488633029914
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8" />
<meta name=3D"viewport" content=3D"width=3Ddevice-width, minimum-scale=3D1.=
0, maximum-scale=3D1.0, user-scalable=3D0" />
<meta name=3D"apple-mobile-web-app-capable" content=3D"yes" />
<style type=3D"text/css">
@media only screen and (max-width: 448px) {
.wrapper {
width:100% !important;
}
.full_tweet_margin_lr {
width: 12px !important;
}
</style>
</head>
<body style=3D"margin:0px;padding:0px;-webkit-text-size-adjust:100%;-ms-tex=
t-size-adjust:100%;">
<!--Preheader-->
<div class=3D"preheader" style=3D"display:none;font-size:1px;color:#ffffff;=
line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">
</div>
<!-- end preheader-->
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width:100%=
;background-color: #F5F8FA;margin:0px;padding:0px;">
<tbody>
<tr>
<td align=3D"center" style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" class=3D"wrapper" s=
tyle=3D"margin:0px;padding:0px;width:448px;">
<!-- header start -->
<tbody>
<tr>
<td align=3D"center" style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"width:100%=
;margin:0px;padding:0px;">
<tbody>
<tr>
<td height=3D"24" style=3D"height:24px;margin:0px;padding:0px;"></td>
</tr>
<tr>
<td align=3D"center" style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" align=3D"center" st=
yle=3D"margin:0px;padding:0px;">
<tbody>
<tr>
<td height=3D"6" style=3D"height:6px;margin:0px;padding:0px;"></td>
</tr>
<tr align=3D"center">
<td class=3D"header" style=3D"margin:0px;padding:0px;font-family:'Helvetica=
 Neue Light', 'Helvetica Neue', Arial, sans-serif;-webkit-font-smoothing:an=
tialiased;-webkit-text-size-adjust:none;font-weight:300;color:#292F33;font-=
size:21px;line-height:21px;padding:0px;margin:0px;white-space:nowrap;"> Twe=
ets making headlines </td>
</tr>
</tbody>
</table> </td>
</tr>
<tr>
<td height=3D"24" style=3D"height:24px;margin:0px;padding:0px;"></td>
</tr>
</tbody>
</table> </td>
</tr>
<!-- header end -->
<tr>
<td style=3D"margin:0px;padding:0px;"> <img width=3D"1" height=3D"1" src=3D=
"https://twitter.com/scribe/ibis?t=3D1&amp;cn=3DZmxleGlibGVfcmVjcw%3D%3D&am=
p;iid=3De2064121cdc84ff3b757d76d2e4a1325&amp;uid=3D2901222287&amp;nid=3D244=
+20" style=3D"margin:0px;padding:0px;display:block;-ms-interpolation-mode:b=
icubic;border:none;outline:none;" /> </td>
</tr>
<!-- content start -->
<tr>
<!-- social proof header end --> </a></td>
</tr>
<tr>
<td height=3D"24" class=3D"module_margin_tb" style=3D"margin:0px;padding:0p=
x;height:24px;"></td>
</tr>
<!-- top margin -->
<tr>
<td style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"min-width:=
100%;width:100%;maOl\xC3\xA9rgin:0px;padding:0px;">
<tbody>
<tr>
<td ï»¿ width=3D"24" class=3D"module_margin_lr" style=3D"margin:0px;padding:0px=
;width:24px;"></td>
<!-- left margin -->
<td style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"min-width:=
100%;width:100%;margin:0px;padding:0px;">
<tbody>
<tr>
<td style=3D"margin:0px;padding:0px;">
</tr>
<tr>
<td height=3D"14" style=3D"height:14px;margin:0px;padding:0px;"></td>
</tr>
<tr>
</tbody>
</table> </a></td>
</tr>
</tbody>
</table> </td>
<td width=3D"24" class=3D"module_margin_lr" style=3D"margin:0px;padding:0px=
;width:24px;"></td>
<!-- right margin -->
</tr>
</tbody>
</table> </td>
</tr>
<tr>
<td height=3D"24" class=3D"news_margin_bottom" style=3D"margin:0px;padding:=
0px;height:24px;"></td>
</tr>
<!-- bottom margin -->
</tbody>
</table> </a></td>
</tr>
<tr>
<td height=3D"20" class=3D"module_space" style=3D"margin:0px;padding:0px;he=
ight:20px;"></td>
</tr>
</tbody>
</table> </td>
</tr>
<!-- content end -->
<tr>
<td height=3D"10" style=3D"height:10px;margin:0px;padding:0px;"></td>
</tr>
<tr>
<td align=3D"center" style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" style=3D"margin:0px=
;padding:0px;">
</table> </td>
</tr>
<tr>
<td height=3D"60" style=3D"height:60px;margin:0px;padding:0px;"></td>
</tr>
<!-- footer start -->
<tr>
<td style=3D"margin:0px;padding:0px;">
<table cellpadding=3D"0" cellspacing=3D"0" border=3D"0" align=3D"center" st=
yle=3D"width:100%;margin:0px;padding:0px;">
<tbody>
<tr>
<td height=3D"20" style=3D"height:20px;margin:0px;padding:0px;"></td>
</tr>
<tr>
</tr>
<tr>
<td height=3D"10" style=3D"height:10px;margin:0px;padding:0px;"></td>
</tr>
<tr>
<tr>
<td height=3D"26" style=3D"height:26px;margin:0px;padding:0px;"></td>
</tr>
</tbody>
</table> </td>
</tr>
<!-- footer end -->
</tbody>
</table> </td>
</tr>
</tbody>
</table>
<div style=3D"white-space:nowrap; font:15px courier; color: #ffffff;" class=
=3D"dashline" align=3D"center">
------------------------------------------------
</div>
</body>
</html>

------=_Part_14745358_74550914.1488633029914--
    HTML_BODY
      }
    end
  end
end
