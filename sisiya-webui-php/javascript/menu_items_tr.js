/* Tigra Menu items structure */
var MENU_ITEMS = [
	['Temel Veriler', '', {'tw':'_self','tt':'Temel sistem seçenekleri / özellikleri','sb':'Temel sistem seçenekleri / özellikleri'},
		['Uyarı Türleri', 'sisiya_admin.php?menu=id_keystr&table=alerttypes', {'tw':'_self','tt':'Uyarı gönderme yöntemleri','sb':'Uyarı gönderme yöntemleri'}],
		['Bilgiler', 'sisiya_admin.php?menu=id_sortid_keystr&table=infos', {'tw':'_self','tt':'Sistemlerle ilgili temel bilgi türleri','sb':'Sistemlerle ilgili temel bilgi türleri'}],
		['Konumlar', 'sisiya_admin.php?menu=id_sortid_keystr&table=locations', {'tw':'_self','tt':'Sistemlerin bulunduğu konumlar / merkezler','sb':'Sistemlerin bulunduğu konumlar / merkezler'}],
		['Özellikler', 'sisiya_admin.php?menu=id_keystr&table=properties', {'tw':'_self','tt':'İşleyişle ilgili özellikler','sb':'İşleyişle ilgili özellikler'}],
		['Denetimler', 'sisiya_admin.php?menu=id_keystr&table=services', {'tw':'_self','tt':'Sistemlerin denetleme noktaları','sb':'Sistemlerin denetleme noktaları'}],
		['Durumlar', 'sisiya_admin.php?menu=id_keystr&table=status', {'tw':'_self','tt':'Sistemlerin durumu ile ilgili bilgi türleri','sb':'Sistemlerin durumu ile ilgili bilgi türleri'}],
		['Sistem Türleri', 'sisiya_admin.php?menu=id_str&table=systemtypes', {'tw':'_self','tt':'Sistem çeşitleri / grupları','sb':'Sistem çeşitleri / grupları'}]
	],
	['Sistemler', '', {'tw':'_self','tt':'Sistemlerle ilgili işlemler','sb':'Sistemlerle ilgili işlemler'},
		['Sistemler', 'sisiya_admin.php?menu=systems', {'tw':'_self','tt':'Sistem ekleme, silme ve güncelleme','sb':'Sistem ekleme, silme ve güncelleme'}],
		['Sistem Bilgileri', 'sisiya_admin.php?menu=system_infos', {'tw':'_self','tt':'Sistemlere bilgi türleri atama','sb':'Sistemlere bilgi türleri atama'}],
		['Sistemlerin Denetimleri', 'sisiya_admin.php?menu=system_services', {'tw':'_self','tt':'Sistemlere denetleme noktası atama','sb':'Sistemlere denetleme noktası atama'}],
		['Sistemlerin Durumları', 'sisiya_admin.php?menu=system_status', {'tw':'_self','tt':'Sistemlere durum bilgisi atama','sb':'Sistemlere durum bilgisi atama'}],
		['Sistem Denetimlerinin Durumları', 'sisiya_admin.php?menu=system_service_status', {'tw':'_self','tt':'Sistem denetleme noktalarının durum bilgileri','sb':'Sistem denetleme noktalarının durum bilgileri'}],
		['Sistem Güvenlik Grupları', 'sisiya_admin.php?menu=id_keystr&table=securitygroups', {'tw':'_self','tt':'Sistem Güvenlik Grupları','sb':'Sistem Güvenlik Grupları'}],
		['Güvenlik Grupları Bazında Sistemler', 'sisiya_admin.php?menu=securitygroups_systems', {'tw':'_self','tt':'Güvenlik Grupları Bazında Sistemler','sb':'Güvenlik Grupları Bazında Sistemler'}],
		['Güvenlik Grupları Bazında Kullanıcılar', 'sisiya_admin.php?menu=securitygroups_users', {'tw':'_self','tt':'Güvenlik Grupları Bazında Kullanıcılar','sb':'Güvenlik Grupları Bazında Kullanıcılar'}],
		['Sistem Grupları', 'sisiya_admin.php?menu=system_groups', {'tw':'_self','tt':'Sistem grupları ekleme, silme, güncelleme','sb':'Sistem grupları ekleme, silme, güncelleme'}],
		['Sistem Gruplama', 'sisiya_admin.php?menu=group_systems', {'tw':'_self','tt':'Sistemleri gruplara atama','sb':'Sistemleri gruplara atama'}]
	],
	['Uyarılar', '', {'tw':'_self','tt':'Sistemlere uyarı ekleme, silme ve güncelleme','sb':'Sistemlere uyarı ekleme, silme ve güncelleme'},
		['Sistemlerin Uyarıları', 'sisiya_admin.php?menu=system_alerts', {'tw':'_self','tt':'Sistemlerin durumları için uyarı tanımlama','sb':'Sistemlerin durumları için uyarı tanımlama'}],
		['Sistem Denetimi Uyarıları', 'sisiya_admin.php?menu=system_service_alerts', {'tw':'_self','tt':'Sistem denetim noktaları için uyarı tanımlama','sb':'Sistem denetim noktaları için uyarı tanımlama'}]
	],
	['Araçlar', '', {'tw':'_self','tt':'Algılama araçları','sb':'Algılama araçları'},
		['Otomatik Sistem Algılama', 'sisiya_admin.php?menu=autodiscover', {'tw':'_self','tt':'Aşağıdaki sistemleri otomatik algılama','sb':'Ağdaki sistemleri otomatik algılama'}],
		['SisIYA ya İleti Gönderme', 'sisiya_admin.php?menu=send_message', {'tw':'_self','tt':'SisIYA ya ileti gönderme tanımları','sb':'SisIYA ya ileti gönderme tanımları'}],
		['Resim Yükleme', 'sisiya_admin.php?menu=upload_images', {'tw':'_self','tt':'Resim Yükleme','sb':'Resim Yükle'}],
	],
	['Yapılandırma', '', {'tw':'_self','tt':'Yapılandırma','sb':'Yapılandırma'},
		['Uzaktan Denetimler', 'sisiya_admin.php?menu=remote_checks', {'tw':'_self','tt':'Uzaktan yapılan denetimlerin yapılandırması','sb':'Uzaktan yapılan denetimlerin yapılandırması'}],
		['Diller', '', {'tw':'_self','tt':'SisIYA arayüzü dilleri ile ilgili işlemler','sb':'SisIYA arayüzü dilleri ile ilgili işlemler'},
			['Diller', 'sisiya_admin.php?menu=languages', {'tw':'_self','tt':'Dil ekleme, çıkarma ve değiştirme','sb':'Dil ekleme, çıkarma ve değiştirme'}],
			['Arayüz', 'sisiya_admin.php?menu=translate_language', {'tw':'_self','tt':'SisIYA arayüzü ile ilgili işlem ve değişiklikler','sb':'SisIYA arayüzü ile ilgili işlem ve değişiklikler'}],
			['Anahtar Sözcükler', 'sisiya_admin.php?menu=strkeys', {'tw':'_self','tt':'Anahtar sözcük tanımlama','sb':'Anahtar sözcük tanımlama'}],
			['İndirme / Yükleme', 'sisiya_admin.php?menu=import_export_language', {'tw':'_self','tt':'Dil dosyası indirme / yükleme','sb':'Dil dosyasını indirme / yükleme'}]
		]
	],
	['Kullanıcılar', '', {'tw':'_self','tt':'Kullanıcılar','sb':'Kullanıcılar'},
		['Kullanıcı Özellikleri', 'sisiya_admin.php?menu=user_properties', {'tw':'_self','tt':'Kullanıcıya ait özellikler','sb':'Kullanıcıya ait özellikler'}],
		['Kullanıcılar', 'sisiya_admin.php?menu=users', {'tw':'_self','tt':'Kullanıcı ekleme/değiştirme','sb':'Kullanıcı ekleme/değiştirme'}],
		['Şifre Değiştirme', 'sisiya_admin.php?menu=change_password', {'tw':'_self','tt':'Şifre Değiştirme','sb':'Şifre Değiştirme'}],
	]
];
