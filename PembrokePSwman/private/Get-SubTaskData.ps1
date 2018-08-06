function Get-SubTaskData {
    <#
	.DESCRIPTION
		This function will gather Tasks based on a requested Status
    .PARAMETER Task_Type_Id
        A Status is required.
    .PARAMETER RestServer
        A RestServer is Required.
	.EXAMPLE
        Get-SubTaskData -Task_Type_Id 1 -RestServer localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][String]$Task_Type_Id,
        [Parameter(Mandatory=$true)][String]$RestServer
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Gathering SubTask data for Task_Type_Id: $Task_Type_Id." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/subtask_generator?filter=task_type_id,eq," + $Task_Type_Id + "&transform=1"
            Write-LogLevel -Message "$URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $SubTaskData = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Get-SubTaskData: $ErrorMessage $FailedItem"
        }
        $SubTaskData
    } else {
        Throw "Get-SubTaskData: Unable to reach Rest server: $RestServer."
    }
}