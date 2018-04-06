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

    # Get System properties from Rest Server -> in pembrokepsRest
    # Install required Modules -> in pembrokepsrest
    # Create local directory structure -> In Utilities
        # Move Files -> In utilities?
    # Get Component specific properties. - > pembrokepsrest
    # Write Properties file  -> In utilities
            
            
            
            
            
            
            
            
            if(Test-Path -Path "$Destination\wman") {
                Write-LogLevel -Message "Directory: $Destination, exists." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
            } else {
                Write-LogLevel -Message "Creating \wman\data and \wman\logs Directories." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
                New-Item -Path "$Destination\wman\data" -ItemType Directory
                New-Item -Path "$Destination\wman\logs" -ItemType Directory
            }
            Write-LogLevel -Message "Installing Dependent Modules." -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
            Install-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber,RestPS -Force
            Import-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber,RestPS -Force
            Invoke-CreateRouteDirectorySet -InstallDirectory "$Destination\wman\rest"
            Write-LogLevel -Message "Copying Properties file to $Destination\wman\data" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
            Copy-Item -Path "$Source\data\pembrokeps.properties" -Destination "$Destination\wman\data" -Confirm:$false       
            Copy-Item -Path "$Source\bin\workflow_wrapper.ps1" -Destination "$Destination\wman\bin" -Confirm:$false
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