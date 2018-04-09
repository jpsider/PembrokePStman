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

            if($REGISTRATION_STATUS -eq 13){
                # Get Component Endpoint Port
                $EndpointPortData = (Get-EndpointPort -RestServer $RestServer -EndpointPortID $WKFLW_PORT_ID).endpoint_ports
                $Port = $EndpointPortData.PORT
                
                # Get System properties from Rest Server -> in pembrokepsRest
                $PropertyData = (Get-PpsPropertySet -RestServer $RestServer).properties
                $RequiredModuleSet = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.RequiredModules"}).PROP_VALUE
                $BaseWorkingDirectory = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.Root"}).PROP_VALUE
                $LogDirectory = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.LogDirectory"}).PROP_VALUE
                $ResultsDirectory = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.ResultsDirectory"}).PROP_VALUE
                $RunLogLevel = ($PropertyData | Where-Object {$_.PROP_NAME -eq "system.RunLogLevel"}).PROP_VALUE

                # Import required Modules -> in pembrokepsrest
                $RequiredModuleList = $RequiredModuleSet.split(",")
                Invoke-InstallRequiredModuleSet -RequiredModuleSet $RequiredModuleSet

                foreach($RequiredModule in $RequiredModuleList){
                    Get-Module -ListAvailable $RequiredModule | Import-Module
                }

                # Setup the local File directories
                if(Test-Path -Path "$BaseWorkingDirectory\wman") {
                    Write-LogLevel -Message "Directory: $BaseWorkingDirectory, exists." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
                } else {
                    Write-LogLevel -Message "Creating \wman\data and \wman\logs Directories." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
                    New-Item -Path "$BaseWorkingDirectory\wman\data" -ItemType Directory
                    New-Item -Path "$BaseWorkingDirectory\wman\logs" -ItemType Directory
                }
                Invoke-DeployPPSRest
                $WmanRoutesDestination = $SystemRoot + "\wman\data"
                $WmanEndpointRoutes = $BaseWorkingDirectory + "\wman\data\WmanEndpointRoutes.ps1"
                # Still need to get this file there!
                $Source=(Split-Path -Path (Get-Module -ListAvailable PembrokePSwman).path)
                $WmanEndpointRoutesSource = $Source + "\data\WmanEndpointRoutes.ps1"
                Write-LogLevel -Message "Copying Properties file to $BaseWorkingDirectory\wman\data" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
                Copy-Item -Path "$Source\scripts\*" -Destination "$BaseWorkingDirectory\wman\data\scripts" -Confirm:$false       
                Copy-Item -Path "$Source\bin\workflow_wrapper.ps1" -Destination "$BaseWorkingDirectory\wman\bin" -Confirm:$false
                Copy-Item -Path "$WmanEndpointRoutesSource" -Destination $WmanRoutesDestination -Confirm:$false -Force
                
                # Write Properties file  -> In utilities
                $PropertiesFile = "c:\PembrokePS\wman\pembrokeps.properties"
                Write-Output "system.RestServer=$RestServer" | Out-File $PropertiesFile
                Write-Output "system.LogDirectory=$LogDirectory" | Out-File $PropertiesFile -Append
                Write-Output "system.ResultsDirectory=$ResultsDirectory" | Out-File $PropertiesFile -Append
                Write-Output "system.Root=$BaseWorkingDirectory" | Out-File $PropertiesFile -Append
                Write-Output "component.Id=$Component_Id" | Out-File $PropertiesFile -Append
                Write-Output "component.Type=Workflow_Manager" | Out-File $PropertiesFile -Append
                Write-Output "component.RestPort=$Port" | Out-File $PropertiesFile -Append
                Write-Output "component.RunLogLevel=$RunLogLevel" | Out-File $PropertiesFile -Append
                Write-Output "component.logfile=$LOG_FILE" | Out-File $PropertiesFile -Append
                Write-Output "component.WmanEndpointRoutes=$WmanEndpointRoutes" | Out-File $PropertiesFile -Append
            }
            else 
            {
                Throw "Wman Component ID: $Component_Id is not Available to Register."
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-RegisterWman: $ErrorMessage $FailedItem"
        }
        $PropertiesFileData
    } else {
        Throw "Invoke-RegisterWman: Unable to reach web server."
    }
    
}