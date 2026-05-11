# ==============================================================================
# ABSCHNITT 7: REMOTE DESKTOP AKTIVIEREN
# ==============================================================================
Write-Step "Aktiviere Remote Desktop Verbindung"

if (Confirm-Step "Remote Desktop aktivieren (NLA deaktivieren)")
{
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0
    Write-Host "==> Success - Remote Desktop aktiviert." -ForegroundColor Green
}
