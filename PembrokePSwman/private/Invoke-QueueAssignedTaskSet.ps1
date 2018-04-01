function Invoke-QueueAssignedTaskSet {
    <#
	.DESCRIPTION
		This function will Queue any assigned tasks to the current Workflow_Manager.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
    .PARAMETER ID
        An ID is Required.
	.EXAMPLE
        Invoke-QueueAssignedTaskSet -RestServer localhost -TableName tasks
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([Int])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$ID,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Get a list of Assigned tasks
            $TableName = $TableName.ToLower()
            Write-LogLevel -Message "Queueing Assigned tasks for WMan: $ID" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $AssignedTasks = (Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 7 -WmanId $ID).$TableName
            $AssignedTasksCount = ($AssignedTasks | Measure-Object).count
            Write-LogLevel -Message "Queueing $AssignedTasksCount Assigned tasks for WMan: $ID" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            if($AssignedTasksCount -gt 0) {
                foreach($Task in $AssignedTasks){
                    # Foreach task, set it to Complete/Aborted.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "6"
                                RESULT_ID = "6"
                            }
                    Write-LogLevel -Message "Queueing task: $Task_Id, from table: $TableName." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                    $RestReturn = Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                }
            } else {
                # No tasks to queue
                Write-LogLevel -Message "No Tasks to Queue for Wman: $ID." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-QueueAssignedTaskSet: $ErrorMessage $FailedItem"
        }
        $RestReturn
    } else {
        Throw "Invoke-QueueAssignedTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}