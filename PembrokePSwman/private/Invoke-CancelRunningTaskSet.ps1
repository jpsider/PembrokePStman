function Invoke-CancelRunningTaskSet {
    <#
	.DESCRIPTION
		This function will Set any Running task to Cancelled.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
    .PARAMETER ID
        An ID is Required.
	.EXAMPLE
        Invoke-CancelRunningTaskSet -RestServer localhost -TableName tasks
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
            # Get a list of Running tasks
            $TableName = $TableName.ToLower()
            Write-LogLevel -Message "Gathering Running Tasks for Wman: $ID from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $RunningTasks = (Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 8 -WmanId $ID).$TableName
            $RunningTasksCount = ($RunningTasks | Measure-Object).count
            Write-LogLevel -Message "Cancelling: $RunningTasksCount tasks from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            if($RunningTasksCount -gt 0) {
                foreach($Task in $RunningTasks){
                    # Foreach task, set it to Complete/Aborted.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "10"
                                RESULT_ID = "6"
                            }
                    Write-LogLevel -Message "Cancelling Running task: $TaskId from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                    $RestReturn = Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                }
            } else {
                # No tasks to Cancel
                Write-LogLevel -Message "No Tasks to Cancel for Wman: $ID" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Invoke-CancelRunningTaskSet: $ErrorMessage $FailedItem"
        }
        $RestReturn
    } else {
        Throw "Invoke-CancelRunningTaskSet: Unable to reach Rest server: $RestServer."
    }
}