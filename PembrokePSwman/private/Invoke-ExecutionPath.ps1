function Invoke-ExecutionPath {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER ExecutionPath
        A ExecutionPath is required.
	.EXAMPLE
        Invoke-ExecutionPath -ExecutionPath C:\PembrokePS\wman\scripts\somefile.ps1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$ExecutionPath
    )
    try
    {
		# Validate the Path Exists and Perform the task.
		if(Test-Path -Path $ExecutionPath){
			Write-LogLevel -Message "Executing Script: $ExecutionPath, with Args: $Task_Args" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            . "$ExecutionPath" $Task_Args
		} else {
			$script:TaskResult = 4
			Write-LogLevel -Message "File: $ExecutionPath does not exist." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel ERROR  
        }
        return $script:TaskResult
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-ExecutionPath: $ErrorMessage $FailedItem"
    }

}