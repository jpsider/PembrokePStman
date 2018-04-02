$script:ModuleName = 'PembrokePSwman'

Describe "Invoke-WorkflowWrapper function for $moduleName" {
    function Get-LocalPropertySet{}
    function Invoke-ImportWmanModuleSet{}
    function Invoke-Wait{}
    function Get-TaskInfo{}
    function Write-LogLevel{}
    function Import-Module{}
    function Invoke-UpdateTaskTable{}
    function Invoke-GenerateSubTask{}
    function Get-SubTaskData{}
    function Test-Connection{}
    function Invoke-ExecutionPath{}
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-ImportWmanModuleSet' -MockWith {}
        Mock -CommandName 'Get-TaskInfo' -MockWith {}
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {}
        Mock -CommandName 'Invoke-GenerateSubTask' -MockWith {}
        Mock -CommandName 'Get-SubTaskData' -MockWith {}
        Mock -CommandName 'Invoke-ExecutionPath' -MockWith {}
        {Invoke-WorkflowWrapper -PropertyFilePath "c:\pps\Wman\pembrokeps.properties" -TaskId 111 -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ImportWmanModuleSet' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Get-TaskInfo' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Get-SubTaskData' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-GenerateSubTask' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ExecutionPath' -Times 0 -Exactly

    }
    It "Should Throw if the path fails" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-ImportWmanModuleSet' -MockWith {}
        Mock -CommandName 'Get-TaskInfo' -MockWith {}
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {}
        Mock -CommandName 'Invoke-GenerateSubTask' -MockWith {}
        Mock -CommandName 'Get-SubTaskData' -MockWith {}
        Mock -CommandName 'Invoke-ExecutionPath' -MockWith {}
        {Invoke-WorkflowWrapper -PropertyFilePath "c:\pps\Wman\pembrokeps.properties" -TaskId 111 -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ImportWmanModuleSet' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Get-TaskInfo' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Get-SubTaskData' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-GenerateSubTask' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ExecutionPath' -Times 0 -Exactly
    }
    It "Should not Throw if the task passes" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    LogDirectory = 'SomeDirectory'
                }
                component = @{
                    id = '1'
                    RunLogLevel = 'CONSOLEONLY'
                    Destination = 'SomeDirectory'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-ImportWmanModuleSet' -MockWith {}
        Mock -CommandName 'Get-TaskInfo' -MockWith {
            $RawReturn = @{
                tasks = @{
                    ID            = '1'
                    STATUS_ID     = '1'
                    TASK_TYPE_ID  = '1'
                    ARGUMENTS     = 'SomeArgs'
                    TARGET_ID     = '1'
                    targets = @{
                        TARGET_NAME            = 'SomeHostname'
                        IP_ADDRESS    = '123.123.123.123'
                    }
                    task_types = @{
                        TASK_PATH     = 'SomePath'
                    }
                }            
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            $script:TaskResult = 1
            return $script:TaskResult
        }
        Mock -CommandName 'Invoke-GenerateSubTask' -MockWith {}
        Mock -CommandName 'Get-SubTaskData' -MockWith {
            $RawReturn = @{
                subtask_generator = @{
                    ID            = '1'
                    PASS_SUBTASK_ID = '1'
                }            
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Invoke-ExecutionPath' -MockWith {}
        {Invoke-WorkflowWrapper -PropertyFilePath "c:\pps\Wman\pembrokeps.properties" -TaskId 111 -RestServer localhost -TableName tasks} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 9 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ImportWmanModuleSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-TaskInfo' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ExecutionPath' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-SubTaskData' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-GenerateSubTask' -Times 1 -Exactly
    }
    It "Should not Throw if task fails" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    LogDirectory = 'SomeDirectory'
                }
                component = @{
                    id = '1'
                    RunLogLevel = 'CONSOLEONLY'
                    Destination = 'SomeDirectory'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-ImportWmanModuleSet' -MockWith {}
        Mock -CommandName 'Get-TaskInfo' -MockWith {
            $RawReturn = @{
                tasks = @{
                    ID            = '1'
                    STATUS_ID     = '1'
                    TASK_TYPE_ID  = '1'
                    ARGUMENTS     = 'SomeArgs'
                    TARGET_ID     = '1'
                    targets = @{
                        TARGET_NAME            = 'SomeHostname'
                        IP_ADDRESS    = '123.123.123.123'
                    }
                    task_types = @{
                        TASK_PATH     = 'SomePath'
                    }
                }            
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            $script:TaskResult = 2
            return $script:TaskResult
        }
        Mock -CommandName 'Invoke-GenerateSubTask' -MockWith {}
        Mock -CommandName 'Get-SubTaskData' -MockWith {
            $RawReturn = @{
                tasks = @{
                    ID            = '1'
                    FAIL_SUBTASK_ID = '2'
                }            
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Invoke-ExecutionPath' -MockWith {}
        {Invoke-WorkflowWrapper -PropertyFilePath "c:\pps\Wman\pembrokeps.properties" -TaskId 111 -RestServer localhost -TableName tasks} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 17 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ImportWmanModuleSet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-TaskInfo' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ExecutionPath' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-SubTaskData' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-GenerateSubTask' -Times 2 -Exactly
    }
    It "Should not Throw if the task is fubar" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    LogDirectory = 'SomeDirectory'
                }
                component = @{
                    id = '1'
                    RunLogLevel = 'CONSOLEONLY'
                    Destination = 'SomeDirectory'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-ImportWmanModuleSet' -MockWith {}
        Mock -CommandName 'Get-TaskInfo' -MockWith {
            $RawReturn = @{
                tasks = @{
                    ID            = '1'
                    STATUS_ID     = '1'
                    TASK_TYPE_ID  = '1'
                    ARGUMENTS     = 'SomeArgs'
                    TARGET_ID     = '1'
                    targets = @{
                        TARGET_NAME            = 'SomeHostname'
                        IP_ADDRESS    = '123.123.123.123'
                    }
                    task_types = @{
                        TASK_PATH     = 'SomePath'
                    }
                }            
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            $script:TaskResult = 4
            return $script:TaskResult
        }
        Mock -CommandName 'Invoke-GenerateSubTask' -MockWith {}
        Mock -CommandName 'Get-SubTaskData' -MockWith {
            $ReturnData = $null
            return $ReturnData
        }
        Mock -CommandName 'Invoke-ExecutionPath' -MockWith {}
        {Invoke-WorkflowWrapper -PropertyFilePath "c:\pps\Wman\pembrokeps.properties" -TaskId 111 -RestServer localhost -TableName tasks} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 25 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ImportWmanModuleSet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-TaskInfo' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ExecutionPath' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-SubTaskData' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-GenerateSubTask' -Times 2 -Exactly
    }
    It "Should Throw if a Function throws an error" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                    LogDirectory = 'SomeDirectory'
                }
                component = @{
                    id = '1'
                    RunLogLevel = 'CONSOLEONLY'
                    Destination = 'SomeDirectory'
                }
            }
            return $PpsProperties
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Mock -CommandName 'Invoke-ImportWmanModuleSet' -MockWith {}
        Mock -CommandName 'Get-TaskInfo' -MockWith {
            $RawReturn = @{
                tasks = @{
                    ID            = '1'
                    STATUS_ID     = '1'
                    TASK_TYPE_ID  = '1'
                    ARGUMENTS     = 'SomeArgs'
                    TARGET_ID     = '1'
                    targets = @{
                        TARGET_NAME            = 'SomeHostname'
                        IP_ADDRESS    = '123.123.123.123'
                    }
                    task_types = @{
                        TASK_PATH     = 'SomePath'
                    }
                }            
            }
            $ReturnJson = $RawReturn | ConvertTo-Json
            $ReturnData = $ReturnJson | convertfrom-json
            return $ReturnData
        }
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            $script:TaskResult = 4
            return $script:TaskResult
        }
        Mock -CommandName 'Invoke-GenerateSubTask' -MockWith {}
        Mock -CommandName 'Get-SubTaskData' -MockWith {
            throw "Could not get subtask data."
        }
        Mock -CommandName 'Invoke-ExecutionPath' -MockWith {}
        {Invoke-WorkflowWrapper -PropertyFilePath "c:\pps\Wman\pembrokeps.properties" -TaskId 111 -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 32 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ImportWmanModuleSet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-TaskInfo' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 8 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ExecutionPath' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-SubTaskData' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-GenerateSubTask' -Times 2 -Exactly
    }
}