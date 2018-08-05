$script:ModuleName = 'PembrokePSwman'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-ExecutionPath function for $moduleName" {
    function Write-LogLevel{}
    function Test-Path{}
    It "Should not throw if the script executes correctly." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-ExecutionPath -ExecutionPath "$here\PembrokePSwman\scripts\forUnitTests.ps1"} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
    }
    It "Should not Throw if the path is not valid." {
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-ExecutionPath -ExecutionPath C:\PembrokePS\wman\scripts\somefile.ps1} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Throw if the file execution fails." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        {Invoke-ExecutionPath -ExecutionPath C:\PembrokePS\wman\scripts\somefile.ps1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 3 -Exactly
    }
}