$script:ModuleName = 'PembrokePSwman'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-UpdateWmanData function for $moduleName" {
    function Write-LogLevel{}
    function Invoke-UpdateComponent{}
    It "Should not Throw" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-UpdateComponent' -MockWith {
            1
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateComponent' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
    }
    It "Should Throw if the update is not complete." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-UpdateComponent' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-UpdateWmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateComponent' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 3 -Exactly
    }
}