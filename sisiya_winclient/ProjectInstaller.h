#pragma once

using namespace System;
using namespace System::ComponentModel;
using namespace System::Collections;
using namespace System::Configuration::Install;


namespace SisIYAws
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
			this->serviceInstaller1->DisplayName = S"SisIYAws";
			this->serviceInstaller1->ServiceName = S"SisIYAws";
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