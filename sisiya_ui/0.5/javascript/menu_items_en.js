/* Tigra Menu items structure */
var MENU_ITEMS = [
	['Definitions', '', {'tw':'_self','tt':'Definitions','sb':'Definitions'},
		['Alert Types', 'sisiya_admin.php?menu=id_keystr&table=alerttypes', {'tw':'_self','tt':'Alert Types','sb':'Alert Types'}],
		['Infos', 'sisiya_admin.php?menu=id_sortid_keystr&table=infos', {'tw':'_self','tt':'Infos','sb':'Infos'}],
		['Locations', 'sisiya_admin.php?menu=id_sortid_keystr&table=locations', {'tw':'_self','tt':'Locations','sb':'Locations'}],
		['Properties', 'sisiya_admin.php?menu=id_keystr&table=properties', {'tw':'_self','tt':'Properties','sb':'Properties'}],
		['Services', 'sisiya_admin.php?menu=id_keystr&table=services', {'tw':'_self','tt':'Services','sb':'Services'}],
		['Status', 'sisiya_admin.php?menu=id_keystr&table=status', {'tw':'_self','tt':'Status','sb':'Status'}],
		['System Types', 'sisiya_admin.php?menu=id_str&table=systemtypes', {'tw':'_self','tt':'System Types','sb':'System Types'}]
	],
	['Systems', '', {'tw':'_self','tt':'Systems','sb':'Systems'},
		['Systems', 'sisiya_admin.php?menu=systems', {'tw':'_self','tt':'Systems','sb':'Systems'}],
		['System Infos', 'sisiya_admin.php?menu=system_infos', {'tw':'_self','tt':'System Infos','sb':'System Infos'}],
		['System Services', 'sisiya_admin.php?menu=system_services', {'tw':'_self','tt':'System Services','sb':'System Services'}],
		['System Status', 'sisiya_admin.php?menu=system_status', {'tw':'_self','tt':'System Status','sb':'System Status'}],
		['System Service Status', 'sisiya_admin.php?menu=system_service_status', {'tw':'_self','tt':'System Service Status','sb':'System Service Status'}],
		['System Security Groups', 'sisiya_admin.php?menu=id_keystr&table=securitygroups', {'tw':'_self','tt':'System Security Groups','sb':'System Security Groups'}],
		['Systems by Security Groups', 'sisiya_admin.php?menu=securitygroups_systems', {'tw':'_self','tt':'Systems by Security Groups','sb':'Systems by Security Groups'}],
		['Users by Security Groups', 'sisiya_admin.php?menu=securitygroups_users', {'tw':'_self','tt':'Users by Security Groups','sb':'Users by Security Groups'}],
		['System Groups', 'sisiya_admin.php?menu=system_groups', {'tw':'_self','tt':'System Groups','sb':'System Groups'}],
		['Group Systems', 'sisiya_admin.php?menu=group_systems', {'tw':'_self','tt':'Group Systems','sb':'Group Systems'}]
	],
	['Alerts', '', {'tw':'_self','tt':'Alerts','sb':'Alerts'},
		['System Alerts', 'sisiya_admin.php?menu=system_alerts', {'tw':'_self','tt':'Define system alerts','sb':'Define system alerts'}],
		['System Service Alerts', 'sisiya_admin.php?menu=system_service_alerts', {'tw':'_self','tt':'Define system alerts','sb':'Define system alerts'}]
	],
	['Tools', '', {'tw':'_self','tt':'Tools','sb':'Tools'},
		['Autodiscover Systems', 'sisiya_admin.php?menu=autodiscover', {'tw':'_self','tt':'Autodiscover Systems','sb':'Autodiscover Systems'}],
		['Send SisIYA a message', 'sisiya_admin.php?menu=send_message', {'tw':'_self','tt':'Sen SisIYA a message','sb':'Sen SisIYA a message'}],
		['Upload Images', 'sisiya_admin.php?menu=upload_images', {'tw':'_self','tt':'Upload Images','sb':'Upload Images'}],
	],
	['Configuration', '', {'tw':'_self','tt':'Configuration','sb':'Configuration'},
		['Remote Services', 'sisiya_admin.php?menu=remote_checks', {'tw':'_self','tt':'Configure remote checks','sb':'Configure remote checks'}],
		['Languages', '', {'tw':'_self','tt':'Add / Change Language','sb':'Add / Change Language'},
			['Languages', 'sisiya_admin.php?menu=languages', {'tw':'_self','tt':'Add a Language','sb':'Add a Language'}],
			['Interface', 'sisiya_admin.php?menu=translate_language', {'tw':'_self','tt':'Change Interface','sb':'Change Interface'}],
			['String Keys', 'sisiya_admin.php?menu=strkeys', {'tw':'_self','tt':'Add/Modify String Keys','sb':'Add/Modify String Keys'}],
			['Download / Upload', 'sisiya_admin.php?menu=import_export_language', {'tw':'_self','tt':'Download / Upload Language File','sb':'Download / Upload Language File'}]
		]
	],
	['Users', '', {'tw':'_self','tt':'Users','sb':'Users'},
		['User Properties', 'sisiya_admin.php?menu=user_properties', {'tw':'_self','tt':'Add/Change User Properties','sb':'Add/Change User Properties'}],
		['Users', 'sisiya_admin.php?menu=users', {'tw':'_self','tt':'Add/Change Users','sb':'Add/Change Users'}],
		['Change Password', 'sisiya_admin.php?menu=change_password', {'tw':'_self','tt':'Change Password','sb':'Change Password'}],
	]

];
