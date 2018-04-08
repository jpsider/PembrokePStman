$script:ModuleName = 'PembrokePSwman'

Describe "Start-Wman function for $moduleName" {
    function Write-LogLevel{}
    function Invoke-NewConsole{}
    function Test-Path{}
    function Get-PpsProcessStatus{}
    function Test-Connection{}
    function Get-LocalPropertySet{}
    It "Should throw if the Rest Server cannot be reached" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Start-Wman -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 0 -Exactly
    }
    It "Should Throw if the path is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-path' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Start-Wman -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
    }
    It "Should Return false if -whatif is used." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Start-Wman -RestServer dummyServer -whatif | Should be $false
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should not throw if the kicker is running." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-NewConsole' -MockWith {}
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $true
        }
        {Start-Wman -RestServer dummyServer} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-NewConsole' -Times 0 -Exactly
    }
    It "Should not throw if the kicker is not running." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-NewConsole' -MockWith {}
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $false
        }
        {Start-Wman -RestServer dummyServer} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 7 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-NewConsole' -Times 1 -Exactly
    }
    It "Should throw if a command fails." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-NewConsole' -MockWith {
            throw "Failed to Invoke-NewConsole"
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $false
        }
        {Start-Wman -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 9 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-NewConsole' -Times 2 -Exactly
    }
}