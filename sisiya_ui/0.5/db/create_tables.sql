CREATE TABLE systemtypes (
	id	integer		NOT NULL,
	str	varchar(32)	NOT NULL,
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemtypes_pk ON systemtypes(id);

CREATE TABLE strkeys (
	id	integer		NOT NULL,
	keystr	varchar(256)	NOT NULL,
	str	text		NOT NULL,
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_keystrs_pk		ON strkeys(id);
CREATE UNIQUE INDEX index_keystrs_keystr	ON strkeys(keystr);

CREATE TABLE languages (
	id		integer		NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	code		varchar(8)	NOT NULL,
	charset		varchar(32)	NOT NULL,
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_languages_pk		ON languages(id);
CREATE UNIQUE INDEX index_languages_code	ON languages(code);
ALTER TABLE languages ADD CONSTRAINT fk_languages_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE properties (
	id	integer		NOT NULL,
	keystr	varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_properties_pk ON properties(id);
ALTER TABLE properties ADD CONSTRAINT fk_properties_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE services (
	id		integer		NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_services_pk ON services(id);
ALTER TABLE services ADD CONSTRAINT fk_services_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE status (
	id		integer	NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_status_pk ON status(id);
ALTER TABLE status ADD CONSTRAINT fk_status_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE interface (
	languageid	integer	NOT NULL REFERENCES languages(id),
	strkeyid	integer	NOT NULL REFERENCES strkeys(id),
	str		text	NOT NULL,
	primary key(languageid,strkeyid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_interface_pk		ON interface(languageid,strkeyid);
ALTER TABLE interface ADD CONSTRAINT fk_interface_languageid	FOREIGN KEY(languageid)	REFERENCES languages(id);
ALTER TABLE interface ADD CONSTRAINT fk_interface_strkeyid	FOREIGN KEY(strkeyid)	REFERENCES strkeys(id);

CREATE TABLE alerttypes (
	id		integer 	NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_alerttypes_pk		ON alerttypes(id);
ALTER TABLE alerttypes ADD CONSTRAINT fk_alerttypes_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE infos (
	id		integer 	NOT NULL,
	sortid		integer 	NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_infos_pk		ON infos(id);
ALTER TABLE infos ADD CONSTRAINT fk_infos_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE locations (
	id		integer NOT NULL,
	sortid		integer NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_locations_pk		ON locations(id);
ALTER TABLE locations ADD CONSTRAINT fk_locations_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE systems (
	id			integer		NOT NULL,
	active			char(1)		NOT NULL,
	systemtypeid		integer		NOT NULL REFERENCES systemtypes(id),
	locationid		integer		NOT NULL REFERENCES locations(id),
	hostname		varchar(32)	NOT NULL,
	fullhostname		varchar(64)	NOT NULL,
	effectsglobal		char(1)		NOT NULL,
	ip			varchar(256)	NOT NULL,
	mac			varchar(256)	NOT NULL,
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systems_pk		ON systems(id);
CREATE UNIQUE INDEX index_systems_hostname	ON systems(hostname);
CREATE UNIQUE INDEX index_systems_fullhostname	ON systems(fullhostname);
ALTER TABLE systems ADD CONSTRAINT fk_systems_systemtypeid	FOREIGN KEY(systemtypeid)	REFERENCES systemtypes(id);
ALTER TABLE systems ADD CONSTRAINT fk_systems_locationid	FOREIGN KEY(locationid)		REFERENCES locations(id);

CREATE TABLE users (
	id		integer		NOT NULL,
	username	varchar(32)	NOT NULL,
	password	varchar(256)	NOT NULL,
	name		varchar(64)	NOT NULL,
	surname		varchar(64)	NOT NULL,
	email		varchar(128)	NOT NULL,
	isadmin		char(1)		NOT NULL,
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_users_pk		ON users(id);
CREATE UNIQUE INDEX index_users_username	ON users(username);

CREATE TABLE scannedsystems (
	userid			integer		NOT NULL REFERENCES users(id),
	systemtypeid		integer		NOT NULL REFERENCES systemtypes(id),
	hostname		varchar(32)	NOT NULL,
	fullhostname		varchar(64)	NOT NULL,
	ip			varchar(256)	NOT NULL,
	mac			varchar(256)	NOT NULL,
	primary key(userid,hostname)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_scannedsystems_pk		ON scannedsystems(userid,hostname);
CREATE UNIQUE INDEX index_scannedsystems_hostname	ON scannedsystems(hostname);
CREATE UNIQUE INDEX index_scannedsystems_fullhostname	ON scannedsystems(fullhostname);
ALTER TABLE scannedsystems ADD CONSTRAINT fk_scannedsystems_userid		FOREIGN KEY(userid)		REFERENCES users(id);
ALTER TABLE scannedsystems ADD CONSTRAINT fk_scannedsystems_systemtypeid	FOREIGN KEY(systemtypeid)	REFERENCES systemtypes(id);


CREATE TABLE systeminfo (
	systemid	integer		NOT NULL REFERENCES systems(id),
	infoid		integer		NOT NULL REFERENCES infos(id),
	languageid	integer		NOT NULL REFERENCES languages(id),
	str		text		NOT NULL,
	primary key(systemid,infoid,languageid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systeminfo_pk	ON systeminfo(systemid,infoid,languageid);
ALTER TABLE systeminfo ADD CONSTRAINT fk_systeminfo_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systeminfo ADD CONSTRAINT fk_systeminfo_infoid	FOREIGN KEY(infoid)	REFERENCES infos(id);
ALTER TABLE systeminfo ADD CONSTRAINT fk_systeminfo_languageid	FOREIGN KEY(languageid)	REFERENCES languages(id);

CREATE TABLE systemservice (
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	languageid	integer		NOT NULL REFERENCES languages(id),
	active		char(1)		NOT NULL,
	starttime	char(14)	NOT NULL,
	str		text		NOT NULL,
	primary key(systemid,serviceid,languageid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemservice_pk	ON systemservice(systemid,serviceid,languageid);
ALTER TABLE systemservice ADD CONSTRAINT fk_systemservice_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemservice ADD CONSTRAINT fk_systemservice_serviceid	FOREIGN KEY(serviceid)	REFERENCES services(id);
ALTER TABLE systemservice ADD CONSTRAINT fk_systemservice_languageid	FOREIGN KEY(languageid)	REFERENCES languages(id);

CREATE TABLE systemhistorystatusall (
	sendtime	char(14)	NOT NULL,
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	recievetime	char(14)	NOT NULL,
	str		text,
	data		varchar(1024),
	primary key(sendtime,systemid,serviceid,statusid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemhistorystatusall_pk	ON systemhistorystatusall(sendtime,systemid,serviceid,statusid);
ALTER TABLE systemhistorystatusall ADD CONSTRAINT fk_systemhistorystatusall_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemhistorystatusall ADD CONSTRAINT fk_systemhistorystatusall_serviceid	FOREIGN KEY(serviceid)	REFERENCES services(id);
ALTER TABLE systemhistorystatusall ADD CONSTRAINT fk_systemhistorystatusall_statusid	FOREIGN KEY(statusid)	REFERENCES status(id);

CREATE TABLE systemhistorystatustmp (
	sendtime	char(14)	NOT NULL,
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	recievetime	char(14)	NOT NULL,
	str		text,
	data		varchar(1024),
	primary key(sendtime,systemid,serviceid,statusid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemhistorystatustmp_pk	ON systemhistorystatustmp(sendtime,systemid,serviceid,statusid);
ALTER TABLE systemhistorystatustmp ADD CONSTRAINT fk_systemhistorystatustmp_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemhistorystatustmp ADD CONSTRAINT fk_systemhistorystatustmp_serviceid	FOREIGN KEY(serviceid)	REFERENCES services(id);
ALTER TABLE systemhistorystatustmp ADD CONSTRAINT fk_systemhistorystatustmp_statusid	FOREIGN KEY(statusid)	REFERENCES status(id);

CREATE TABLE systemhistorystatusqueue (
	sendtime	char(14)	NOT NULL,
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	recievetime	char(14)	NOT NULL,
	str		text,
	data		varchar(1024),
	primary key(sendtime,systemid,serviceid,statusid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemhistorystatusqueue_pk	ON systemhistorystatusqueue(sendtime,systemid,serviceid,statusid);
ALTER TABLE systemhistorystatusqueue ADD CONSTRAINT fk_systemhistorystatusqueue_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemhistorystatusqueue ADD CONSTRAINT fk_systemhistorystatusqueue_serviceid	FOREIGN KEY(serviceid)	REFERENCES services(id);
ALTER TABLE systemhistorystatusqueue ADD CONSTRAINT fk_systemhistorystatusqueue_statusid	FOREIGN KEY(statusid)	REFERENCES status(id);

CREATE TABLE systemhistorystatus (
	sendtime	char(14)	NOT NULL,
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	recievetime	char(14)	NOT NULL,
	str		text		NOT NULL,
	data		varchar(1024),
	primary key(sendtime,systemid,serviceid,statusid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemhistorystatus_pk	ON systemhistorystatus(sendtime,systemid,serviceid);
ALTER TABLE systemhistorystatus ADD CONSTRAINT fk_systemhistorystatus_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemhistorystatus ADD CONSTRAINT fk_systemhistorystatus_serviceid	FOREIGN KEY(serviceid)	REFERENCES services(id);
ALTER TABLE systemhistorystatus ADD CONSTRAINT fk_systemhistorystatus_statusid	FOREIGN KEY(statusid)	REFERENCES status(id);

CREATE TABLE systemservicestatus (
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	updatetime	char(14)	NOT NULL,
	changetime	char(14)	NOT NULL,
	expires		integer		NOT NULL,
	str		text		NOT NULL,
	data		varchar(1024),
	primary key(systemid,serviceid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemservicestatus_pk	ON systemservicestatus(systemid,serviceid);
ALTER TABLE systemservicestatus ADD CONSTRAINT fk_systemservicestatus_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemservicestatus ADD CONSTRAINT fk_systemservicestatus_serviceid	FOREIGN KEY(serviceid)	REFERENCES services(id);
ALTER TABLE systemservicestatus ADD CONSTRAINT fk_systemservicestatus_statusid	FOREIGN KEY(statusid)	REFERENCES status(id);


CREATE TABLE systemstatus (
	systemid	integer		NOT NULL REFERENCES systems(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	updatetime	char(14)	NOT NULL,
	changetime	char(14)	NOT NULL,
	str		text		NOT NULL,
	primary key(systemid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemstatus_pk	ON systemstatus(systemid);
ALTER TABLE systemstatus ADD CONSTRAINT fk_systemstatus_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);
ALTER TABLE systemstatus ADD CONSTRAINT fk_systemstatus_statusid	FOREIGN KEY(statusid)	REFERENCES status(id);

CREATE TABLE securitygroups (
	id		integer		NOT NULL,
	keystr		varchar(256)	NOT NULL REFERENCES strkeys(keystr),
	primary key(id)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_securitygroups_pk ON securitygroups(id);
ALTER TABLE securitygroups ADD CONSTRAINT fk_securitygroups_keystr	FOREIGN KEY(keystr)	REFERENCES strkeys(keystr);

CREATE TABLE securitygroupsystem (
	securitygroupid		integer NOT NULL REFERENCES securitygroups(id),
	systemid		integer NOT NULL REFERENCES systems(id),
	primary key(securitygroupid,systemid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_securitygroupsystem_pk	ON securitygroupsystem(securitygroupid,systemid);
ALTER TABLE securitygroupsystem ADD CONSTRAINT fk_securitygroupsystem_securitygroupid	FOREIGN KEY(securitygroupid)	REFERENCES securitygroups(id);
ALTER TABLE securitygroupsystem ADD CONSTRAINT fk_securitygroupsystem_systemid		FOREIGN KEY(systemid)		REFERENCES systems(id);

CREATE TABLE securitygroupuser (
	securitygroupid		integer NOT NULL REFERENCES securitygroups(id),
	userid			integer NOT NULL REFERENCES users(id),
	primary key(securitygroupid,userid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_securitygroupuser_pk	ON securitygroupuser(securitygroupid,userid);
ALTER TABLE securitygroupuser ADD CONSTRAINT fk_securitygroupuser_securitygroupid	FOREIGN KEY(securitygroupid)	REFERENCES securitygroups(id);
ALTER TABLE securitygroupuser ADD CONSTRAINT fk_securitygroupuser_userid		FOREIGN KEY(userid)		REFERENCES users(id);

CREATE TABLE groups (
	id		integer		NOT NULL,
	languageid	integer		NOT NULL REFERENCES languages(id),
	userid		integer		NOT NULL REFERENCES users(id),
	sortid		integer		NOT NULL,
	str		varchar(64)	NOT NULL,
	primary key(id,languageid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_groups_pk ON groups(id,languageid);
ALTER TABLE groups ADD CONSTRAINT fk_groups_userid	FOREIGN KEY(userid)	REFERENCES users(id);
ALTER TABLE groups ADD CONSTRAINT fk_groups_languageid	FOREIGN KEY(languageid)	REFERENCES languages(id);

CREATE TABLE groupsystem (
	groupid		integer NOT NULL REFERENCES groups(id),
	systemid	integer NOT NULL REFERENCES systems(id),
	primary key(groupid,systemid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_groupsystem_pk	ON groupsystem(groupid,systemid);
ALTER TABLE groupsystem ADD CONSTRAINT fk_groupsystem_groupid	FOREIGN KEY(groupid)	REFERENCES groups(id);
ALTER TABLE groupsystem ADD CONSTRAINT fk_groupsystem_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);

CREATE TABLE usersystemalert (
	userid		integer		NOT NULL REFERENCES users(id),
	systemid	integer		NOT NULL REFERENCES systems(id),
	alerttypeid	integer		NOT NULL REFERENCES alerttypes(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	enabled		char(1)		NOT NULL,
	expire		integer		NOT NULL,
	alerttime	char(14)	NOT NULL,
	primary key(userid,systemid,alerttypeid,statusid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_usersystemalert_pk	ON usersystemalert(userid,systemid,alerttypeid,statusid);
ALTER TABLE usersystemalert ADD CONSTRAINT fk_usersystemalert_userid		FOREIGN KEY(userid)		REFERENCES users(id);
ALTER TABLE usersystemalert ADD CONSTRAINT fk_usersystemalert_systemid		FOREIGN KEY(systemid)		REFERENCES systems(id);
ALTER TABLE usersystemalert ADD CONSTRAINT fk_usersystemalert_alerttypeid	FOREIGN KEY(alerttypeid)	REFERENCES alerttypes(id);
ALTER TABLE usersystemalert ADD CONSTRAINT fk_usersystemalert_statusid		FOREIGN KEY(statusid)		REFERENCES status(id);


CREATE TABLE usersystemservicealert (
	userid		integer		NOT NULL REFERENCES users(id),
	systemid	integer		NOT NULL REFERENCES systems(id),
	serviceid	integer		NOT NULL REFERENCES services(id),
	alerttypeid	integer		NOT NULL REFERENCES alerttypes(id),
	statusid	integer		NOT NULL REFERENCES status(id),
	enabled		char(1)		NOT NULL,
	expire		integer		NOT NULL,
	alerttime	char(14)	NOT NULL,
	primary key(userid,systemid,serviceid,alerttypeid,statusid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_usersystemservicealert_pk	ON usersystemservicealert(userid,systemid,serviceid,alerttypeid,statusid);
ALTER TABLE usersystemservicealert ADD CONSTRAINT fk_usersystemservicealert_userid	FOREIGN KEY(userid)	 REFERENCES users(id);
ALTER TABLE usersystemservicealert ADD CONSTRAINT fk_usersystemservicealert_systemid	FOREIGN KEY(systemid) 	 REFERENCES systems(id);
ALTER TABLE usersystemservicealert ADD CONSTRAINT fk_usersystemservicealert_serviceid	FOREIGN KEY(serviceid) 	 REFERENCES services(id);
ALTER TABLE usersystemservicealert ADD CONSTRAINT fk_usersystemservicealert_alerttypeid	FOREIGN KEY(alerttypeid) REFERENCES alerttypes(id);
ALTER TABLE usersystemservicealert ADD CONSTRAINT fk_usersystemservicealert_statusid	FOREIGN KEY(statusid)	 REFERENCES status(id);

CREATE TABLE userproperties (
	userid		integer		NOT NULL REFERENCES users(id),
	propertyid	integer		NOT NULL REFERENCES properties(id),
	str		varchar(64)	NOT NULL,
	primary key(userid,propertyid)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_userproperties_pk	ON userproperties(userid,propertyid);
ALTER TABLE userproperties ADD CONSTRAINT fk_userproperties_userid	FOREIGN KEY(userid)	 REFERENCES users(id);
ALTER TABLE userproperties ADD CONSTRAINT fk_userproperties_propertyid	FOREIGN KEY(propertyid)	 REFERENCES properties(id);

CREATE TABLE systemswitch (
	switchid	integer		NOT NULL REFERENCES systems(id),
	port		integer		NOT NULL,
	status		char(1)		NOT NULL,
	isknown		char(1)		NOT NULL,
	isuplink	char(1)		NOT NULL,
	systemid	integer		NOT NULL REFERENCES systems(id),
	speed		varchar(32)	NOT NULL,
	duplex		char(1)		NOT NULL,
	vlan		integer		NOT NULL,
	primary key(switchid,port)
)
ENGINE = INNODB;
CREATE UNIQUE INDEX index_systemswitch_pk	ON systemswitch(switchid,port);
ALTER TABLE systemswitch ADD CONSTRAINT fk_systemswitch_switchid	FOREIGN KEY(switchid)	REFERENCES systems(id);
ALTER TABLE systemswitch ADD CONSTRAINT fk_systemswitch_systemid	FOREIGN KEY(systemid)	REFERENCES systems(id);

