function Get-WmanTableName {
    <#
	.DESCRIPTION
		This function will gather The tableName for the Workflow Manager type.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Type_ID
        A Workflow Manager Type_ID is required.
	.EXAMPLE
        Get-WmanTableName -RestServer localhost -Type_ID 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$Type_ID
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Gathering TableName for Wman Type: $Type_ID." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/workflow_manager_type/$Type_ID"
            Write-LogLevel -Message "$URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $TableNameData = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Get-WmanTableName: $ErrorMessage $FailedItem"
        }
        $TableNameData
    } else {
        Throw "Get-WmanTableName: Unable to reach Rest server: $RestServer."
    }
}