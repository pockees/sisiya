/*
    Copyright (C) 2003 - 2012  Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#pragma once

using namespace System;
using namespace System::Threading;
using namespace System::Collections;
using namespace System::ServiceProcess;
using namespace System::ComponentModel;
//#include <string>

namespace SisIYA
{
	static const char *progName="SisIYA_cron";

	public __gc class SisIYA_cron : public System::ServiceProcess::ServiceBase 
	{
		public:
			SisIYA_cron() 
			{
					InitializeComponent();    
					serviceName = "SisIYA_cron";
					//logName = "SisIYA_cron";
			}

			/// <summary>
			/// Clean up any resources being used.
			/// </summary>
			void Dispose(bool disposing)
			{
				if(disposing && components)
					components->Dispose();
				__super::Dispose(disposing);
			}
		
		protected:
			//! Start the service.
			void OnStart(String* args[])
			{
				//Threading::ThreadStart* threadStart=new Threading::ThreadStart(this,mainLoop);
				ThreadStart* threadStart = new ThreadStart(this, &SisIYA::SisIYA_cron::mainLoop);
				serviceThread = new Thread(threadStart);
				serviceThread->Start();
			}

			//! The main loop.
			void mainLoop(void);

			//! Stop this service.
			void OnStop() { stopping = true; }
    		
		private:
			//! Required designer variable.
			System::ComponentModel::Container *components;
			const char *serviceName;
			bool stopping;
			int loopsleep;	//milliseconds
			Threading::Thread* serviceThread;
			//std::string logName;

			//! Required method for Designer support - do not modify the contents of this method with the code editor.
			void InitializeComponent(void)
			{
				// 
				// SisIYA_cronWinService
				// 
				this->CanPauseAndContinue = true;
				this->ServiceName = S"SisIYA_cron";

			}
	};
}