---
external help file: PembrokePSwman-help.xml
Module Name: PembrokePSwman
online version:
schema: 2.0.0
---

# Invoke-RegisterWman

## SYNOPSIS

## SYNTAX

```
Invoke-RegisterWman [-RestServer] <String> [-Component_Id] <String> [[-Wman_Type] <String>]
 [[-LocalDir] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will gather Status information from PembrokePS web/rest for a Queue_Manager

## EXAMPLES

### EXAMPLE 1
```
Invoke-RegisterWman -RestServer localhost -Component_Id 1 -Wman_Type Primary -LocalDir c:\PembrokePS
```

## PARAMETERS

### -RestServer
A Rest Server is required.

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

### -Component_Id
A Component_Id is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wman_Type
A Wman_Type is Optional.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Primary
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDir
A LocalDir is Optional.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: C:\PembrokePS
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Hashtable

## NOTES
This will return a hashtable of data from the PPS database.

## RELATED LINKS
