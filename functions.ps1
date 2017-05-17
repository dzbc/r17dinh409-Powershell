# Create use cli menu


# Define Disk Quotas
function setMailboxQuota($identity, $issueWarningQuota, $prohibitSendQuota, $prohibitSendReceiveQuota, $useDatabaseQuotaDefaults) {
    Set-Mailbox -Identity $identity -IssueWarningQuota $issueWarningQuota `
    -ProhibitSendQuota $prohibitSendQuota -ProhibitSendReceiveQuota `
    $prohibitSendReceiveQuota -UseDatabaseQuotaDefaults $useDatabaseQuotaDefaults
}

# Set IPv4 Address
function setIpv4Address() {}

# Set IPv6 Address
function setIpv6Address() {}


# Create AD User


# Modify existing AD User


# Create GPO


# Link GPO to OU


# Show exsiting AD Groups


# Show members of AD Group


# Show current disk usage


# Show latest x warnings and errors from eventlog


# Start services (defualt only services set to auto-startup)


# Install AD


# Configure AD