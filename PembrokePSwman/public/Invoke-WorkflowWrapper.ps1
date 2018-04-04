function Invoke-WorkflowWrapper {
	<#
	.DESCRIPTION
		This Script will Execute a specified task, and submit any needed subtasks.
	.PARAMETER PropertyFilePath
		A Rest PropertyFilePath is required.
	.PARAMETER TaskId
		A TaskId is required.
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
	begin {
		if (Test-Connection -Count 1 $RestServer -Quiet) {
			# No Action needed if the RestServer can be reached.
		} else {
			Throw "Workflow_Wrapper: Unable to reach web server."
		}
		if (Test-Path -Path $PropertyFilePath) {
			# Gather Local Properties for the Workflow Manager
			$PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
			$RestServer = $PpsProperties.'system.RestServer'
			$RunLogLevel = $PpsProperties.'component.RunLogLevel'
			$BaseWorkingDirectory = $PpsProperties.'system.Root'
			$WmanId = $PpsProperties.'component.Id'
			$ResultsDirectory = $PpsProperties.'system.LogDirectory'
			# Create Logfile Path
			$LOG_FILE = $ResultsDirectory + "\Task_$TaskId" + ".log"
			Write-LogLevel -Message "Gathering Local Properties from: $PropertyFilePath" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
		} else {
			Write-LogLevel -Message "Unable to Locate Local properties file: $PropertyFilePath." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
			Throw "Workflow_Wrapper: Unable to Locate Properties file."
		}     
		# Import Required Modules
		Write-LogLevel -Message "Importing Additional Required Modules." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
		Invoke-ImportWmanModuleSet -RestServer $RestServer -WmanId $WmanId
		# Get all the Task Information.
		Write-LogLevel -Message "Gathering information for task: $TaskId" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
		$TaskData = Get-TaskInfo -TaskId $TaskId -TableName $TableName -RestServer $RestServer
		
		# Set the task to running
		$body = @{STATUS_ID = "8"
					RESULT_ID = "6"
					LOG_FILE = "$LOG_FILE"
				}
		Write-LogLevel -Message "Setting Task: $TaskId to Running(8)" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
		Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
	}
	process
	{
		try
		{
			# Gather Specific task info
			$Task_Path = ($TaskData.task_types).TASK_PATH
			$Task_Args = ($TaskData).ARGUMENTS
			$Target_ID = ($TaskData).TARGET_ID
			$Target_Name = ($TaskData.targets).TARGET_NAME
			$Target_IP = ($TaskData.targets).IP_ADDRESS
			$TASK_TYPE_ID = ($TaskData).TASK_TYPE_ID
			# Set a place holder
			$script:TaskResult = 4
			# Build the Execution Path
			$ExecutionPath = $BaseWorkingDirectory + "\wman\scripts\" + $Task_Path
			# Validate the Path Exists and Perform the task.
			Write-LogLevel -Message "Target ID: $Target_ID, Target: $Target_Name, IP: $Target_IP" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
			Write-LogLevel -Message "Executing Script: $ExecutionPath, with Args: $Task_Args" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
			Invoke-ExecutionPath -ExecutionPath $ExecutionPath
			# Update the Database with the result
			$body = @{STATUS_ID = "9"
						RESULT_ID = "$script:TaskResult"
						LOG_FILE = "$LOG_FILE"
				}
			Write-LogLevel -Message "Setting Task: $TaskId to Complete(9) and Result: $script:TaskResult" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
			Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
			# Run SubTask Generator
			$SubTaskData = (Get-SubTaskData -Task_Type_Id $TASK_TYPE_ID -RestServer $RestServer).subtask_generator
			if($script:TaskResult -eq 1){
				$SubTaskId = (Invoke-GenerateSubTask -RestServer $RestServer -SubTaskTypeId ($SubTaskData.PASS_SUBTASK_ID) -TableName $TableName -Target_ID $Target_ID).NewTaskId
			} elseif($script:TaskResult -eq 2){
				$SubTaskId = (Invoke-GenerateSubTask -RestServer $RestServer -SubTaskTypeId ($SubTaskData.FAIL_SUBTASK_ID) -TableName $TableName -Target_ID $Target_ID).NewTaskId
			} else {
				$SubTaskId = "No SubTask"
			}
			Write-LogLevel -Message "Generated taskid: $SubTaskId" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
		}
		catch
		{
			$ErrorMessage = $_.Exception.Message
			$FailedItem = $_.Exception.ItemName		
			Throw "Invoke-WorkflowWrapper: $ErrorMessage $FailedItem"
		}
	}
}