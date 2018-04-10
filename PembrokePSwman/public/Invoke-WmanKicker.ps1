function Invoke-WmanKicker {   
   <#
    .DESCRIPTION
    	This Script runs in the background of the Workflow manager to help with health/mgmt of the component.
    .PARAMETER PropertyFilePath
        A properties path is Required.
    .EXAMPLE
        Invoke-WmanKicker -PropertyFilePath "c:\PembrokePS\Wman\pembrokeps.properties"
    .NOTES
        Nothing to see here.
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$PropertyFilePath
    )
    if (Test-Path -Path $PropertyFilePath) {
        # Gather Local Properties for the Workflow Manager
        $PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
        $RestServer = $PpsProperties.'system.RestServer'
        $SystemRoot = $PpsProperties.'system.root'
        $ID = $PpsProperties.'component.Id'
        $LOG_FILE = $PpsProperties.'component.logfile'
        $Port = $PpsProperties.'component.RestPort'
        $AvailableRoutesFile.'component.AvailableRoutesFile'
        Write-LogLevel -Message "Gathering Local Properties from: $PropertyFilePath, SystemRoot: $SystemRoot." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
    } else {
        Write-LogLevel -Message "Unable to Locate Local properties file: $PropertyFilePath." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
        Throw "Invoke-WmanKicker: Unable to Locate Properties file."
    }

    try
    {
        $script:WmanKickerRunning = "Running"
        do {
            # Test connection with the Database Server
            Write-LogLevel -Message "Starting Invoke-WmanKicker loop" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO
            if (Test-Connection -Count 1 $RestServer -Quiet) {
                $Host.UI.RawUI.WindowTitle = "WmanKicker WmanId:$ID"
            } else {
                $script:WmanKickerRunning = "Shutdown"
                Write-LogLevel -Message "Unable to reach RestServer: $RestServer." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel ERROR
                Throw "Invoke-Wman: Unable to reach Rest server: $RestServer."
            }
            Write-LogLevel -Message "Validated Connection to RestServer: $RestServer." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 

            # Get the Status and Workflow Manager Specific Information from the Database
            $WmanStatusData = Get-WmanStatus -ComponentId $ID -RestServer $RestServer
            $WorkflowManagerStatus = $WmanStatusData.STATUS_ID
            $ManagerWait = $WmanStatusData.WAIT

    		Write-LogLevel -Message "Get-WmanStatus is complete" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel DEBUG 
            # Based on the Status Perform Specific actions
            Write-LogLevel -Message "WorkflowManager ID:       $ID" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager Status:   $WorkflowManagerStatus" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager Wait:     $ManagerWait" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 

            # Check Wman Endpoint
            If(Get-PpsProcessStatus -ProcessName "Port:$Port"){
                Write-LogLevel -Message "Wman Endpoint is running." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel ERROR
            } else {
                # Start the Endpoint
                $SourceAvailableRoutesFile = $SystemRoot + "\wman\data\WmanEndpointRoutes.ps1"
                Invoke-StartPPSEndpoint -Port $Port -SourceAvailableRoutesFile $SourceAvailableRoutesFile
            }
            if ($WorkflowManagerStatus -eq 1) {
                # Down - Not doing Anything.
                Write-LogLevel -Message "Get-WmanStatus is Down, Not taking Action." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel ERROR 
            } elseif ($WorkflowManagerStatus -eq 2) {
                # Up - Not doing anything. 
                Write-LogLevel -Message "Get-WmanStatus is Up, Not taking Action." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel ERROR 
            } elseif ($WorkflowManagerStatus -eq 3) {
                # Starting Up - Perform startup Tasks
                Write-LogLevel -Message "Starting Up the Workflow Manager" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 
                # Start a new Window, then start the Invoke-Wman Function.
                $ExecutionPath = $SystemRoot + "\wman\bin\Invoke-NewConsole.ps1"
                # Check that the wman Process is not running
                If(Get-PpsProcessStatus -ProcessName WorkFlow_Manager){
                    Write-LogLevel -Message "Workflow Manager is running." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel ERROR
                } else {
                    # Start the Workflow Manager
                    Write-LogLevel -Message "Starting path: $ExecutionPath, PropertyFilePath: $PropertyFilePath, -FunctionName Invoke-Wman" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel INFO
                    Start-Process -WindowStyle Normal powershell.exe -ArgumentList "-file $ExecutionPath", "-PropertyFilePath $PropertyFilePath -FunctionName Invoke-Wman"
                    Write-LogLevel -Message "Workflow Manager Has been started. Giving the Manager 5min to start." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel DEBUG
                    Invoke-Wait -Seconds 300
                }
            } elseif ($WorkflowManagerStatus -eq 4) {
                # Shutting Down - Not doing anything.
                Write-LogLevel -Message "Get-WmanStatus is Shutdown, not taking action." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 
            }
            Write-LogLevel -Message "ManagerKicker is running, Waiting $ManagerWait, before checking status again." -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel DEBUG 
            Invoke-Wait -Seconds $ManagerWait
        } while ($script:WmanKickerRunning -ne "Shutdown")
        Write-LogLevel -Message "Exiting WorkflowManager Kicker Script" -Logfile $LOG_FILE -RunLogLevel CONSOLEONLY -MsgLevel INFO 
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-WmanKicker: $ErrorMessage $FailedItem"
    }
}
