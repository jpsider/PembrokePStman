$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-InstallWmanModuleSet function for $moduleName" {
    function Write-LogLevel{}
    function Invoke-Wait {}
    function Get-WmanModuleSet{}
    It "Should not Throw an exception if the source directory does exist." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-WmanModuleSet' -MockWith {
            $RawReturn = @{
                workflow_manager_modules = @{
                    additional_ps_modules = @{
                        NAME            = 'PowerCLI'
                        GALLERY_NAME    = 'vmware.PowerCLI'
                        MODULE_VERSION  = 'Latest'
                        STATUS_ID       = '11'
                    }
                }
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        {Invoke-InstallWmanModuleSet -RestServer localhost -WmanId 1} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanModuleSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 1 -Exactly
        
    }
    It "Should not Throw an exception if the source directory does exist." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-WmanModuleSet' -MockWith {
            $RawReturn = @{
                workflow_manager_modules = @{
                    additional_ps_modules = @{
                        NAME            = 'PowerCLI'
                        GALLERY_NAME    = 'vmware.PowerCLI'
                        MODULE_VERSION  = '1.2'
                        STATUS_ID       = '11'
                    }
                }
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        {Invoke-InstallWmanModuleSet -RestServer localhost -WmanId 1} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanModuleSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-InstallWmanModuleSet -RestServer localhost -WmanId 1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
    }
    It "Should not Throw an exception if there are no modules to install." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-WmanModuleSet' -MockWith {
            $ReturnData = $null
            return $ReturnData
        }
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        {Invoke-InstallWmanModuleSet -RestServer localhost -WmanId 1} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanModuleSet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanModuleSet' -MockWith {
            Throw "(404) Not Found"
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-InstallWmanModuleSet -RestServer localhost -WmanId 1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanModuleSet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 7 -Exactly
    }
}