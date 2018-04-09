$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-RegisterWman function for $moduleName" {
    function Write-LogLevel{}
    function Invoke-DeployPPSRest {}
    function Get-PpsPropertySet{}
    function Get-EndpointPort{}
    function Get-ComponentStatus{}
    function Get-Module{}
    function Import-Module{}
    function Invoke-InstallRequiredModuleSet{}
    function New-Item{}
    function Test-Path{}
    function Test-Connection{}
    function Write-Output{}
    function Out-File{}
    $RawReturn = @{
        properties = @{
            ID            = '1'
            Prop_Name     = 'system.Root'
            Prop_Value  = 'c:\temp\someDir'
        },
        @{
            ID            = '1'
            Prop_Name     = 'system.LogDirectory'
            Prop_Value  = 'c:\temp\someDir'
        },
        @{
            ID            = '1'
            Prop_Name     = 'system.ResultsDirectory'
            Prop_Value  = 'c:\temp\someDir\results'
        },
        @{
            ID            = '1'
            Prop_Name     = 'system.RequiredModules'
            Prop_Value  = 'powerlumber,pembrokepsrest'
        },              
        @{
            ID            = '1'
            Prop_Name     = 'system.RunLogLevel'
            Prop_Value  = 'CONSOLEONLY'
        }               
    }
    $ReturnJson = $RawReturn | ConvertTo-Json
    $ReturnData = $ReturnJson | convertfrom-json
    It "Should not Throw During normal operations." {
        Mock -CommandName 'Get-PpsPropertySet' -MockWith {
            return $ReturnData
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-InstallRequiredModuleSet' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-DeployPPSRest' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Get-EndpointPort' -MockWith {
            $RawReturn3 = @{
                endpoint_ports = @{
                    ID            = '1'
                    Port     = '8999'
                }               
            }
            $ReturnJson3 = $RawReturn3 | ConvertTo-Json
            $ReturnData3 = $ReturnJson3 | convertfrom-json
            return $ReturnData3
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith {
            $RawReturn2 = @{
                workflow_manager = @{
                    ID            = '1'
                    REGISTRATION_STATUS_ID     = '13'
                    WKFLW_PORT_ID  = '1'
                    LOG_FILE  = 'FakeValue'
                }               
            }
            $ReturnJson2 = $RawReturn2 | ConvertTo-Json
            $ReturnData2 = $ReturnJson2 | convertfrom-json
            return $ReturnData2
        }
        Mock -CommandName 'Get-Module' -MockWith {
            $RawReturn4 = @(
                @{
                    path            = 'c:\someModulePath'
                    Name            = 'c:\PembrokePSwman'
                }               
            )
            $ReturnJson4 = $RawReturn4 | ConvertTo-Json
            $ReturnData4 = $ReturnJson4 | convertfrom-json
            return $ReturnData4
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Test-Connection' -MockWith {
            return $true
        }
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Out-File' -MockWith {}
        {Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\temp\someDir} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-InstallRequiredModuleSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-DeployPPSRest' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsPropertySet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-EndpointPort' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-Module' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'New-Item' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 10 -Exactly
        Assert-MockCalled -CommandName 'Out-File' -Times 0 -Exactly
    }
    It "Should Throw an exception if the Rest Server cannot be reached." {
        Mock -CommandName 'Get-PpsPropertySet' -MockWith {
            return $ReturnData
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-InstallRequiredModuleSet' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-DeployPPSRest' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Get-EndpointPort' -MockWith {
            $RawReturn3 = @{
                endpoint_ports = @{
                    ID            = '1'
                    Port     = '8999'
                }               
            }
            $ReturnJson3 = $RawReturn3 | ConvertTo-Json
            $ReturnData3 = $ReturnJson3 | convertfrom-json
            return $ReturnData3
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith {
            $RawReturn2 = @{
                workflow_manager = @{
                    ID            = '1'
                    REGISTRATION_STATUS_ID     = '13'
                    WKFLW_PORT_ID  = '1'
                    LOG_FILE  = 'FakeValue'
                }               
            }
            $ReturnJson2 = $RawReturn2 | ConvertTo-Json
            $ReturnData2 = $ReturnJson2 | convertfrom-json
            return $ReturnData2
        }
        Mock -CommandName 'Get-Module' -MockWith {
            $RawReturn4 = @(
                @{
                    path            = 'c:\someModulePath'
                    Name            = 'c:\PembrokePSwman'
                }               
            )
            $ReturnJson4 = $RawReturn4 | ConvertTo-Json
            $ReturnData4 = $ReturnJson4 | convertfrom-json
            return $ReturnData4
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Test-Connection' -MockWith {
            return $false
        }
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Out-File' -MockWith {}
        {Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\temp\someDir} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-DeployPPSRest' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-InstallRequiredModuleSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsPropertySet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-EndpointPort' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-Module' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'New-Item' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 10 -Exactly
        Assert-MockCalled -CommandName 'Out-File' -Times 0 -Exactly
    }


    It "Should not Throw an exception if the source directory does exist." {
        Mock -CommandName 'Get-PpsPropertySet' -MockWith {
            return $ReturnData
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-InstallRequiredModuleSet' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-DeployPPSRest' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Get-EndpointPort' -MockWith {
            $RawReturn3 = @{
                endpoint_ports = @{
                    ID            = '1'
                    Port     = '8999'
                }               
            }
            $ReturnJson3 = $RawReturn3 | ConvertTo-Json
            $ReturnData3 = $ReturnJson3 | convertfrom-json
            return $ReturnData3
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith {
            $RawReturn2 = @{
                workflow_manager = @{
                    ID            = '1'
                    REGISTRATION_STATUS_ID     = '13'
                    WKFLW_PORT_ID  = '1'
                    LOG_FILE  = 'FakeValue'
                }               
            }
            $ReturnJson2 = $RawReturn2 | ConvertTo-Json
            $ReturnData2 = $ReturnJson2 | convertfrom-json
            return $ReturnData2
        }
        Mock -CommandName 'Get-Module' -MockWith {
            $RawReturn4 = @(
                @{
                    path            = 'c:\someModulePath'
                    Name            = 'c:\PembrokePSwman'
                }               
            )
            $ReturnJson4 = $RawReturn4 | ConvertTo-Json
            $ReturnData4 = $ReturnJson4 | convertfrom-json
            return $ReturnData4
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Test-Connection' -MockWith {
            return $true
        }
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Out-File' -MockWith {}
        {Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\temp\someDir} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Invoke-DeployPPSRest' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-InstallRequiredModuleSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-EndpointPort' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-Module' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'New-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 20 -Exactly
        Assert-MockCalled -CommandName 'Out-File' -Times 0 -Exactly
    }
    It "Should Throw if the Wman was already registerred." {
        Mock -CommandName 'Get-PpsPropertySet' -MockWith {
            return $ReturnData
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-InstallRequiredModuleSet' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-DeployPPSRest' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Get-EndpointPort' -MockWith {
            $RawReturn3 = @{
                endpoint_ports = @{
                    ID            = '1'
                    Port     = '8999'
                }               
            }
            $ReturnJson3 = $RawReturn3 | ConvertTo-Json
            $ReturnData3 = $ReturnJson3 | convertfrom-json
            return $ReturnData3
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith {
            $RawReturn2 = @{
                workflow_manager = @{
                    ID            = '1'
                    REGISTRATION_STATUS_ID     = '7'
                    WKFLW_PORT_ID  = '1'
                    LOG_FILE  = 'FakeValue'
                }               
            }
            $ReturnJson2 = $RawReturn2 | ConvertTo-Json
            $ReturnData2 = $ReturnJson2 | convertfrom-json
            return $ReturnData2
        }
        Mock -CommandName 'Get-Module' -MockWith {
            $RawReturn4 = @(
                @{
                    path            = 'c:\someModulePath'
                    Name            = 'c:\PembrokePSwman'
                }               
            )
            $ReturnJson4 = $RawReturn4 | ConvertTo-Json
            $ReturnData4 = $ReturnJson4 | convertfrom-json
            return $ReturnData4
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Test-Connection' -MockWith {
            return $true
        }
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Out-File' -MockWith {}
        {Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\temp\someDir} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Invoke-DeployPPSRest' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-InstallRequiredModuleSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-EndpointPort' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-Module' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'New-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 20 -Exactly
        Assert-MockCalled -CommandName 'Out-File' -Times 0 -Exactly
    }
    It "Should Throw if copy-item fails." {
        Mock -CommandName 'Get-PpsPropertySet' -MockWith {
            return $ReturnData
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-InstallRequiredModuleSet' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-DeployPPSRest' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {
            Throw "Copy-Item barfed."
        }
        Mock -CommandName 'Get-EndpointPort' -MockWith {
            $RawReturn3 = @{
                endpoint_ports = @{
                    ID            = '1'
                    Port     = '8999'
                }               
            }
            $ReturnJson3 = $RawReturn3 | ConvertTo-Json
            $ReturnData3 = $ReturnJson3 | convertfrom-json
            return $ReturnData3
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith {
            $RawReturn2 = @{
                workflow_manager = @{
                    ID            = '1'
                    REGISTRATION_STATUS_ID     = '7'
                    WKFLW_PORT_ID  = '1'
                    LOG_FILE  = 'FakeValue'
                }               
            }
            $ReturnJson2 = $RawReturn2 | ConvertTo-Json
            $ReturnData2 = $ReturnJson2 | convertfrom-json
            return $ReturnData2
        }
        Mock -CommandName 'Get-Module' -MockWith {
            $RawReturn4 = @(
                @{
                    path            = 'c:\someModulePath'
                    Name            = 'c:\PembrokePSwman'
                }               
            )
            $ReturnJson4 = $RawReturn4 | ConvertTo-Json
            $ReturnData4 = $ReturnJson4 | convertfrom-json
            return $ReturnData4
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Test-Connection' -MockWith {
            return $true
        }
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Out-File' -MockWith {}
        {Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\temp\someDir} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Invoke-DeployPPSRest' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-InstallRequiredModuleSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-EndpointPort' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-Module' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'New-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 20 -Exactly
        Assert-MockCalled -CommandName 'Out-File' -Times 0 -Exactly
    }
}