$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-WmanShutdownTaskSet function for $moduleName" {
    function Invoke-Wait{}
    It "Should not be null" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-CancelRunningTaskSet' -MockWith {
            1
        }
        Mock -CommandName 'Invoke-QueueAssignedTaskSet' -MockWith {
            1
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {}
        Mock -CommandName 'Invoke-UpdateWmanData' -MockWith {
            1
        }
        Invoke-WmanShutdownTaskSet -RestServer localhost -TableName tasks -ID 1 | Should not be $null
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CancelRunningTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-QueueAssignedTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateWmanData' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-WmanShutdownTaskSet -RestServer localhost -TableName tasks -ID 1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {}
        Mock -CommandName 'Invoke-CancelRunningTaskSet' -MockWith { 
            Throw "(404) Not Found"
        }
        {Invoke-WmanShutdownTaskSet -RestServer localhost -TableName tasks -ID 1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CancelRunningTaskSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
    }
}