$script:ModuleName = 'PembrokePSwman'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Start-AssignedTask function for $moduleName" {
    function Write-LogLevel{}
    It "Should not throw" {
        function Start-Process{}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Start-Process' -MockWith {}
        {Start-AssignedTask -RestServer dummyServer -TaskId 22} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Start-Process' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Start-AssignedTask -RestServer dummyServer -TaskId 22} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
    }
    It "Should Throw if the Return is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {
            Throw "Some error to be named later."
        }
        {Start-AssignedTask -RestServer dummyServer -TaskId 22} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Return false if -whatif is used." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Start-AssignedTask -RestServer dummyServer -TaskId 22 -whatif| Should be $false
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
    }
}