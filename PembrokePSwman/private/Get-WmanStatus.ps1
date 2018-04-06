function Get-WmanStatus {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Workflow_Manager
    .PARAMETER ComponentId
        An ID is required.
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Get-WmanStatus -ComponentId 1 -RestServer localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][int]$ComponentId,
        [Parameter(Mandatory=$true)][string]$RestServer
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Gathering Component: $ComponentId Status." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $ComponentStatusData = (Get-ComponentStatus -ComponentType Workflow_Manager -ComponentId $ComponentId -RestServer $RestServer).workflow_manager
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-WmanStatus: $ErrorMessage $FailedItem"
        }
        $ComponentStatusData
    } else {
        Throw "Get-WmanStatus: Unable to reach Rest server: $RestServer."
    }
    
}