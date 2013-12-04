create table alerttypes (
id integer not null,
str varchar(32),
primary key(id)
);

create table infos (
id integer not null,
sortid integer not null,
str varchar(32),
primary key(id)
);

create table languages (
id integer not null,
code varchar(8) not null unique,
str varchar(32) not null,
charset varchar(32) not null,
primary key(id)
);

create table locations (
id integer not null,
sortid integer not null,
str varchar(32),
primary key(id)
);

create table properties (
id integer not null,
str varchar(64) not null,
primary key(id)
);


create table services (
id integer not null,
str varchar(32),
primary key(id)
);

create table status (
id integer not null,
str varchar(32),
primary key(id)
);

create table strkeys (
id integer not null,
keystr varchar(256),
str text,
primary key(id)
);

create table interface (
languageid integer not null references languages(id),
strkeyid integer not null references strkeys(id),
str text not null,
primary key(languageid,strkeyid)
);

create table systemtypes (
id integer not null,
str varchar(32),
primary key(id)
);

create table systems (
id integer not null,
active char(1) not null,
systemtypeid integer not null references systemtypes(id),
locationid integer not null references locations(id),
hostname varchar(32) not null,
fullhostname varchar(64) not null,
effectsglobal char(1) not null,
primary key(id),
unique(hostname),
unique(fullhostname)
);

create table systeminfo (
systemid integer not null references systems(id),
infoid integer not null references infos(id),
str text,
primary key(systemid,infoid)
);

create table systemservice (
systemid integer not null references systems(id),
serviceid integer not null references services(id),
active char(1) not null,
starttime char(14) not null,
str text not null,
primary key(systemid,serviceid)
);

create table systemhistorystatusall (
sendtime char(14) not null,
systemid integer not null references systems(id),
serviceid integer not null references services(id),
statusid integer not null references status(id),
recievetime char(14) not null,
str text,
primary key(sendtime,systemid,serviceid,statusid)
);

create table systemhistorystatustmp (
sendtime char(14) not null,
systemid integer not null references systems(id),
serviceid integer not null references services(id),
statusid integer not null references status(id),
recievetime char(14) not null,
str text,
primary key(sendtime,systemid,serviceid,statusid)
);

create table systemhistorystatusqueue (
sendtime char(14) not null,
systemid integer not null references systems(id),
serviceid integer not null references services(id),
statusid integer not null references status(id),
recievetime char(14) not null,
str text,
primary key(sendtime,systemid,serviceid,statusid)
);

create table systemhistorystatus (
sendtime char(14) not null,
systemid integer not null references systems(id),
serviceid integer not null references services(id),
statusid integer not null references status(id),
recievetime char(14) not null,
str text,
primary key(sendtime,systemid,serviceid,statusid)
);

create table systemservicestatus (
systemid integer not null references systems(id),
serviceid integer not null references services(id),
statusid integer not null references status(id),
updatetime char(14) not null,
changetime char(14) not null,
expires integer not null,
str text,
primary key(systemid,serviceid)
);

create table systemstatus (
systemid integer not null references systems(id),
statusid integer not null references status(id),
updatetime char(14) not null,
changetime char(14) not null,
str text,
primary key(systemid)
);

create table users (
id integer not null,
username varchar(32) not null,
password varchar(256) not null,
name varchar(64) not null,
surname varchar(64) not null,
email varchar(128) not null,
isadmin char(1) not null,
primary key(id)
);

create table groups (
id integer not null,
userid integer not null references users(id),
sortid integer not null,
str varchar(64),
primary key(id)
);

create table groupsystem (
groupid integer not null references groups(id),
systemid integer not null references systems(id),
primary key(groupid,systemid)
);

create table usersystemalert (
userid integer not null references users(id),
systemid integer not null references systems(id),
alerttypeid integer not null references alerttypes(id),
statusid integer not null references status(id),
enabled char(1) not null,
expire integer not null,
alerttime char(14) not null,
primary key(userid,systemid,alerttypeid,statusid)
);

create table usersystemservicealert (
userid integer not null references users(id),
systemid integer not null references systems(id),
serviceid integer not null references services(id),
alerttypeid integer not null references alerttypes(id),
statusid integer not null references status(id),
enabled char(1) not null,
expire integer not null,
alerttime char(14) not null,
primary key(userid,systemid,serviceid,alerttypeid,statusid)
);

create table userproperties (
userid integer not null references users(id),
propertyid integer not null references properties(id),
str varchar(64) not null,
primary key(userid,propertyid)
);
