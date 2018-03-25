$script:ModuleName = 'PembrokePSWman'

Describe "Invoke-ReviewAssignedTaskSet function for $moduleName" {
    $ID = 1
    function Invoke-UpdateTaskTable{}
    function Start-AssignedTask{}
    function Invoke-Wait{}
    function Get-WmanTaskSet{}
    It "Should not throw, when there are no tasks to assign." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanTaskSet' -MockWith {
            1
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {}
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            1
        }
        Mock -CommandName 'Start-AssignedTask' -MockWith {
        }
        {Invoke-ReviewAssignedTaskSet -RestServer localhost -TableName tasks -MAX_CONCURRENT_TASKS 1} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanTaskSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Start-AssignedTask' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 0 -Exactly
    }
    It "Should not throw,when there are tasks to assign." {
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
        Mock -CommandName 'Start-AssignedTask' -MockWith {
        }
        Mock -CommandName 'Invoke-Wait' -MockWith{}
        {Invoke-ReviewAssignedTaskSet -RestServer localhost -TableName tasks -MAX_CONCURRENT_TASKS 2} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanTaskSet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Start-AssignedTask' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-ReviewAssignedTaskSet -RestServer localhost -TableName tasks -MAX_CONCURRENT_TASKS 3} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        $MAX_CONCURRENT_TASKS = 1
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanTaskSet' -MockWith {
            Throw "(404) Not Found"
        }
        {Invoke-ReviewAssignedTaskSet -RestServer localhost -TableName tasks -MAX_CONCURRENT_TASKS $MAX_CONCURRENT_TASKS} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanTaskSet' -Times 5 -Exactly
    }
}