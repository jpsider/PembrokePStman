$script:ModuleName = 'PembrokePSWman'

Describe "Invoke-QueueAssignedTaskSet function for $moduleName" {
    $ID = 1
    function Invoke-UpdateTaskTable{}
    function Write-LogLevel{}
    It "Should not be null" {
        $RawReturn = @{
            tasks = @{
                ID            = '1'
                STATUS_ID     = '7'
                RESULT_ID       = '3'
            }               
        }
        $ReturnJson = $RawReturn | ConvertTo-Json
        $ReturnData = $ReturnJson | convertfrom-json
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanTaskSet' -MockWith {
            $ReturnData
        }
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            1
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Invoke-QueueAssignedTaskSet -RestServer localhost -TableName tasks | Should not be $null
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-QueueAssignedTaskSet -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanTaskSet' -MockWith {
            Throw "(404) Not Found"
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-QueueAssignedTaskSet -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanTaskSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 3 -Exactly
    }
    It "Should not Throw if there no assigned Tasks." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanTaskSet' -MockWith {
            $Data = $null
            return $Data
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-QueueAssignedTaskSet -RestServer localhost -TableName tasks} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanTaskSet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 5 -Exactly
    }
}