# Storage Migration Service Helper

This PowerShell script will gather the appropriate event logs of a Windows Server 2019 computer running the Storage Migration Service feature, then save them to a ZIP file. 
You should run this script against both the Orchestrator node and the transfer destination node when troubleshooting.
Always run from within an elevated PowerShell console.

*To use locally and save to the current folder*

PS C:\> `Import-Module .\StorageMigrationServiceHelper.psm1`

PS C:\> `help Get-SmsLogs`

*To use locally and save to a specified folder*

PS C:\> `Import-Module .\StorageMigrationServiceHelper.psm1`

PS C:\> `help Get-SmsLogs -Path *c:\temp*`

*To use remotely*

PS C:\> `Import-Module .\StorageMigrationServiceHelper.psm1`

PS C:\> `help Get-SmsLogs -Computer *Foo*`

## Legal and Licensing

PowerShell is licensed under the [MIT license][].

## [Code of Conduct][conduct-md]

This project has adopted the [Microsoft Open Source Code of Conduct][conduct-code].
For more information see the [Code of Conduct FAQ][conduct-FAQ] or contact [opencode@microsoft.com][conduct-email] with any additional questions or comments.

[conduct-code]: http://opensource.microsoft.com/codeofconduct/
[conduct-FAQ]: http://opensource.microsoft.com/codeofconduct/faq/
[conduct-email]: mailto:opencode@microsoft.com
