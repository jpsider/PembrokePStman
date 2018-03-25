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
            $TableName = (Invoke-RestMethod -Method Get -Uri "http://$RestServer/PembrokePS/public/api/api.php/workflow_manager_type/$Type_ID" -UseBasicParsing).TABLENAME
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-WmanTableName: $ErrorMessage $FailedItem"
        }
        $TableName
    } else {
        Throw "Unable to reach Rest server: $RestServer."
    }
    
}