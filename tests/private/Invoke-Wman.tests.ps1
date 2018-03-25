$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-Wman function for $moduleName" {
    function Get-LocalPropertySet{}
    function Get-WmanStatus{}
    function Invoke-Wait{}
    function Get-WmanTableName{}
    function Write-Log{}
    It "Should Throw if the path fails" {
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        {Invoke-Wman -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
    }
    It "Should not Throw during Shutdown Tasks" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '4'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Get-WmanTableName' -MockWith {
            return "tasks"
        }
        function Invoke-WmanShutdownTaskSet{}
        Mock -CommandName 'Write-Log' -MockWith {}
        Mock -CommandName 'Invoke-WmanShutdownTaskSet' -MockWith {}
        {Invoke-Wman -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-WmanShutdownTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-Log' -Times 15 -Exactly
    }
    It "Should not Throw during StartUp Tasks" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '3'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Get-WmanTableName' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanRunning = "shutdown"
            return $script:WmanRunning
        }
        function Invoke-WmanStartupTaskSet{}
        Mock -CommandName 'Invoke-WmanStartupTaskSet' -MockWith {
            $true
        }
        Mock -CommandName 'Write-Log' -MockWith {}
        {Invoke-Wman -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-WmanStartupTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-Log' -Times 31 -Exactly
    }
    It "Should not Throw during Normal Operation" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '2'
                    WAIT       = $null
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Get-WmanTableName' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanRunning = "shutdown"
            return $script:WmanRunning
        }
        function Invoke-ReviewAssignedTaskSet{}
        Mock -CommandName 'Invoke-ReviewAssignedTaskSet' -MockWith {
            $true
        }
        Mock -CommandName 'Write-Log' -MockWith {}
        {Invoke-Wman -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ReviewAssignedTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-Log' -Times 48 -Exactly
    }
    It "Should not Throw if the Status starts as Down" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '1'
                    WAIT       = $null
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Get-WmanTableName' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanRunning = "shutdown"
            return $script:WmanRunning
        }
        function Invoke-ReviewAssignedTaskSet{}
        Mock -CommandName 'Invoke-ReviewAssignedTaskSet' -MockWith {
            $true
        }
        Mock -CommandName 'Write-Log' -MockWith {}
        {Invoke-Wman -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ReviewAssignedTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-Log' -Times 63 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith {
            return $PpsProperties
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-Log' -MockWith {}
        {Invoke-Wman -PropertyFilePath "c:\pps\Wman\pembrokeps.properties"} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-Log' -Times 66 -Exactly
    }
    It "Should Throw if the file does not exist." {
        Mock -CommandName 'Test-Path' -MockWith {}
        Mock -CommandName 'Write-Log' -MockWith {}
        {Invoke-Wman -PropertyFilePath "c:\pps\Wman\pembrokeps.properties"} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 7 -Exactly
        Assert-MockCalled -CommandName 'Write-Log' -Times 67 -Exactly
    }
}