# ==============================================================================
# ABSCHNITT 13: SPERRBILDSCHIRM-WERBUNG & TIPPS DEAKTIVIEREN
# ==============================================================================
Write-Step "Deaktiviere Werbung und Tipps (Content Delivery Manager)..."

if (Confirm-Step "Sperrbildschirm-Werbung, Tipps und gesponserte Apps deaktivieren")
{
    $contentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    if (-not (Test-Path $contentPath))
    { New-Item -Path $contentPath -Force | Out-Null
    }

    try
    {
        Set-ItemProperty -Path $contentPath -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $contentPath -Name "SilentInstalledAppsEnabled"      -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $contentPath -Name "SystemPaneSuggestionsEnabled"    -Value 0 -Type DWord -Force
        Write-Host "==> Success - Sperrbildschirm-Werbung, Tipps und gesponserte Apps deaktiviert." -ForegroundColor Green
    } catch
    {
        Write-Host "==> Error - Fehler bei den Sperrbildschirm-Einstellungen: $($_.Exception.Message)" -ForegroundColor Red
    }
}
