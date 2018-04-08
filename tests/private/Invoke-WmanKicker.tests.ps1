$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-WmanKicker function for $moduleName" {
    function Get-LocalPropertySet{}
    function Get-WmanStatus{}
    function Invoke-Wait{}
    function Get-WmanTableName{}
    function Write-LogLevel{}
    function Invoke-WmanShutdownTaskSet{}
    function Test-Connection {}
    function Test-Path{}
    function Get-PpsProcessStatus{}
    function Invoke-StartPPSEndpoint{}
    function Start-Process{}
    It "Should Throw if the path fails" {
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
    }
    It "Should Throw if the RestServer cannot be reached." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 1 -Exactly
    }
    It "Should not Throw if the Wman status is down" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '1'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanKickerRunning = "shutdown"
            return $script:WmanKickerRunning
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $true
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 15 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 1 -Exactly
    }
    It "Should not Throw if the Wman status is Running" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '2'
                    STATUS_ID     = '2'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanKickerRunning = "shutdown"
            return $script:WmanKickerRunning
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $true
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should  -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 26 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
    }
    It "Should not Throw if the Wman status is Shutting down" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '2'
                    STATUS_ID     = '4'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanKickerRunning = "shutdown"
            return $script:WmanKickerRunning
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $true
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 37 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 3 -Exactly
    }
    It "Should not Throw if the Wman status is Shutting down and the Endpoint needs to be started." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '2'
                    STATUS_ID     = '4'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanKickerRunning = "shutdown"
            return $script:WmanKickerRunning
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $false
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 47 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 4 -Exactly
    }
    It "Should not Throw if the Wman status is Starting UP and the Process needs to be started." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '2'
                    STATUS_ID     = '3'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanKickerRunning = "shutdown"
            return $script:WmanKickerRunning
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $false
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 7 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 59 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 6 -Exactly
    }
    It "Should not Throw if the Wman status is Starting UP and the Wman process was started." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    root = 'c:\\PembrokePS'
                }
                component = @{
                    id = '1'
                    logfile = 'c:\pembrokeps\logs\wman\wman_1.log'
                    RestPort = '8001'
                    AvailableRoutesFile = 'c:\pembrokeps\wman\data\wmanEndpointRoutes.ps1'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Get-WmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '2'
                    STATUS_ID     = '3'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $WmanStatusData = $ReturnJson | convertfrom-json
            return $WmanStatusData
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $script:WmanKickerRunning = "shutdown"
            return $script:WmanKickerRunning
        }
        Mock -CommandName 'Get-PpsProcessStatus' -MockWith {
            return $true
        }
        {Invoke-WmanKicker -PropertyFilePath 'c:\pps\Wman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 8 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 7 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 71 -Exactly
        Assert-MockCalled -CommandName 'Get-WmanStatus' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 7 -Exactly
        Assert-MockCalled -CommandName 'Get-PpsProcessStatus' -Times 8 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 7 -Exactly
    }
}