function Invoke-UpdateWmanData {
    <#
	.DESCRIPTION
		This function will update a column and field for a Workflow_Manager
    .PARAMETER ComponentId
        An ID is required.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Column
        A Column/Field is required.
    .PARAMETER Value
        A Value is required.
	.EXAMPLE
        Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][int]$ComponentId,
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][string]$Column,
        [Parameter(Mandatory=$true)][string]$Value
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Updating Wman: $ComponentId, Column: $Column, Value: $Value" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            if ((Invoke-UpdateComponent -ComponentId $ComponentId -RestServer $RestServer -Column $Column -Value $Value -ComponentType workflow_manager) -eq 1) {
                # Good To go
            } else {
                Write-LogLevel -Message "Unable to update Wman: $ComponentId, Column: $Column, Value: $Value" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                Throw "Invoke-UpdateWmanData: Unable to update Wman data."
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-UpdateWmanData: $ErrorMessage $FailedItem"
        }
    } else {
        Throw "Invoke-UpdateWmanData: Unable to reach Rest server: $RestServer."
    }
    
}