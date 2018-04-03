function Invoke-ExecutionPath {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER FileExecPath
        A FileExecPath is required.
	.EXAMPLE
        Invoke-ExecutionPath -FileExecPath C:\PembrokePS\wman\scripts\somefile.ps1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$FileExecPath
    )
    try
    {
		# Validate the Path Exists and Perform the task.
		if(Test-Path -Path $ExecutionPath){
			Write-LogLevel -Message "Executing Script: $ExecutionPath, with Args: $Task_Args" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            Start-Process -NoNewWindow powershell.exe -ArgumentList "-file $ExecutionPath" $Task_Args
		} else {
			$TaskResult = 4
			Write-LogLevel -Message "File: $ExecutionPath does not exist." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel ERROR  
        }
        $TaskResult
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-ExecutionPath: $ErrorMessage $FailedItem"
    }

}