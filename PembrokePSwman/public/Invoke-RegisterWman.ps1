function Invoke-RegisterWman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Component_Id
        A Component_Id is required.
    .PARAMETER Wman_Type
        A Wman_Type is Optional.
    .PARAMETER LocalDir
        A LocalDir is Optional.
	.EXAMPLE
        Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\PembrokePS
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][string]$Component_Id,
        [string]$Wman_Type = "Primary",
        [string]$LocalDir = "c:\PembrokePS"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Determine if the specified Component is already Registerred and gather component specific properties
            $ComponentStatus = (Get-ComponentStatus -ComponentType Workflow_Manager -ComponentId $Component_Id -RestServer $RestServer).workflow_manager
            $LOG_FILE = $ComponentStatus.LOG_FILE
            $REGISTRATION_STATUS = $ComponentStatus.REGISTRATION_STATUS_ID
            $WKFLW_PORT_ID = $ComponentStatus.WKFLW_PORT_ID

            # Get Component Endpoint Port
            $EndpointPortData = (Get-EndpointPort -RestServer $RestServer -EndpointPortID $WKFLW_PORT_ID).endpoint_ports
            $Port = $EndpointPortData.PORT
            
            # Get System properties from Rest Server -> in pembrokepsRest
            $PropertyData = (Get-PembrokePSproperties -RestServer $RestServer).properties

            $RequiredModules = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.RequiredModules"}).PROP_VALUE
            $BaseWorkingDirectory = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.Root"}).PROP_VALUE
            $LogDirectory = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.LogDirectory"}).PROP_VALUE
            $ResultsDirectory = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.LogDirectory"}).PROP_VALUE
            $RunLogLevel = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.RunLogLevel"}).PROP_VALUE

            # Import required Modules -> in pembrokepsrest
            $RequiredModuleList = $RequiredModules.split(",")
            foreach($RequiredModule in $RequiredModuleList){
                $localModuledataCount = (Get-Module -ListAvailable $RequiredModule | Measure-Object).count
                if($localModuledataCount -ge 1){
                    Get-Module -ListAvailable $RequiredModule | Import-Module
                } else {
                    Install-Module -Name $RequiredModule -Force
                    Get-Module -ListAvailable $RequiredModule | Import-Module
                }
            }
            
            # Setup the local File directories
            if(Test-Path -Path "$BaseWorkingDirectory\wman") {
                Write-LogLevel -Message "Directory: $BaseWorkingDirectory, exists." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
            } else {
                Write-LogLevel -Message "Creating \wman\data and \wman\logs Directories." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
                New-Item -Path "$BaseWorkingDirectory\wman\data" -ItemType Directory
                New-Item -Path "$BaseWorkingDirectory\wman\logs" -ItemType Directory
            }
            Invoke-CreateRouteDirectorySet -InstallDirectory "$BaseWorkingDirectory\wman\rest"
            Write-LogLevel -Message "Copying Properties file to $BaseWorkingDirectory\wman\data" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
            Copy-Item -Path "$Source\data\pembrokeps.properties" -Destination "$BaseWorkingDirectory\wman\data" -Confirm:$false       
            Copy-Item -Path "$Source\bin\workflow_wrapper.ps1" -Destination "$BaseWorkingDirectory\wman\bin" -Confirm:$false

            # Write Properties file  -> In utilities
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