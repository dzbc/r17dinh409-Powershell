# Define Disk Quotas
Function Set-MailboxQuota($identity, $issueWarningQuota, $prohibitSendQuota, $prohibitSendReceiveQuota, $useDatabaseQuotaDefaults) {
    Set-Mailbox -Identity $identity -IssueWarningQuota $issueWarningQuota `
    -ProhibitSendQuota $prohibitSendQuota -ProhibitSendReceiveQuota `
    $prohibitSendReceiveQuota -UseDatabaseQuotaDefaults $useDatabaseQuotaDefaults
}




# Set IPv4 Address
Function Set-Ipv4Address($intName, $ipv4, $netmask, $gateway, $dns) {
    $adapter = Get-CimInstance win32_NetworkAdapterConfiguration | `
        Where Index -eq (Get-NetIntIndex -intName $intName)

    $adapter.EnableStatic($ipv4, $netmask)
    Sleep -Seconds 4
    $adapter.SetGateways($gateway, 1)
    $adapter.SetDNSServerSearchOrder($dns)
}


# Set IPv6 Address
Function Set-Ipv6Address() {}


# Set Network Interface mode to DHCP Enabled for both IPv4 and IPv6
# and get DNS servers, too, with DHCP IP Address
Function Set-EnableDHCPInterface($intName, $setDnsToAuto = $true) {
    If ($intName.length -eq 0) {
        Write-Host 'ERROR: A Network Intrface Name was not given.'
        Break
    }

    $adapter = Get-CimInstance win32_NetworkAdapterConfiguration | `
        Where Index -eq (Get-NetIntIndex -intName $intName)
    
    $adapter.SetDNSServerSearchOrder()
    $adapter.EnableDHCP()

    $adapter.SetGateways()
    
    $adapter.SetDNSDomain()
}


# Start services (defualt only services set to auto-startup)
Function Set-StartStoppedServices($onlyAutoStartServices = $true) {
    If ($onlyAutoStartServices -eq $true) {
        $onlyAutoStartServices = 'auto'
    } Else {
        Break
    }

    Get-CimInstance win32_service |
        Where startmode -eq $onlyAutoStartServices |
        Where state -eq 'stopped'
}
