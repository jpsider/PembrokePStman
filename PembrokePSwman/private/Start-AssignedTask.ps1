function Start-AssignedTask {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TaskId
        A TaskId is required.
	.EXAMPLE
        Start-AssignedTask -RestServer -localhost -TaskId $TaskId
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
        [Parameter(Mandatory=$true)][Int]$TaskId
    )
    begin {
        if (Test-Connection -Count 1 $RestServer -Quiet) {
            # No Action needed if the RestServer can be reached.
        } else {
            Throw "Unable to reach Rest server: $RestServer."
        }
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Creating Headers."))
        {
            try
            {
                #Going to be creating a new record here, need to figure out the 'joins' to ensure the data is good.
                Write-Output "This function is not complete!"
                Start-Process -WindowStyle Normal powershell.exe -ArgumentList "-file $workflow_wrapper", "$TaskId", "$RestServer"
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName		
                Throw "Start-AssignedTask: $ErrorMessage $FailedItem"
            }
            #$QmanStatusData
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}