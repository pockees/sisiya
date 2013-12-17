// Arul's JavaScript functions
var dabba = '';
function init(id) {
dabba = id;
n = document.getElementById(id);
n.focus();
n.select();
return true;
}
function validator(id, e) {
n = document.getElementById(id);
if (n.value == "") {
    	alert("Please enter " + e);
    	n.focus();
    	return (false);
    }
	document.getElementById("submit").disabled = true;
	return (true);
}
function showDate() {
	var d=new Date()
	var weekday=new Array("Sun","Mon","Tue","Wed","Thur","Fri","Sat")
	var monthname=new Array("January","February","March","April","May","June","July","August","September","October","November","December")
	document.write(weekday[d.getDay()] + ", ")
	document.write(d.getDate() + " ")
	document.write(monthname[d.getMonth()] + " ")
	document.write(d.getFullYear())
}
function addToFavourite(favTitle, favUrl) {
    if (document.all) {
        window.external.AddFavorite(favUrl, favTitle);
    } else if ((typeof window.sidebar == "object") && (typeof window.sidebar.addPanel == "function")) {
		alert("Press Ctrl+D to bookmark this page!");
    } else {
		alert("Press Ctrl+D to bookmark this page!");
    }
}

function checkEnter(e) {
	var charCode = (e.which) ? e.which : e.keyCode;
  	if (charCode == 13) {
  	     checkEmpty();
    } else {
		document.getElementById("res").innerHTML = "";
	}
	return true;
}

function checkEmpty() {
	n = document.getElementById(dabba);
    if (n.value == '') {
        alert('Please enter a value');
       	n.focus();
        n.select();
    } else {
        sendRequest();
    }
}

/* AJAX stuff */
var http = createRequestObject();
function createRequestObject() {
var obj = false;
try {
  var obj = window.XMLHttpRequest ? new XMLHttpRequest(): new ActiveXObject("Microsoft.XMLHTTP");
} catch(e) {
  alert("Your browser does not support AJAX, sorry!");
}
return obj;
}
function handleResponse() {
if(http.readyState == 4){
  document.getElementById("res").innerHTML = http.responseText;
}
}
function cv(id) {
  id.select();
  showTooltip('Press <span class="key">Ctrl</span> <span class="key">C</span> to copy this code.<br><br>Then paste it into your webpage.', 200, 'ffffff');
}
function showarticles(){
for (i=0;i<ntitle.length;i++) {document.writeln('<p><a href="'+nurl[i]+'">'+ntitle[i]+'</a></p>');}
}
function detectua(ui,um){
if(navigator.userAgent.match(/iP(od|hone|ad)/i)){location.href=ui}
//else if(navigator.userAgent.match(/mobile/i)){location.href=um}
}