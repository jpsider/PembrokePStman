function Invoke-InstallWmanModuleSet {
    <#
	.DESCRIPTION
		This function will Install additional Modules for a Workflow_Manager.
    .PARAMETER RestServer
        A RestServer is Required.
    .PARAMETER WmanId
        An WmanId is Required.
	.EXAMPLE
        Invoke-InstallWmanModuleSet -RestServer localhost -WmanId 1
	.NOTES
        This will Install additional Modules for a Workflow_Manager.
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$WmanId
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Getting additional Required Modules for Workflow Manager: $WmanId." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $WmanModuleSet = ((Get-WmanModuleSet -WmanId $WmanId -RestServer $RestServer).workflow_manager_modules).additional_ps_modules | Where-Object {$_.STATUS_ID -eq 11}
            $WmanModuleSetCount = ($WmanModuleSet | Measure-Object).count
            if($WmanModuleSetCount -ge 1){
                foreach ($WmanModule in $WmanModuleSet) {
                    $ModuleName = $WmanModule.NAME
                    $GalleryName = $WmanModule.GALLERY_NAME
                    $Version = $WmanModule.MODULE_VERSION
                    Write-LogLevel -Message "Installing Module $ModuleName." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                    if($Version -eq "Latest"){
                        Install-Module -Name $GalleryName -Force
                    } else {
                        Install-Module -Name $GalleryName -RequiredVersion $Version -Force
                    }
                    Invoke-Wait -Seconds 2
                }
            } else {
                Write-LogLevel -Message "No Modules to Install." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-InstallWmanModuleSet: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Invoke-InstallWmanModuleSet: Unable to reach Rest server: $RestServer."
    }

}
    