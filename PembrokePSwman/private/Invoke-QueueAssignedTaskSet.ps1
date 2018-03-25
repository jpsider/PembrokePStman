function Invoke-QueueAssignedTaskSet {
    <#
	.DESCRIPTION
		This function will Queue any assigned tasks to the current Workflow_Manager.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
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
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Get a list of Assigned tasks
            $TableName = $TableName.ToLower()
            $AssignedTasks = Get-WmanTaskSet -RestServer $RestServer -TableName $TableName -STATUS_ID 7 -WmanId $ID
            $AssignedTasksCount = ($AssignedTasks | Measure-Object).count
            if($AssignedTasksCount -gt 0) {
                foreach($Task in $AssignedTasks){
                    # Foreach task, set it to Complete/Aborted.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "6"
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
            Throw "Invoke-QueueAssignedTaskSet: $ErrorMessage $FailedItem"
        }
        $RestReturn
    } else {
        Throw "Unable to reach Rest server: $RestServer."
    }
    
}