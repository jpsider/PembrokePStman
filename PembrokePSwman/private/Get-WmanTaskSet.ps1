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
            $url = "http://$RestServer/PembrokePS/public/api/api.php/" + $TableName + "?filter=status_id,eq," + $Status_ID + '&filter=workflow_manager_id,eq,' + $WmanId + '&transform=1'
            $TaskData = (Invoke-RestMethod -Method Get -Uri "$url" -UseBasicParsing).$TableName
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-WmanTaskSet: $ErrorMessage $FailedItem"
        }
        $TaskData
    } else {
        Throw "Unable to reach Rest server: $RestServer."
    }
    
}