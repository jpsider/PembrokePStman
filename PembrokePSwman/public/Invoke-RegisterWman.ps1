function Invoke-RegisterWman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Invoke-RegisterWman -RestServer -localhost 
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            #Going to be creating a new record here, need to figure out the 'joins' to ensure the data is good.
            Write-LogLevel -Message "lamp" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-RegisterWman: $ErrorMessage $FailedItem"
        }
        #$QmanStatusData
    } else {
        Throw "Invoke-RegisterWman: Unable to reach web server."
    }
    
}