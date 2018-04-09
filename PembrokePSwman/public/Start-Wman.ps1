function Start-Wman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER PropertyFilePath
        A PropertyFilePath is required.
	.EXAMPLE
        Start-Wman -RestServer -localhost 
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([hashtable])]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][string]$PropertyFilePath
    )
    begin {
        if (Test-Connection -Count 1 $RestServer -Quiet) {
            # No Action needed if the RestServer can be reached.
        } else {
            Throw "Start-Wman: Unable to reach web server."
        }
        if (Test-Path -Path $PropertyFilePath) {
			# Gather Local Properties for the Workflow Manager
			$PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
			$RestServer = $PpsProperties.'system.RestServer'
            $ResultsDirectory = $PpsProperties.'system.LogDirectory'
            $SystemRoot = $PpsProperties.'system.Root'
			# Create Logfile Path
			$LOG_FILE = $ResultsDirectory + "\Task_$TaskId" + ".log"
			Write-LogLevel -Message "Gathering Local Properties from: $PropertyFilePath" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
		} else {
			Write-LogLevel -Message "Unable to Locate Local properties file: $PropertyFilePath." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
			Throw "Start-Wman: Unable to Locate Properties file."
		} 
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Performing Start-Wman."))
        {
            try
            {
                Write-LogLevel -Message "lamp" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
                If(Get-PpsProcessStatus -ProcessName WmanKicker){
                    Write-LogLevel -Message "WmanKicker is running." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel ERROR
                } else {
                    # Start the Process
                    $ExecutionWrapperPath = $SystemRoot + "\wman\bin\Invoke-NewConsole.ps1"
                    Write-LogLevel -Message "Starting Wman Kicker Process" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
                    Start-Process -WindowStyle Normal powershell.exe -ArgumentList "-file $ExecutionWrapperPath", "-FunctionName Invoke-WmanKicker -PropertyFilePath $PropertyFilePath"
                }
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName		
                Throw "Start-Wman: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}