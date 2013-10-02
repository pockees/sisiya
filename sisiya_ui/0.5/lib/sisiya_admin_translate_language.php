<?php
/*
    Copyright (C) 2003 - __YEAR__ Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
error_reporting(E_ALL);

### begin of functions
function update()
{
	$sql_str="update interface set str='".$_POST['keystr_value']."' where languageid=".$_POST['language_id']." and strkeyid=".$_POST['strkey_id'];
	return(execSQL($sql_str));
}

function insert()
{
	$sql_str="insert into interface values(".$_POST['language_id'].",".$_POST['strkey_id'].",'".$_POST['keystr_value']."')";
	return(execSQL($sql_str));
}

function insert_or_update()
{
	if(update() != 1)
		insert(); 
}
### end of functions
###########################################################
$html='';
$table_name='strkeys';
$nrows=get_setNRows($table_name);

$keystr='';
$language_id=getHTTPValue('language_id');
$strkey_id=getHTTPValue('strkey_id');
$keystr_value=getHTTPValue('keystr_value');

if(isset($_POST['update']))
	insert_or_update();
#$languages=getSQL2SelectArray("select a.id,c.str from languages a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='en' and d.id=c.languageid order by c.str");
$languages=getSQL2SelectArray("select a.id,i.str from languages a,languages l,strkeys s,interface i where a.keystr=s.keystr and s.keystr=l.keystr and s.id=i.strkeyid and i.languageid=".$_SESSION['language_id']);
if($language_id == '' || $language_id == '-')
	$strkeys=array();
else
	$strkeys=getSQL2SelectArray("select id,str from strkeys order by str");
if($strkey_id != '') {
	getStrkeyAndValue($language_id,$strkey_id,$keystr,$keystr_value);
}
$html.='<form id="translate_languageForm" action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
if($_SESSION['is_admin'] == 't') {
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.languages.label.language']."</td>\n";
	$html.='	<td>'.getSelect('language_id',getHTTPValue('language_id'),$languages,"document.forms['translate_languageForm'].submit();")."</td>\n";
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.strkeys.label.keystr']."</td>\n";
	$html.='	<td>'.$keystr."</td>\n";
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.strkeys.label.str']."</td>\n";
	$html.='	<td>'.getSelect('strkey_id',getHTTPValue('strkey_id'),$strkeys,"document.forms['translate_languageForm'].submit();")."</td>\n";
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.'.$menu.'.label.translation']."</td>\n";
	$html.='	<td><input class="text_wide" type="text" name="keystr_value" value="'.$keystr_value.'" /></td>'."\n"; 
	$html.="</tr>\n";
}
$html.='</table>'."\n";
$html.='<div>'.getButtonIcon('update').'</div>'."\n";
$html.="</form>\n";
$h->addContent($html);
?>
