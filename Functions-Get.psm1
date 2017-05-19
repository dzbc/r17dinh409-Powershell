Param(
    $computerName = $env:COMPUTERNAME,
    $computerLogFolder = "C:\Logs"
)


# Return NIC Index value from given NIC Interface Name
Function Get-NetIntIndex($intName) {
    $intIndex = Get-NetAdapter -physical | 
        Where name -eq $intName | select -expand ifIndex

    If ($intIndex.length -eq 0) {
        Write-Host "Sadly. No Interface was found IP Enabled with the given Interface Name."
        Break
    }

    Return $intIndex
}

# Get local Bios Params
Function Get-BiosParams() {
    Get-CimInstance -Class win32_bios -ComputerName $computerName
}


# Check if folder exists
<#Function Get-DoesFolderExist($Path) {
    $Return = $False #default to $False
    If (($Path.Length -eq 0) -eq $False) { #verify input is not zero characters
        If (Test-Path $Path) { #verify folder exist
            $Return = $True
        }
    }
    Return $Return
}#>