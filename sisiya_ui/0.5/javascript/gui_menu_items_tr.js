/* Tigra Menu items structure */
var MENU_ITEMS = [
	['İzleme Paneli', 'sisiya_gui.php?menu=dashboard', {'tw':'_self','tt':'İzleme Paneli','sb':'İzleme Paneli'},
		['Kritik Sistemler', 'sisiya_gui.php?menu=dashboard&type=systems&effectsglobal=t', {'tw':'_self','tt':'Kritik Sistemler','sb':'Kritik Sistemler'}],
		['Kritik Olmayan Sistemler', 'sisiya_gui.php?menu=dashboard&type=systems&effectsglobal=f', {'tw':'_self','tt':'Kritik olmayan Sistemler','sb':'Kritik Olmayan Sistemler'}],
		['Denetimler', 'sisiya_gui.php?menu=dashboard&type=services', {'tw':'_self','tt':'Denetimler','sb':'Denetimler'}]
	],
	['Genel Görünüm', '', {'tw':'_self','tt':'Genel Görünüm','sb':'Genel Görünüm'},
		['Konumlar Bazında', 'sisiya_gui.php?menu=overview', {'tw':'_self','tt':'Konumlar Bazında Genel Görünüm','sb':'Konumlar Bazında Genel Görünüm'}],
		['Gruplar Bazında', 'sisiya_gui.php?menu=overview&groups=1', {'tw':'_self','tt':'Gruplar Bazında Genel Görünüm','sb':'Gruplar Bazında Genel Görünüm'}]
	],
	['Ayrıntılı Görünüm', '', {'tw':'_self','tt':'Ayrıntılı Görünüm','sb':'Ayrıntılı Görünüm'},
		['Konumlar Bazında', 'sisiya_gui.php?menu=detailed_view', {'tw':'_self','tt':'Konumlar Bazında Ayrıntılı Görünüm','sb':'Konumlar Bazında Ayrıntılı Görünüm'}],
		['Gruplar Bazında', 'sisiya_gui.php?menu=detailed_view&groups=1', {'tw':'_self','tt':'Gruplar Bazında Ayrıntılı Görünüm','sb':'Gruplar Bazında Ayrıntılı Görünüm'}]
	],
	['Ağ Aygıt Görünümü', 'sisiya_gui.php?menu=switch_view', {'tw':'_self','tt':'Ağ Aygıt Görünümü','sb':'Ağ Aygıt Görünümü'}],
	['Sistem Denetimleri', 'sisiya_gui.php?menu=system_services', {'tw':'_self','tt':'Sistem Denetimleri','sb':'Sistem Denetimleri'}],
	['Yapılandırma', 'sisiya_admin.php', {'tw':'sisiya_admin.php','tt':'Yapılandırma','sb':'Yapılandırma'},
		['Yapılandırma', 'sisiya_admin.php', {'tw':'sisiya_admin.php','tt':'Yapılandırma','sb':'Yapılandırma'}],
		['İndir', 'sisiya_gui.php?menu=client_programs', {'tw':'_self','tt':'İndir','sb':'İndir'}],
		['RSS', 'sisiya_rss.xml', {'tw':'sisiya_rss.xml','tt':'RSS','sb':'RSS'}]
	],
	['Yardım', '', {'tw':'','tt':'Yardım','sb':'Yardım'},
		['Belgeler', 'sisiya_gui.php?menu=documentation', {'tw':'_self','tt':'Belgeler','sb':'Belgeler'}],
		['Destek', 'sisiya_gui.php?menu=support', {'tw':'_self','tt':'Destek','sb':'Destek'}],
		['Hakkında', 'sisiya_gui.php?menu=about', {'tw':'_self','tt':'Hakkında','sb':'Hakkında'}]
	]
];
