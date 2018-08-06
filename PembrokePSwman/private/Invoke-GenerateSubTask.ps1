function Invoke-GenerateSubTask {
    <#
	.DESCRIPTION
		This function will Create a subtask.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        An TableName is required.
    .PARAMETER TaskID
        An TaskID is required.
    .PARAMETER Body
        A Column/Field is required.
	.EXAMPLE
        Invoke-GenerateSubTask -RestServer localhost -SubTaskTypeId 2 -TableName tasks -Target_ID 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$TableName,
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$SubTaskTypeId,
        [Parameter(Mandatory=$true)][int]$Target_ID
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $body = @{STATUS_ID = "5"
                        RESULT_ID = "6"
                        LOG_FILE = "nolog"
                        WORKFLOW_MANAGER_ID = "9999"
                        TASK_TYPE_ID = "$SubTaskTypeId"
                        TARGET_ID = "$Target_ID"
                        ARGUMENTS = "NoArgs"
                        HIDDEN = "0"
            }
            Write-LogLevel -Message "Updating Task Table: $TableNAme, Task: $TaskId." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/$TableName"
            Write-LogLevel -Message "$URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $RestReturn = Invoke-RestMethod -Method Post -Uri "$URL" -body $body
            $ReturnData = @{NewTaskId = $RestReturn}
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Invoke-GenerateSubTask: $ErrorMessage $FailedItem"
        }
        $ReturnData
    } else {
        Throw "Invoke-GenerateSubTask: Unable to reach Rest server: $RestServer."
    }
}