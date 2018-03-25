function Invoke-CancelRunningTaskSet {
    <#
	.DESCRIPTION
		This function will Set any Running task to Cancelled.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
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
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Get a list of Running tasks
            $TableName = $TableName.ToLower()
            $RunningTasks = Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 8 -WmanId $ID
            $RunningTasksCount = ($RunningTasks | Measure-Object).count
            if($RunningTasksCount -gt 0) {
                foreach($Task in $RunningTasks){
                    # Foreach task, set it to Complete/Aborted.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "10"
                                RESULT_ID = "6"
                            }
                    $RestReturn = Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                }
            } else {
                # No tasks to queue
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
        Throw "Unable to reach Rest server: $RestServer."
    }
    
}