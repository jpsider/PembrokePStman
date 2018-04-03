# This is a shell for the Task to run in.
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
		Invoke-WorkflowWrapper -PropertyFilePath "c:\PembrokePS\Wman\data\pembrokeps.properties" -TaskId 1 -RestServer localhost -TableName tasks
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
		# Execute the Task
		Invoke-WorkflowWrapper -PropertyFilePath $PropertyFilePath -TableName $TableName -TaskId $TaskId -RestServer $RestServer
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName		
		Throw "Invoke-ExecuteTask: $ErrorMessage $FailedItem"
	}