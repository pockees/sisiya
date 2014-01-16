#include<iostream>
#include"SisIYAMessage.hpp"


// The List STL template requires overloading operators =, == and <

//! default constructor
SisIYAMessage::SisIYAMessage()
{
}

//! default destructor
SisIYAMessage::~SisIYAMessage()
{
}

//! Constructor with parameters
SisIYAMessage::SisIYAMessage(unsigned long int systemid,
			     unsigned long int serviceid,
			     unsigned short int statusid,
			     unsigned long int expr, string stime,
			     string rtime, string msg)
{
	this->systemID = systemid;
	this->serviceID = serviceid;
	this->statusID = statusid;
	this->expire = expr;
	this->recieveTimestamp = rtime;
	this->sendTimestamp = stime;
	this->message = msg;
}

//! Copy constructor
SisIYAMessage::SisIYAMessage(const SisIYAMessage & src)
{
	this->systemID = src.systemID;
	this->serviceID = src.serviceID;
	this->statusID = src.statusID;
	this->expire = src.expire;
	this->recieveTimestamp = src.recieveTimestamp;
	this->sendTimestamp = src.sendTimestamp;
	this->message = src.message;
}

//! Prints the SisIYA Message contents  
void SisIYAMessage::print(ostream * os)
{
	*os << "SisIYA Message:";
	*os << " systemID=" << systemID;
	*os << " serviceID=" << serviceID;
	*os << " statusID=" << statusID;
	*os << " expire=" << expire;
	*os << " send timestamp=" << sendTimestamp;
	*os << " recieve timestamp=" << recieveTimestamp;
	*os << " Message string=" << message << endl;
}

//! operator <<
ostream & operator<<(ostream & os, SisIYAMessage & p)
{
	p.print(&os);
	return os;
}

//! Assignment operator. 
SisIYAMessage & SisIYAMessage::operator=(const SisIYAMessage & src)
{
	this->systemID = src.systemID;
	this->serviceID = src.serviceID;
	this->statusID = src.statusID;
	this->expire = src.expire;
	this->recieveTimestamp = src.recieveTimestamp;
	this->sendTimestamp = src.sendTimestamp;
	this->message = src.message;
	return *this;
}

//! operator ==
int SisIYAMessage::operator==(const SisIYAMessage & m) const const
{
	if (this->systemID != m.systemID)
		return 0;
	if (this->serviceID != m.systemID)
		return 0;
	if (this->statusID != m.systemID)
		return 0;
	if (this->expire != m.systemID)
		return 0;
	if (this->recieveTimestamp != m.recieveTimestamp)
		return 0;
	if (this->sendTimestamp != m.sendTimestamp)
		return 0;
	if (this->message != m.message)
		return 0;
	// otherwise
	return 1;
}

//! operator <
int SisIYAMessage::operator<(const SisIYAMessage & m) const const
{
	// I do not use this functionality
	if (this->recieveTimestamp < m.recieveTimestamp)
		return 1;
	return 0;
}
