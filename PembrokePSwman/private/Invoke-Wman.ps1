function Invoke-Wman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Workflow_Manager
    .PARAMETER PropertyFilePath
        A properties path is Required.
	.EXAMPLE
        Invoke-Wman -PropertyFilePath "c:\pps\Wman\pembrokeps.properties"
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$PropertyFilePath
    )
    if (Test-Path -Path $PropertyFilePath) {
        # Gather Local Properties for the Workflow Manager
        Write-LogLevel -Message "Gathering Local Properties from: $PropertyFilePath" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
        $PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
        $RestServer = $PpsProperties.'system.RestServer'
        $ID = $PpsProperties.'component.Id'
        $RunLogLevel = $PpsProperties.'component.RunLogLevel'
     } else {
        Write-LogLevel -Message "Unable to Locate Local properties file: $PropertyFilePath." -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
        Throw "Invoke-Wman: Unable to Locate Properties file."
    }
    try
    {
        $script:WmanRunning = "Running"
        do {
            # Test connection with the Database Server
            Write-LogLevel -Message "Starting Invoke-Wman loop" -RunLogLevel $RunLogLevel -MsgLevel INFO
            if (Test-Connection -Count 1 $RestServer -Quiet) {
                # No Action needed if the RestServer can be reached.
            } else {
                $script:WmanRunning = "Shutdown"
                Write-LogLevel -Message "Unable to reach RestServer: $RestServer." -RunLogLevel $RunLogLevel -MsgLevel ERROR
                Throw "Invoke-Wman: Unable to reach Rest server: $RestServer."
            }
			Write-LogLevel -Message "Validated Connection to RestServer: $RestServer." -RunLogLevel $RunLogLevel -MsgLevel INFO 
            # Get the Status and Workflow Manager Specific Information from the Database
            $WmanStatusData = Get-WmanStatus -ComponentId $ID -RestServer $RestServer
            $WorkflowManagerStatus = $WmanStatusData.STATUS_ID
            $LOG_FILE = $WmanStatusData.LOG_FILE
            $ManagerWait = $WmanStatusData.WAIT
            $MAX_CONCURRENT_TASKS = $WmanStatusData.MAX_CONCURRENT_TASKS
            $WORKFLOW_MANAGER_TYPE_ID = $WmanStatusData.WORKFLOW_MANAGER_TYPE_ID
			Write-LogLevel -Message "Get-WmanStatus is complete" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
            $TableName = Get-WmanTableName -RestServer $RestServer -Type_ID $WORKFLOW_MANAGER_TYPE_ID
			Write-LogLevel -Message "Get WmanTablename is complete, TableName: $TableName" -RunLogLevel $RunLogLevel -MsgLevel INFO
            # Based on the Status Perform Specific actions
            Write-LogLevel -Message "WorkflowManager ID:                     $ID" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager Status:                 $WorkflowManagerStatus" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager TableName :             $TableName" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager Wait:                   $ManagerWait" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager MAX_CONCURRENT_TASKS:   $MAX_CONCURRENT_TASKS" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "WorkflowManager LogFile:                $LOG_FILE" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            if ($WorkflowManagerStatus -eq 1) {
                # Down - Not doing Anything
                Write-LogLevel -Message "Get-WmanStatus is Down, Not taking Action." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel ERROR 
            } elseif ($WorkflowManagerStatus -eq 2) {
                # Up - Perform normal Tasks
                Write-LogLevel -Message "Get-WmanStatus is UP, performing Normal Operations" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Write-LogLevel -Message "Reviewing Assigned Tasks" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Invoke-ReviewAssignedTaskSet -RestServer $RestServer -TableName $TableName -MAX_CONCURRENT_TASKS $MAX_CONCURRENT_TASKS
                Write-LogLevel -Message "Normal Operations Completed." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
            } elseif ($WorkflowManagerStatus -eq 3) {
                # Starting Up - Perform startup Tasks
                Write-LogLevel -Message "Performting Startup Tasks" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Invoke-WmanStartupTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                Write-LogLevel -Message "Startup Tasks Completed." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            } elseif ($WorkflowManagerStatus -eq 4) {
                # Shutting Down - Perform Shutdown Tasks
                Write-LogLevel -Message "Performing Shutdown tasks." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Invoke-WmanShutdownTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                $script:WmanRunning = "Shutdown"
                Write-LogLevel -Message "Shutdown tasks completed." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            }
            Write-LogLevel -Message "Manager running String: $script:WmanRunning" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
            if($script:WmanRunning -ne "Shutdown"){
                Write-LogLevel -Message "Waiting $ManagerWait Seconds" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Invoke-Wait -Seconds $ManagerWait
            }
        } while ($script:WmanRunning -ne "Shutdown")
        Write-LogLevel -Message "Exiting WorkflowManager Function." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-Wman: $ErrorMessage $FailedItem"
    }
    
}