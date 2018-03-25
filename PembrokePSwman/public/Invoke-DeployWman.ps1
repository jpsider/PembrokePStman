function Invoke-DeployWman
{
    <#
	.DESCRIPTION
		Deploys artifacts to prepare a machine to run a PembrokePS Workflow Manager.
    .PARAMETER Destination
        A Destitnation path is optional.
    .PARAMETER Source
        A Source location for PembrokePS artifacts is optional.
	.EXAMPLE
        Invoke-DeployWman -Destination c:\PembrokePS -Source c:\OpenProjects\ProjectPembroke\PembrokePSwman
	.NOTES
        It will create the directory if it does not exist. Also install required Modules.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [String]$Destination="C:\PembrokePS\",
        [String]$Source=(Split-Path -Path (Get-Module -ListAvailable PembrokePSwman).path)
    )
    try
    {
        if(Test-Path -Path "$Destination\wman") {
            Write-Output "The wman Directory exists."
        } else {
            New-Item -Path "$Destination\wman\data" -ItemType Directory
            New-Item -Path "$Destination\wman\logs" -ItemType Directory
        }
        Install-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber,RestPS -Force
        Import-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber,RestPS -Force
        Invoke-CreateRouteDirectorySet -InstallDirectory "$Destination\wman\rest"
        Copy-Item -Path "$Source\data\pembrokeps.properties" -Destination "$Destination\wman\data" -Confirm:$false       
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-DeployWman: $ErrorMessage $FailedItem"
    }

}