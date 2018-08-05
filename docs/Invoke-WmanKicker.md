---
external help file: PembrokePSwman-help.xml
Module Name: PembrokePSwman
online version:
schema: 2.0.0
---

# Invoke-WmanKicker

## SYNOPSIS

## SYNTAX

```
Invoke-WmanKicker [-PropertyFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
This Script runs in the background of the Workflow manager to help with health/mgmt of the component.

## EXAMPLES

### EXAMPLE 1
```
Invoke-WmanKicker -PropertyFilePath "c:\PembrokePS\Wman\pembrokeps.properties"
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

### System.Boolean

## NOTES
Nothing to see here.

## RELATED LINKS
