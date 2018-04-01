function Get-WmanModuleSet {
    <#
	.DESCRIPTION
		This function will gather Modules based on a WorkflowManager ID.
    .PARAMETER WmanId
        A Status is required.
    .PARAMETER RestServer
        A RestServer is Required.
	.EXAMPLE
        Get-WmanModuleSet -WmanId 1 -RestServer localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][String]$WmanId,
        [Parameter(Mandatory=$true)][String]$RestServer
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Gathering Modules for Workflow Manager: $WmanId." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/workflow_manager_modules?include=additional_ps_modules&filter[]=result_id,eq,1&filter[]=workflow_manager_id,eq," + $WmanId +"&transform=1"
            Write-LogLevel -Message "$URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $WmanModules = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-WmanModuleSet: $ErrorMessage $FailedItem"
        }
        $WmanModules
    } else {
        Throw "Get-WmanModuleSet: Unable to reach Rest server: $RestServer."
    }
    
}