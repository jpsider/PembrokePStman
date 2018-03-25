$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-UpdateWmanData function for $moduleName" {
    function Invoke-UpdateComponent{}
    It "Should not Throw" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-UpdateComponent' -MockWith {
            1
        }
        {Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateComponent' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the update is not complete." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-UpdateComponent' -MockWith {}
        {Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateComponent' -Times 2 -Exactly
    }
}