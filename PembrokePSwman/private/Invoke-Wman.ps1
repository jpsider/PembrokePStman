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
        Write-Log -Message "Gathering Local Properties from: $PropertyFilePath" -OutputStyle ConsoleOnly
        $PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
        $RestServer = $PpsProperties.'system.RestServer'
        $ID = $PpsProperties.'component.Id'
     } else {
        Write-Log -Message "Unable to Locate Local properties file: $PropertyFilePath." -OutputStyle ConsoleOnly
        Throw "Unable to Locate Properties file."
    }
    try
    {
        $script:WmanRunning = "Running"
        do {
            # Test connection with the Database Server
            Write-Log -Message "Starting Invoke-Wman loop" -OutputStyle ConsoleOnly
            if (Test-Connection -Count 1 $RestServer -Quiet) {
                # No Action needed if the RestServer can be reached.
            } else {
                $script:WmanRunning = "Shutdown"
                Write-Log -Message "Unable to reach RestServer: $RestServer." -OutputStyle ConsoleOnly
                Throw "Unable to reach Rest server: $RestServer."
            }
			Write-Log -Message "Validated Connection to RestServer: $RestServer." -OutputStyle ConsoleOnly 
            # Get the Status and Workflow Manager Specific Information from the Database
            $WmanStatusData = Get-WmanStatus -ComponentId $ID -RestServer $RestServer
            $WorkflowManagerStatus = $WmanStatusData.STATUS_ID
            $LOG_FILE = $WmanStatusData.LOG_FILE
            $ManagerWait = $WmanStatusData.WAIT
            $MAX_CONCURRENT_TASKS = $WmanStatusData.MAX_CONCURRENT_TASKS
            $WORKFLOW_MANAGER_TYPE_ID = $WmanStatusData.WORKFLOW_MANAGER_TYPE_ID
			Write-Log -Message "Get-WmanStatus is complete" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            $TableName = Get-WmanTableName -RestServer $RestServer -Type_ID $WORKFLOW_MANAGER_TYPE_ID
			Write-Log -Message "Get WmanTablename is complete, TableName: $TableName" -OutputStyle ConsoleOnly
            # Based on the Status Perform Specific actions
            Write-Log -Message "WorkflowManager ID:                     $ID" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "WorkflowManager Status:                 $WorkflowManagerStatus" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "WorkflowManager TableName :             $TableName" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "WorkflowManager Wait:                   $ManagerWait" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "WorkflowManager MAX_CONCURRENT_TASKS:   $MAX_CONCURRENT_TASKS" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "WorkflowManager LogFile:                $LOG_FILE" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            if ($WorkflowManagerStatus -eq 1) {
                # Down - Not doing Anything
                Write-Log -Message "Get-WmanStatus is Down, Not taking Action." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            } elseif ($WorkflowManagerStatus -eq 2) {
                # Up - Perform normal Tasks
                Write-Log -Message "Get-WmanStatus is UP, performing Normal Operations" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Write-Log -Message "Reviewing Assigned Tasks" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-ReviewAssignedTaskSet -RestServer $RestServer -TableName $TableName -MAX_CONCURRENT_TASKS $MAX_CONCURRENT_TASKS
                Write-Log -Message "Normal Operations Completed." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            } elseif ($WorkflowManagerStatus -eq 3) {
                # Starting Up - Perform startup Tasks
                Write-Log -Message "Performting Startup Tasks" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-WmanStartupTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                Write-Log -Message "Startup Tasks Completed." -Logfile $LOG_FILE -OutputStyle ConsoleOnly
            } elseif ($WorkflowManagerStatus -eq 4) {
                # Shutting Down - Perform Shutdown Tasks
                Write-Log -Message "Performing Shutdown tasks." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-WmanShutdownTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                $script:WmanRunning = "Shutdown"
                Write-Log -Message "Shutdown tasks completed." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            }
            Write-Log -Message "Manager running String: $script:WmanRunning" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            if($script:WmanRunning -ne "Shutdown"){
                Write-Log -Message "Waiting $ManagerWait Seconds" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-Wait -Seconds $ManagerWait
            }
        } while ($script:WmanRunning -ne "Shutdown")
        Write-Log -Message "Exiting WorkflowManager Function." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-Wman: $ErrorMessage $FailedItem"
    }
    
}