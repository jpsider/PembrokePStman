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
            $AssignedTasks = Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 7 -WmanId $ID
            $AssignedTasksCount = ($AssignedTasks | Measure-Object).count
            
            if($AssignedTasksCount -gt 0) {
                # Determine the number of Running Tasks.
                $RunningTasks = Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 8 -WmanId $ID
                $RunningTasksCount = ($RunningTasks | Measure-Object).count
                if(($RunningTasksCount -lt $MAX_CONCURRENT_TASKS) -and ($AssignedTasksCount -gt 0)) {
                    $Task = $AssignedTasks[0]
                    # Grab the First task in the list, and set it to staged.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "14"
                                RESULT_ID = "6"
                            }
                    Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                    # Start the Workflow Wrapper.
                    Start-AssignedTask -RestServer $RestServer -TaskId $TaskId
                    Invoke-Wait -Seconds 3
                    
                } else {
                    # No tasks to Start
                }
            } else {
                # No Tasks to Start
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-ReviewAssignedTaskSet: $ErrorMessage $FailedItem"
        }
    } else {
        Throw "Unable to reach Rest server: $RestServer."
    }
    
}