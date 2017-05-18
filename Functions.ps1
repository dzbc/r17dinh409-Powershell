Param(
    $computerName = $env:COMPUTERNAME,
    $computerTimestamp = ((Get-Date -Format o).Split("{+}")[0]) -replace ".{4}$"
)


# Define Disk Quotas
function Set-MailboxQuota($identity, $issueWarningQuota, $prohibitSendQuota, $prohibitSendReceiveQuota, $useDatabaseQuotaDefaults) {
    Set-Mailbox -Identity $identity -IssueWarningQuota $issueWarningQuota `
    -ProhibitSendQuota $prohibitSendQuota -ProhibitSendReceiveQuota `
    $prohibitSendReceiveQuota -UseDatabaseQuotaDefaults $useDatabaseQuotaDefaults
}


# Return NIC Index value from given NIC Interface Name
function Get-NetIntIndex($intName) {
    $intIndex = Get-NetAdapter -physical | 
        where name -eq $intName | select -expand ifIndex

    if ($intIndex.length -eq 0) {
        Write-Host "Sadly. No Interface was found IP Enabled with the given Interface Name."
        break;
    }

    return $intIndex
}


# Set IPv4 Address
function Set-Ipv4Address($intName, $ipv4, $netmask, $gateway, $dns) {
    $adapter = Get-CimInstance win32_NetworkAdapterConfiguration | `
        Where Index -eq (Get-NetIntIndex -intName $intName)

    $adapter.EnableStatic($ipv4, $netmask)
    Sleep -Seconds 4
    $adapter.SetGateways($gateway, 1)
    $adapter.SetDNSServerSearchOrder($dns)
}
Set-Ipv4Address -intName "Ethernet" -ipv4 "192.0.2.2" `
    -netmask '255.255.255.0' -gateway '192.0.2.1' -dns '192.0.2.254'


# Set IPv6 Address
function Set-Ipv6Address() {}


# Set Network Interface mode to DHCP Enabled for both IPv4 and IPv6
# and get DNS servers, too, with DHCP IP Address
function Set-EnableDHCPInterface($intName, $setDnsToAuto = $true) {
    if($intName.length -eq 0) {
        Write-Host 'ERROR: A Network Intrface Name was not given.'
        break
    }

    $adapter = Get-CimInstance win32_NetworkAdapterConfiguration | `
        Where Index -eq (Get-NetIntIndex -intName $intName)
    
    $adapter.SetDNSServerSearchOrder()
    $adapter.EnableDHCP()

    $adapter.SetGateways()
    
    $adapter.SetDNSDomain()
}


# Create AD User
function New-CsvADUsers($CsvFilePath = "C:\newuserstoad.txt"){
    $Users = Import-Csv -Delimiter "," -Path $CsvFilePath
    foreach ($User in $Users)
    {
        $ADServer = "DC-01.5.5.2017.test.netravnen.eu"
        $SAM = $Firstname.Substring(0,3) + ($Lastname -replace ".{3}$")
        $UserDisplayname = $User.Firstname + " " + $User.Othernames `
            + " " + $User.Lastname
        $UPN = $SAM + "." `
            <#+ (Get-Date -UFormat "T%H%M%S")#> `
            + "@" `
            + $User.Maildomain
        
        try {
            Get-ADUser -Identity $SAM -ErrorAction Stop
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            Write-Warning -Message 'Account not found'
        }
        Finally
        {
            $Time = ((Get-Date -Format o).Split("{+}")[0]) -replace ".{4}$"
            "This script made a read attempt at $Time" | out-file C:\Log\New-ADUser.log -append
        }
        
        # Maximum length of SAM is 20 chars.
        if ($SAM.length -gt 20) {
            # Log a message telling the $User creation failed
            <#
            --> log error code to system log or custom log file here
            #>
            
            # Stop creating current $User
            break
        }

        # Create @var $UserInitials
        $User.Firstname.split(' ') | foreach {$UserInitials += $_[0]}
        $User.Othernames.split(' ') | foreach {$UserInitials += $_[0]}
        $User.Lastname.split(' ') | foreach {$UserInitials += $_[0]}
        
        Write-Host "\n\n" + 'DEBUG OUTPUT BEFORE NEW-ADUSER COMMAND IS EXECUTED' + "\n" + $User "\n\n"
        
        New-ADUser `
            -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
            -ChangePasswordAtLogon $false `
            -City $User.City `
            -Company $User.Company `
            -Country $User.Country `
            -Department $User.Department `
            -Description $User.Description `
            -DisplayName "$UserDisplayname" `
            -Division $User.Division `
            -EmployeeNumber $User.EmployeeNumber `
            -Enabled $true `
            -GivenName $User.Firstname `
            -Intials $UserInitials `
            -Manager $User.Manager `
            -Name "$UserDisplayname" `
            -OfficePhone $User.OfficePhone `
            -OtherName $User.Othernames
            -Path $User.OU `
            -PostalCode $User.PostalCode `
            -SamAccountName $SAM `
            -State $User.State
            -StreetAddress $User.StreetAddress `
            -Surname $User.Lastname `
            -Title $User.Title `
            -UserPrincipalName $SAM `
            -server domain.loc `
            -PasswordNeverExpires $true
    }
}


# Modify existing AD User


# Create GPO


# Link GPO to OU


# Show exsiting AD Groups


# Show members of AD Group


# Show current disk usage


# Show latest x warnings and errors from eventlog


# Start services (defualt only services set to auto-startup)
function Set-StartStoppedServices($onlyAutoStartServices = $true) {
    if($onlyAutoStartServices -eq $true) {
        $onlyAutoStartServices = 'auto'
    } else {
        break
    }

    Get-CimInstance win32_service |
        Where startmode -eq $onlyAutoStartServices |
        Where state -eq 'stopped'
}


# Install AD


# Configure AD


# Get local Bios Params
function Get-BiosParams() {
    Get-CimInstance -Class win32_bios -ComputerName $computerName
}
