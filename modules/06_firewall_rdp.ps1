# ========================================================================================================
# Abschnitt 6: Firewall-Einstellungen
# ========================================================================================================
Write-Step "Firewall regeln werden eingestellt..."

if (Confirm-Step "Firewall-Regeln setzen (RDP + ICMP aktivieren)")
{
    Write-Host "==> Info - Aktiviere RDP Regeln" -ForegroundColor Gray
    Get-NetFirewallRule | Where-Object {
        ($_.DisplayName -like "*remotedesktop*") -and $_.Enabled -eq $true
    } | Select-Object DisplayName, Direction, Profile | Format-Table -AutoSize
    Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*remotedesktop*" } | Enable-NetFirewallRule
    Write-Host "==> Success - RDP Firewall regeln wurden aktiviert." -ForegroundColor Green

    Write-Host "==> Info - Aktiviere ICMP Regeln" -ForegroundColor Gray
    Get-NetFirewallRule | Where-Object {
        ($_.DisplayName -like "*ICMP*" -or $_.Protocol -eq "ICMPv4" -or $_.Protocol -eq "ICMPv6") -and $_.Enabled -eq $true
    } | Select-Object DisplayName, Direction, Profile | Format-Table -AutoSize
    Get-NetFirewallRule | Where-Object {
        $_.DisplayName -like "*ICMP*" -or ($_.Protocol -eq "ICMPv4") -or ($_.Protocol -eq "ICMPv6")
    } | Enable-NetFirewallRule
    Write-Host "==> Success - ICMP Firewall regeln wurden aktiviert." -ForegroundColor Green
}
