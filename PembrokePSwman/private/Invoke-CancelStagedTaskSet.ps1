function Invoke-CancelStagedTaskSet {
    <#
	.DESCRIPTION
		This function will Set any Staged task to Cancelled.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
    .PARAMETER ID
        An ID is Required.
	.EXAMPLE
        Invoke-CancelStagedTaskSet -RestServer localhost -TableName tasks
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
            # Get a list of Staged tasks
            $TableName = $TableName.ToLower()
            Write-LogLevel -Message "Gathering Staged Tasks for Wman: $ID from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $StagedTasks = (Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 14 -WmanId $ID).$TableName
            $StagedTasksCount = ($StagedTasks | Measure-Object).count
            Write-LogLevel -Message "Cancelling: $StagedTasksCount tasks from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            if($StagedTasksCount -gt 0) {
                foreach($Task in $StagedTasks){
                    # Foreach task, set it to Complete/Aborted.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "10"
                                RESULT_ID = "6"
                            }
                    Write-LogLevel -Message "Cancelling Staged task: $TaskId from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
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
            Throw "Invoke-CancelStagedTaskSet: $ErrorMessage $FailedItem"
        }
        $RestReturn
    } else {
        Throw "Invoke-CancelStagedTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}