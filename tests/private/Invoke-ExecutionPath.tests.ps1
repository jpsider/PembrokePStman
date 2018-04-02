$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-ExecutionPath function for $moduleName" {
    function Write-LogLevel{}
    function Test-Path{}
    It "Should not throw" {
        function Start-Process{}
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Start-Process' -MockWith {}
        {Invoke-ExecutionPath -FileExecPath C:\PembrokePS\wman\scripts\somefile.ps1} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Start-Process' -Times 1 -Exactly
    }
    It "Should not Throw if the path is not valid." {
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-ExecutionPath -FileExecPath C:\PembrokePS\wman\scripts\somefile.ps1} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Throw if the Start-Process fails." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Start-Process' -MockWith {
            Throw "could not execute file."
        }
        {Invoke-ExecutionPath -FileExecPath C:\PembrokePS\wman\scripts\somefile.ps1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Start-Process' -Times 2 -Exactly
    }
}