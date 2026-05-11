# ==============================================================================
# KONFIGURATIONSDATEI
# ==============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Windows Bloatware Entfernungs-Skript Vorbereitung" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bitte selektiere eine Konfiguration:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Standard (entfernt alle Bloatware inkl. Microsoft 365) [apps_standard.txt]" -ForegroundColor White
Write-Host "  [2] Standard, aber Microsoft 365 behalten [apps_exkl_m365.txt]" -ForegroundColor White
Write-Host "  [3] Eigene Datei [apps_custom.txt]" -ForegroundColor White
Write-Host ""

$choice = Read-Host "==> Deine Wahl (1-3)"



switch ($choice)
{
    "1"
    { $configFile = Join-Path $scriptPath "apps_standard.txt"
    }
    "2"
    { $configFile = Join-Path $scriptPath "apps_exkl_m365.txt"
    }
    "3"
    { $configFile = Join-Path $scriptPath "apps_custom.txt"
    }
    default
    {
        Write-Host "Keine korrekte Auswahl. Verwende Standard-Konfiguration." -ForegroundColor Red
        $configFile = Join-Path $scriptPath "apps_standard.txt"
    }
}

if (-not (Test-Path $configFile))
{
    Write-Host ""
    Write-Host "==> FEHLER: Konfigurationsdatei nicht gefunden!" -ForegroundColor Red
    Write-Host "==> Erwartet: $configFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "==> Bitte erstelle die Datei mit einer App pro Zeile." -ForegroundColor Yellow
    Write-Host "==> Beispiel:" -ForegroundColor Gray
    Write-Host "      Microsoft.BingNews" -ForegroundColor Gray
    Write-Host "      Microsoft.XboxApp" -ForegroundColor Gray
    Write-Host ""
    Pause
    exit
}

$AppsToRemove = Get-Content $configFile | Where-Object {
    $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$'
} | ForEach-Object { $_.Trim() }

Write-Host ""
Write-Host "==> Verwende Konfiguration: $configFile" -ForegroundColor Green
Write-Host "==> Anzahl zu entfernender Apps: $($AppsToRemove.Count)" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 2
