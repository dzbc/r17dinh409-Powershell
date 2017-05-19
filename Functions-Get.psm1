Param(
    $computerName = $env:COMPUTERNAME,
    $computerTimestamp = ((Get-Date -Format o).Split("{+}")[0]) -replace ".{4}$",
    $computerLogFolder = "C:\Logs"
)


# Return NIC Index value from given NIC Interface Name
function Get-NetIntIndex($intName) {
    $intIndex = Get-NetAdapter -physical | 
        Where name -eq $intName | select -expand ifIndex

    If ($intIndex.length -eq 0) {
        Write-Host "Sadly. No Interface was found IP Enabled with the given Interface Name."
        break;
    }

    return $intIndex
}

# Get local Bios Params
function Get-BiosParams() {
    Get-CimInstance -Class win32_bios -ComputerName $computerName
}


# Check if folder exists
function Get-DoesFolderExist($Path) {
    $return = $False #default to $False
    If (!($Path.Length -eq 0)) { #verify input is not zero characters
        If (Test-Path $Path) { #verify folder exist
            $return = $True
        }
    }
    Return $return
}


