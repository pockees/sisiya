function yourOS() {
    var ua = navigator.userAgent.toLowerCase();
    if (ua.indexOf("win") != -1) {
        return "Windows";
    } else if (ua.indexOf("mac") != -1) {
        return "Macintosh";
    } else if (ua.indexOf("linux") != -1) {
        return "Linux";
    } else if (ua.indexOf("x11") != -1) {
        return "Unix";
    } else {
        return "Bilgisayar";
    }
}
function yourBR() {
    var br = navigator.appName;
    if (br != '') {
        return br;
    } else {
        return "Tarayıcı";
	}
}