Function New-LogCustomEvent ($LogFile,$Success,$LogMessage,$Server) {
    $Time = (((Get-Date -Format o).Split("{+}")[0]).Split("{.}"))
    $TimeZone = ((Get-Date -Format o).Split("{+}")[1])
    
    ("$Time+$TimeZone" `
        + ' - SUCCESS ' + $success `
        + ' - MESSAGE ' + $LogMessage `
        + ' - SERVER ' + $Server) | Out-File $LogFile -append
}