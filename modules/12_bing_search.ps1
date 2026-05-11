# ==============================================================================
# ABSCHNITT 12: BING-WEBSUCHE IM STARTMENÜ DEAKTIVIEREN
# ==============================================================================
Write-Step "Deaktiviere Bing-Websuche im Startmenue..."

if (Confirm-Step "Bing-Websuche im Startmenü deaktivieren")
{
    $searchPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
    if (-not (Test-Path $searchPath))
    { New-Item -Path $searchPath -Force | Out-Null
    }

    try
    {
        Set-ItemProperty -Path $searchPath -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
        Write-Host "==> Success - Bing-Websuche im Startmenue deaktiviert." -ForegroundColor Green
    } catch
    {
        Write-Host "==> Error - Fehler beim Deaktivieren der Bing-Suche: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""
