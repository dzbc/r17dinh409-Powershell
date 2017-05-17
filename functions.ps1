Param(
    $computerName = $env:COMPUTERNAME
)


# Define Disk Quotas
function set_mailbox_quota($identity, $issueWarningQuota, $prohibitSendQuota, $prohibitSendReceiveQuota, $useDatabaseQuotaDefaults) {
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
    $adapter = Get-WmiObject win32_NetworkAdapterConfiguration | `
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

    $adapter = Get-WmiObject win32_NetworkAdapterConfiguration | `
        Where Index -eq (Get-NetIntIndex -intName $intName)
    
    $adapter.SetDNSServerSearchOrder()
    $adapter.EnableDHCP()

    $adapter.SetGateways()
    
    $adapter.SetDNSDomain()
}


# Create AD User


# Modify existing AD User


# Create GPO


# Link GPO to OU


# Show exsiting AD Groups


# Show members of AD Group


# Show current disk usage


# Show latest x warnings and errors from eventlog


# Start services (defualt only services set to auto-startup)
function start_stopped_services($onlyAutoStartServices = $true) {
    if($onlyAutoStartServices -eq $true) {
        $onlyAutoStartServices = 'auto'
    } else {
        break
    }

    Get-WmiObject win32_service |
        Where startmode -eq $onlyAutoStartServices |
        Where state -eq 'stopped'
}


# Install AD


# Configure AD


# Get local Bios Params
function get_bios_params() {
    Get-WmiObject -Class win32_bios -ComputerName $computerName
}