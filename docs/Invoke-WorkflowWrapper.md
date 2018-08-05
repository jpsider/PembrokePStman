---
external help file: PembrokePSwman-help.xml
Module Name: PembrokePSwman
online version:
schema: 2.0.0
---

# Invoke-WorkflowWrapper

## SYNOPSIS

## SYNTAX

```
Invoke-WorkflowWrapper [-PropertyFilePath] <String> [[-TableName] <String>] [-TaskId] <Int32>
 [-RestServer] <String> [<CommonParameters>]
```

## DESCRIPTION
This Script will Execute a specified task, and generate any needed subtasks.

## EXAMPLES

### EXAMPLE 1
```
Invoke-WorkflowWrapper -PropertyFilePath "c:\PembrokePS\Wman\data\pembrokeps.properties" -TaskId 1 -RestServer localhost -TableName tasks
```

## PARAMETERS

### -PropertyFilePath
A Rest PropertyFilePath is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TableName
{{Fill TableName Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Tasks
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaskId
A TaskId is required.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RestServer
{{Fill RestServer Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This will execute a task against a specific target defined in the PembrokePS database.

## RELATED LINKS
