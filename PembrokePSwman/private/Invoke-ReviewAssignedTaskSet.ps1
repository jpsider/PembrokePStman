function Invoke-ReviewAssignedTaskSet {
    <#
	.DESCRIPTION
		This function will Start an Assigned task if the Workflow Manager is under its max Concurrent tasks.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
    .PARAMETER MAX_CONCURRENT_TASKS
        A MAX_CONCURRENT_TASKS is required.
	.EXAMPLE
        Invoke-ReviewAssignedTaskSet -RestServer localhost -TableName tasks -MAX_CONCURRENT_TASKS 4
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([Int])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][Int]$MAX_CONCURRENT_TASKS,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Get a list of Running tasks
            $TableName = $TableName.ToLower()
            Write-LogLevel -Message "Reviewing Assigned tasks for Wman: $ID for table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $AssignedTasks = Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 7 -WmanId $ID
            $AssignedTasksCount = ($AssignedTasks | Measure-Object).count
            
            if($AssignedTasksCount -gt 0) {
                # Determine the number of Running Tasks.
                Write-LogLevel -Message "Determining if the Current Running tasks for Wman: $ID is over its Max: $MAX_CONCURRENT_TASKS." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                $RunningTasks = Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 8 -WmanId $ID
                $RunningTasksCount = ($RunningTasks | Measure-Object).count
                if(($RunningTasksCount -lt $MAX_CONCURRENT_TASKS) -and ($AssignedTasksCount -gt 0)) {
                    $Task = $AssignedTasks[0]
                    # Grab the First task in the list, and set it to staged.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "14"
                                RESULT_ID = "6"
                            }
                    Write-LogLevel -Message "Setting Task: $TaskId to Staged" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
                    Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                    # Start the Workflow Wrapper.
                    Write-LogLevel -Message "Starting Task: $TaskId." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
                    Start-AssignedTask -RestServer $RestServer -TaskId $TaskId
                    Invoke-Wait -Seconds 3
                    
                } else {
                    # Wman is at its Max.
                    Write-LogLevel -Message "Wman: $ID is at its max: $MAX_CONCURRENT_TASKS tasks." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                }
            } else {
                # No Tasks to Start
                Write-LogLevel -Message "No Tasks to start at this time." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-ReviewAssignedTaskSet: $ErrorMessage $FailedItem"
        }
    } else {
        Throw "Invoke-ReviewAssignedTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}