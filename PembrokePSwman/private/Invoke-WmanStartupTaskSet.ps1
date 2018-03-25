function Invoke-WmanStartupTaskSet {
    <#
	.DESCRIPTION
		This function will perform shutdown tasks for a Workflow_Manager
    .PARAMETER RestServer
        A RestServer is Required.
    .PARAMETER TableName
        A properties path is Required.
    .PARAMETER ID
        An ID is Required.
	.EXAMPLE
        Invoke-WmanStartupTaskSet -RestServer localhost -TableName tasks -ID 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][string]$TableName,
        [Parameter(Mandatory=$true)][int]$ID
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $TableName = $TableName.ToLower()
            Invoke-CancelRunningTaskSet -RestServer $RestServer -TableName $TableName
            Invoke-Wait -Seconds 5
            Invoke-UpdateWmanData -ComponentId $ID -RestServer $RestServer -Column STATUS_ID -Value 2
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-WmanStartupTaskSet: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Unable to reach Rest server: $RestServer."
    }
}
    