function Get-WmanTaskSet {
    <#
	.DESCRIPTION
		This function will gather task information for a Wman in a with a specific task status.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, tasks is default.
    .PARAMETER Status_ID
        A Status_ID is required.
    .PARAMETER WmanId
        A WmanId is required.
	.EXAMPLE
        Get-WmanTaskSet -RestServer -localhost -Status_ID 7 -TableName tasks
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][String]$RestServer,
        [string]$TableName="Tasks",
        [Parameter(Mandatory=$true)][Int]$Status_ID,
        [Parameter(Mandatory=$true)][Int]$WmanId
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Gathering Wman Tasks with Status: $Status_ID, from table: $TableName." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/" + $TableName + "?filter[]=status_id,eq," + $Status_ID + '&filter[]=workflow_manager_id,eq,' + $WmanId + '&transform=1'
            Write-LogLevel -Message "Url is: $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $TaskData = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-WmanTaskSet: $ErrorMessage $FailedItem"
        }
        $TaskData
    } else {
        Throw "Get-WmanTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}