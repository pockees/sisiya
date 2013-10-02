#include<windows.h>
#include<iostream>

//! Log an event for the specified application.
void logEvent(std::string appName,std::string message,WORD type);