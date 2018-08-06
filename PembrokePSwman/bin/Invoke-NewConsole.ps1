<#
.DESCRIPTION
	This Script will Execute a specified task, and submit any needed subtasks.
.PARAMETER PropertyFilePath
	A Rest PropertyFilePath is required.
.PARAMETER FunctionName
	A Rest PropertyFilePath is required.
.EXAMPLE
	Start-Process -WindowStyle Normal powershell.exe -ArgumentList "-file Invoke-NewConsole.ps1", "-PropertyFilePath $PropertyFilePath"
.NOTES
	This will execute a task against a specific target defined in the PembrokePS database.
#>
param(
	[Parameter(Mandatory=$true)][string]$PropertyFilePath,
    [Parameter(Mandatory=$true)][ValidateSet("Invoke-Wman", "Invoke-WmanKicker")]
    [string]$FunctionName
)
# Import required Modules
Get-Module -ListAvailable PembrokePS* | Import-Module
try
{
    switch ($FunctionName)
    {
        Invoke-WmanKicker {
            Invoke-WmanKicker -PropertyFilePath $PropertyFilePath
        }
        Invoke-Wman {
            Invoke-Wman -PropertyFilePath $PropertyFilePath
        }
    }
}
catch
{
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Throw "Invoke-NewConsole: $ErrorMessage $FailedItem"
}