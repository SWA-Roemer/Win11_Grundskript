# ========================================================================================================
# Abschnitt 9: Verbindungsunterbrechung verhindern
# ========================================================================================================
Write-Step "Deaktiviere automatische Verbindungsunterbrechung..."

if (Confirm-Step "Automatische Netzwerk-Verbindungsunterbrechung deaktivieren")
{
    Start-Process -FilePath "net" -ArgumentList "config server /autodisconnect:-1" -Verb RunAs -Wait
    Write-Host "==> Info - Einstellung wurde angewendet."
}
