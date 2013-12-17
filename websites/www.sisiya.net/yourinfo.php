<?php global $language; if ($language=='tr') { ?>

<div><script type="text/javascript">showDate();</script></div>

<h1>IP adresiniz, ülkeniz, tarayıcınız ve sizin diğer ayrıntılarınız:</h1>

<table class="general">
<tr><td class="title">IP adresi</td><td><?php echo $_SERVER['REMOTE_ADDR']; ?></td></tr>
<!-- <tr><td class="title">Hostname</td><td>asy253.asy77.tellcom.com.tr</td></tr> -->
<tr><td class="title">Kullanıcı yüzü</td><td><script type="text/javascript">document.write(""+navigator.appVersion+"");</script></td></tr>
<tr><td class="title">Şehir/Ülke</td><td><?php global $record; echo  $record->city."/".$record->country_name; ?></td></tr>
<!--<tr><td class="title">Internet Provider</td><td>Tellcom Fttx Regnum Elitekent Pool, TR-TELLCOM-BB-FTTX-REGNU</td></tr>-->
<tr><td class="title">Desteklenen dil</td><td><?php echo $record->country_code3; ?></td></tr>
<!--<tr><td class="title">Your port</td><td>54344</td></tr>
<tr><td class="title">Proxy IP</td><td>92.44.77.253</td></tr>
<tr><td class="title">Proxy server</td><td>Not available</td></tr>
<tr><td class="title">Proxy origin</td><td>Turkey</td></tr>
<tr><td class="title">Proxy connection</td><td>Not available</td></tr>-->

	
	<script type="text/javascript">
	// screen resolution
	document.writeln('<tr><td class="title">Ekran çözünülürlüğü </td><td>' + window.screen.width + ' x ' + window.screen.height + '</td></tr>');
	if (self.screen) {
		if (screen.pixelDepth) // for netscape and mozilla
			depth = screen.pixelDepth;
		else if (screen.colorDepth) 
			depth = screen.colorDepth;
	} else depth = 0;
	// colour depth
	if (depth == 0)
		document.writeln('<tr><td class="title">Ekran renk derinliği </td><td>' + "not sure what it is!!" + '</td></tr>');
	else {
		document.writeln('<tr><td class=title>Ekran renk derinliği </td><td>' + depth + '</td></tr>');
		numColours = Math.pow(2, depth);
		document.writeln( '<tr><td class=title>Renk sayısı </td><td>' + numColours + '</td></tr>');
	}
	</script>
	
<tr><td class="title">Web tarayıcısı</td><td><script type="text/javascript">window.document.write(""+navigator.appName+"")</script></td></tr>
<tr><td class="title">İşletim sistemi</td><td><script type="text/javascript">document.write(yourOS()+" ("+navigator.cpuClass+")")</script></td></tr>

	<script language="JavaScript">
	document.writeln('<tr><td class=title nowrap>Görüntülenen sayfa sayısı </td><td>' + history.length + '</td></tr>');
	document.writeln('<tr><td class=title>Platform </td><td>' + navigator.platform + '</td></tr>');
	document.writeln('<tr><td class=title>Java </td><td>' + navigator.javaEnabled() + '</td></tr>');
	</script>

<script language="JavaScript">
var agent = navigator.userAgent.toLowerCase();
// detecting plugins
flashPlugin = raPlugin = qtPlugin = mediaPlayerPlugin = "false";
swdPlugin = acroReadPlugin = vrmlPlugin = "false";

if (agent.indexOf('msie') >= 0) {
        // function to detect the plugins in IE.
	function detectIE(ClassID) { 
		result = false; 
		document.write('<SCRIPT LANGUAGE=VBScript\>\n on error resume next \n result = IsObject(CreateObject("' + ClassID + '"))</SCRIPT\>\n'); 
		if (result) return true;
		else return false;
	}

	if (detectIE("ShockwaveFlash.ShockwaveFlash.7")) flashPlugin = "version 7";
	else if (detectIE("ShockwaveFlash.ShockwaveFlash.6")) flashPlugin = "version 6";
	else if (detectIE("ShockwaveFlash.ShockwaveFlash.5")) flashPlugin = "version 5";
	else flashPlugin = "false";
	swdPlugin = detectIE("SWCtl.SWCtl.1");
	raPlugin = detectIE("rmocx.RealPlayer G2 Control.1");
	qtPlugin = detectIE("QuickTimeCheckObject.QuickTimeCheck.1");
	mediaPlayerPlugin = detectIE("MediaPlayer.MediaPlayer.1");
	acroReadPlugin = detectIE("PDF.PdfCtrl.5");
	vrmlPlugin = detectIE("Cortona.Control");

} else {
        // function to detect the plugins in netscape
        function detect(ClassID) {
                if (nse.indexOf(ClassID) != -1)
                if (navigator.mimeTypes[ClassID].enabledPlugin != null)
                        return true;
                return false;
        }
        nse = "";
        // adding the plugin names
        for (var i=0;i<navigator.mimeTypes.length; i++)
        	nse += navigator.mimeTypes[i].type.toLowerCase();
        flashPlugin = detect("application/x-shockwave-flash");
		raPlugin = detect("audio/x-pn-realaudio-plugin");
		swdPlugin = detect("application/x-director");
		mediaPlayerPlugin = detect("application/x-mplayer2");
		acroReadPlugin = detect("application/pdf");
		vrmlPlugin = detect("model/vrml");
}
document.writeln('<tr><td class=title>Flash  </td><td>' + flashPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Shockwave </td><td>' + swdPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Media Player  </td><td>' + mediaPlayerPlugin + '</td></tr>');
document.writeln('<tr><td class=title>RealPlayer  </td><td>' + raPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Quicktime  </td><td>' + qtPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Acrobat Reader  </td><td>' + acroReadPlugin + '</td></tr>');
//document.writeln('<tr><td class=title>VRML </td><td>' + vrmlPlugin + '</td></tr>');
</script>

</table>

<?php  } else {  ?>

<div>&nbsp;</div>
<h1>Your IP address, Country, Browser and other details</h1>

<table class="general">
<tr><td class="title">IP address</td><td><?php echo $_SERVER['REMOTE_ADDR']; ?></td></tr>
<!-- <tr><td class="title">Hostname</td><td>asy253.asy77.tellcom.com.tr</td></tr> -->
<tr><td class="title">User-Agent</td><td><script type="text/javascript">document.write(""+navigator.appVersion+"");</script></td></tr>
<tr><td class="title">City/Country</td><td><?php global $record; echo  $record->city."/".$record->country_name; ?></td></tr>
<!--<tr><td class="title">Internet Provider</td><td>Tellcom Fttx Regnum Elitekent Pool, TR-TELLCOM-BB-FTTX-REGNU</td></tr>-->
<tr><td class="title">Languages supported</td><td><?php echo $record->country_code3; ?></td></tr>
<!--<tr><td class="title">Your port</td><td>54344</td></tr>
<tr><td class="title">Proxy IP</td><td>92.44.77.253</td></tr>
<tr><td class="title">Proxy server</td><td>Not available</td></tr>
<tr><td class="title">Proxy origin</td><td>Turkey</td></tr>
<tr><td class="title">Proxy connection</td><td>Not available</td></tr>-->

	
	<script type="text/javascript">
	// screen resolution
	document.writeln('<tr><td class="title">Screen Resolution </td><td>' + window.screen.width + ' x ' + window.screen.height + '</td></tr>');
	if (self.screen) {
		if (screen.pixelDepth) // for netscape and mozilla
			depth = screen.pixelDepth;
		else if (screen.colorDepth) 
			depth = screen.colorDepth;
	} else depth = 0;
	// colour depth
	if (depth == 0)
		document.writeln('<tr><td class="title">Screen Colour depth </td><td>' + "not sure what it is!!" + '</td></tr>');
	else {
		document.writeln('<tr><td class=title>Screen Colour depth </td><td>' + depth + '</td></tr>');
		numColours = Math.pow(2, depth);
		document.writeln( '<tr><td class=title>Number of colours </td><td>' + numColours + '</td></tr>');
	}
	</script>
	
<tr><td class="title">Web Browser</td><td><script type="text/javascript">window.document.write(""+navigator.appName+"")</script></td></tr>
<tr><td class="title">Operating System</td><td><script type="text/javascript">document.write(yourOS()+" ("+navigator.cpuClass+")")</script></td></tr>

	<script language="JavaScript">
	document.writeln('<tr><td class=title nowrap>Number of pages viewed </td><td>' + history.length + '</td></tr>');
	document.writeln('<tr><td class=title>Platform </td><td>' + navigator.platform + '</td></tr>');
	document.writeln('<tr><td class=title>Java enabled </td><td>' + navigator.javaEnabled() + '</td></tr>');
	</script>

<script language="JavaScript">
var agent = navigator.userAgent.toLowerCase();
// detecting plugins
flashPlugin = raPlugin = qtPlugin = mediaPlayerPlugin = "false";
swdPlugin = acroReadPlugin = vrmlPlugin = "false";

if (agent.indexOf('msie') >= 0) {
        // function to detect the plugins in IE.
	function detectIE(ClassID) { 
		result = false; 
		document.write('<SCRIPT LANGUAGE=VBScript\>\n on error resume next \n result = IsObject(CreateObject("' + ClassID + '"))</SCRIPT\>\n'); 
		if (result) return true;
		else return false;
	}

	if (detectIE("ShockwaveFlash.ShockwaveFlash.7")) flashPlugin = "version 7";
	else if (detectIE("ShockwaveFlash.ShockwaveFlash.6")) flashPlugin = "version 6";
	else if (detectIE("ShockwaveFlash.ShockwaveFlash.5")) flashPlugin = "version 5";
	else flashPlugin = "false";
	swdPlugin = detectIE("SWCtl.SWCtl.1");
	raPlugin = detectIE("rmocx.RealPlayer G2 Control.1");
	qtPlugin = detectIE("QuickTimeCheckObject.QuickTimeCheck.1");
	mediaPlayerPlugin = detectIE("MediaPlayer.MediaPlayer.1");
	acroReadPlugin = detectIE("PDF.PdfCtrl.5");
	vrmlPlugin = detectIE("Cortona.Control");

} else {
        // function to detect the plugins in netscape
        function detect(ClassID) {
                if (nse.indexOf(ClassID) != -1)
                if (navigator.mimeTypes[ClassID].enabledPlugin != null)
                        return true;
                return false;
        }
        nse = "";
        // adding the plugin names
        for (var i=0;i<navigator.mimeTypes.length; i++)
        	nse += navigator.mimeTypes[i].type.toLowerCase();
        flashPlugin = detect("application/x-shockwave-flash");
		raPlugin = detect("audio/x-pn-realaudio-plugin");
		swdPlugin = detect("application/x-director");
		mediaPlayerPlugin = detect("application/x-mplayer2");
		acroReadPlugin = detect("application/pdf");
		vrmlPlugin = detect("model/vrml");
}
document.writeln('<tr><td class=title>Flash enabled </td><td>' + flashPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Shockwave Director </td><td>' + swdPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Media Player enabled </td><td>' + mediaPlayerPlugin + '</td></tr>');
document.writeln('<tr><td class=title>RealPlayer enabled </td><td>' + raPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Quicktime enabled </td><td>' + qtPlugin + '</td></tr>');
document.writeln('<tr><td class=title>Acrobat Reader enabled </td><td>' + acroReadPlugin + '</td></tr>');
//document.writeln('<tr><td class=title>VRML enabled </td><td>' + vrmlPlugin + '</td></tr>');
</script>

</table>

<?php  }  ?>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>