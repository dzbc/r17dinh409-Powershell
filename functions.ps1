Param(
    $computerName = $env:COMPUTERNAME
)


# Define Disk Quotas
function set_mailbox_quota($identity, $issueWarningQuota, $prohibitSendQuota, $prohibitSendReceiveQuota, $useDatabaseQuotaDefaults) {
    Set-Mailbox -Identity $identity -IssueWarningQuota $issueWarningQuota `
    -ProhibitSendQuota $prohibitSendQuota -ProhibitSendReceiveQuota `
    $prohibitSendReceiveQuota -UseDatabaseQuotaDefaults $useDatabaseQuotaDefaults
}

# Set IPv4 Address
function set_ipv4_address() {}

# Set IPv6 Address
function set_ipv6_address() {}


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