<#
.DESCRIPTION
	This Script will Execute a User specified task and return a 'Failed' result.
.EXAMPLE
    Start-Process -NoNewWindow powershell.exe -ArgumentList "-file $ExecutionPath" $Task_Args
        $ExecutionPath is the full path of this file. Any arguments can be passed in, but it's 
        up to the user to parse them as a string.
.NOTES
    This will execute a task against a specific target defined in the PembrokePS database.
.NOTES
    This script run inside the same shell as Invoke-WorkflowWrapper - it should have access to all
        System variables and task variables.
#>

Write-LogLevel -Message "This is the SampleFailTask.ps1 Script, with Args: $Task_Args" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG

$script:TaskResult = 2

Write-LogLevel -Message "The Result of the script is: $script:TaskResult." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG

Write-LogLevel -Message "Good Bye!" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG

return $script:TaskResult
