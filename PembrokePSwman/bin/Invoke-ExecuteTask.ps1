<#
.DESCRIPTION
	This Script will Execute a specified task, and submit any needed subtasks.
.PARAMETER PropertyFilePath
	A Rest PropertyFilePath is required.
.PARAMETER TaskId
	A TaskId is required.
.PARAMETER RestServer
	A RestServer is required.
.PARAMETER TableName
	A TableName is required.
.EXAMPLE
	Start-Process -WindowStyle Normal powershell.exe -ArgumentList "-file Invoke-ExecuteTask.ps1", "-PropertyFilePath $PropertyFilePath -RestServer $RestServer -TableName $TableName -TaskId $TaskId"
.NOTES
	This will execute a task against a specific target defined in the PembrokePS database.
#>
param(
	[Parameter(Mandatory=$true)][string]$PropertyFilePath,
	[String]$TableName="tasks",
	[Parameter(Mandatory=$true)][Int]$TaskId,
	[Parameter(Mandatory=$true)][string]$RestServer
)
# Import required Modules
Import-Module -Name PembrokePSrest,PembrokePSutilities,PembrokePSwman,PowerLumber,RestPS -Force
try
{
	$Host.UI.RawUI.WindowTitle = "Workflow_Wrapper TaskId:$ID"
	# Execute the Task
	Invoke-WorkflowWrapper -PropertyFilePath $PropertyFilePath -TableName $TableName -TaskId $TaskId -RestServer $RestServer
}
catch
{
	$ErrorMessage = $_.Exception.Message
	$FailedItem = $_.Exception.ItemName
	Throw "Invoke-ExecuteTask: $ErrorMessage $FailedItem"
}