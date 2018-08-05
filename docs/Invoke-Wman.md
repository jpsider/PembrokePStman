---
external help file: PembrokePSwman-help.xml
Module Name: PembrokePSwman
online version:
schema: 2.0.0
---

# Invoke-Wman

## SYNOPSIS

## SYNTAX

```
Invoke-Wman [-PropertyFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
This function will gather Status information from PembrokePS web/rest for a Workflow_Manager

## EXAMPLES

### EXAMPLE 1
```
Invoke-Wman -PropertyFilePath "c:\PembrokePS\Wman\pembrokeps.properties"
```

## PARAMETERS

### -PropertyFilePath
A properties path is Required.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Hashtable

### System.Boolean

## NOTES
This will return a hashtable of data from the PPS database.

## RELATED LINKS
