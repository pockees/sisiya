/* Tigra Menu items structure */
var MENU_ITEMS = [
	['Dashboard', 'sisiya_gui.php?menu=dashboard', {'tw':'_self','tt':'Dashboard','sb':'Dashboard'},
		['Critical Systems', 'sisiya_gui.php?menu=dashboard&type=systems&effectsglobal=t', {'tw':'_self','tt':'Critical Systems','sb':'Critical Systems'}],
		['Non-Critical Systems', 'sisiya_gui.php?menu=dashboard&type=systems&effectsglobal=f', {'tw':'_self','tt':'Non-Critical Systems','sb':'Non-Critical Systems'}],
		['Services', 'sisiya_gui.php?menu=dashboard&type=services', {'tw':'_self','tt':'Services','sb':'Services'}]
	],
	['Overview', '', {'tw':'_self','tt':'Overview','sb':'Overview'},
		['By Locations', 'sisiya_gui.php?menu=overview', {'tw':'_self','tt':'Overview by Locations','sb':'Overview by Locations'}],
		['By Groups', 'sisiya_gui.php?menu=overview&groups=1', {'tw':'_self','tt':'Overview by Groups','sb':'Overview by Groups'}]
	],
	['Detailed View ', '', {'tw':'_self','tt':'Detailed View ','sb':'Detailed View '},
		['By Locations', 'sisiya_gui.php?menu=detailed_view', {'tw':'_self','tt':'Detailed View by Locations','sb':'Detailed View by Locations'}],
		['By Groups', 'sisiya_gui.php?menu=detailed_view&groups=1', {'tw':'_self','tt':'Detailed View by Groups','sb':'Detailed View by Groups'}]
	],
	['Network Device View', 'sisiya_gui.php?menu=switch_view', {'tw':'_self','tt':'Network Device View ','sb':'Network Device View '}],
	['System Services', 'sisiya_gui.php?menu=system_services', {'tw':'_self','tt':'System Services','sb':'System Services'}],
	['Preferences', 'sisiya_admin.php', {'tw':'sisiya_admin.php','tt':'Preferences','sb':'Preferences'},
		['Settings', 'sisiya_admin.php', {'tw':'sisiya_admin.php','tt':'Settings','sb':'Settings'}],
		['Downloads', 'sisiya_gui.php?menu=client_programs', {'tw':'_self','tt':'Downloads','sb':'Downloads'}],
		['RSS', 'sisiya_rss.xml', {'tw':'sisiya_rss.xml','tt':'RSS','sb':'RSS'}]
	],
	['Help', '', {'tw':'','tt':'Help','sb':'Help'},
		['Documentation', 'sisiya_gui.php?menu=documentation', {'tw':'_self','tt':'Documentation','sb':'Documentation'}],
		['Support', 'sisiya_gui.php?menu=support', {'tw':'_self','tt':'Support','sb':'Support'}],
		['About', 'sisiya_gui.php?menu=about', {'tw':'_self','tt':'About','sb':'About'}]
	]
];
