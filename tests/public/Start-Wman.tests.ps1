$script:ModuleName = 'PembrokePSwman'

Describe "Start-Wman function for $moduleName" {
    function Write-LogLevel{}
    function Test-Path{}
    function Get-PpsProcessStatus{}
    function Test-Connection{}
    function Get-LocalPropertySet{}
    function Start-Process{}
    It "Should throw if the Rest Server cannot be reached" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Start-Wman -RestServer dummyServer -PropertyFilePath DummyFile} | Should -Throw
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
        {Start-Wman -RestServer dummyServer -PropertyFilePath DummyFile} | Should -Throw
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
        Start-Wman -RestServer dummyServer -PropertyFilePath DummyFile -whatif | Should be $false
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
        Mock -CommandName 'Start-Process' -MockWith {}
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $true
        }
        {Start-Wman -RestServer dummyServer -PropertyFilePath DummyFile} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Start-Process' -Times 0 -Exactly
    }
    It "Should not throw if the kicker is not running." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Start-Process' -MockWith {}
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $false
        }
        {Start-Wman -RestServer dummyServer -PropertyFilePath DummyFile} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 8 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Start-Process' -Times 1 -Exactly
    }
    It "Should throw if a command fails." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Start-Process' -MockWith {
            throw "Failed to Start-Process"
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $false
        }
        {Start-Wman -RestServer dummyServer -PropertyFilePath DummyFile} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 11 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Start-Process' -Times 2 -Exactly
    }
}