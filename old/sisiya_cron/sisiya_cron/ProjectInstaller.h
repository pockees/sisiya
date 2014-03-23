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
using namespace System::ComponentModel;
using namespace System::Collections;
using namespace System::Configuration::Install;


namespace SisIYA_cron
{
	[RunInstaller(true)]	

	/// <summary> 
	/// Summary for ProjectInstaller
	/// </summary>
	public __gc class ProjectInstaller : public System::Configuration::Install::Installer
	{
	public: 
		ProjectInstaller(void)
		{
			InitializeComponent();
		}
        
	protected: 
		void Dispose(Boolean disposing)
		{
			if (disposing && components)
			{
				components->Dispose();
			}
			__super::Dispose(disposing);
		}
	private: System::ServiceProcess::ServiceProcessInstaller *  serviceProcessInstaller1;
	private: System::ServiceProcess::ServiceInstaller *  serviceInstaller1;

	private:
		/// <summary>
		/// Required designer variable.
		/// </summary>
		System::ComponentModel::Container* components;
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>		
		void InitializeComponent(void)
		{
			this->serviceProcessInstaller1 = new System::ServiceProcess::ServiceProcessInstaller();
			this->serviceInstaller1 = new System::ServiceProcess::ServiceInstaller();
			// 
			// serviceProcessInstaller1
			// 
			this->serviceProcessInstaller1->Account = System::ServiceProcess::ServiceAccount::LocalSystem;
			this->serviceProcessInstaller1->Password = S"0";
			this->serviceProcessInstaller1->Username = S"0";
			// 
			// serviceInstaller1
			// 
			this->serviceInstaller1->DisplayName = S"SisIYA_cron";
			this->serviceInstaller1->ServiceName = S"SisIYA_cron";
			this->serviceInstaller1->StartType = System::ServiceProcess::ServiceStartMode::Automatic;
			// 
			// ProjectInstaller
			// 
			System::Configuration::Install::Installer* __mcTemp__1[] = new System::Configuration::Install::Installer*[2];
			__mcTemp__1[0] = this->serviceProcessInstaller1;
			__mcTemp__1[1] = this->serviceInstaller1;
			this->Installers->AddRange(__mcTemp__1);

		}
	};
}