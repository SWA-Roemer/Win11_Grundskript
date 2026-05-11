# ==============================================================================
# KONFIGURATIONSDATEI
# ==============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Windows Bloatware Entfernungs-Skript Vorbereitung" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bitte selektiere eine Konfiguration:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Standard, mit M365 (apps_standard.txt + apps_m365.txt)" -ForegroundColor White
Write-Host "  [2] Standard, aber Microsoft 365 behalten (Ohne apps_m365.txt)" -ForegroundColor White
Write-Host "  [3] Eigene Datei (apps_standard.txt + apps_custom.txt)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "==> Deine Wahl (1-3)"

# Hilfsfunktion zum Laden einer App-Liste
function Read-Applist
{
    param([string]$FilePath)

    if (-not (Test-Path $FilePath))
    {
        Write-Host ""
        Write-Host "==> FEHLER: Konfigurationsdatei nicht gefunden!" -ForegroundColor Red
        Write-Host "==> Erwartet: $FilePath" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "==> Bitte erstelle die Datei mit einer App pro Zeile." -ForegroundColor Yellow
        Write-Host "==> Beispiel:" -ForegroundColor Gray
        Write-Host "      Microsoft.BingNews" -ForegroundColor Gray
        Write-Host "      Microsoft.XboxApp" -ForegroundColor Gray
        Write-Host ""
        Pause
        exit
    }

    return Get-Content $FilePath | Where-Object {
        $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$'
    } | ForEach-Object { $_.Trim() }
}

# Basis-Liste immer laden
$AppsToRemove = Read-Applist (Join-Path $scriptPath "apps_standard.txt")

switch ($choice)
{
    "1"
    {
        # Basis + M365
        $AppsToRemove += Read-Applist (Join-Path $scriptPath "apps_m365.txt")
        $configLabel = "Standard inkl. Microsoft 365"
    }
    "2"
    {
        # Nur Basis
        $configLabel = "Standard exkl. Microsoft 365"
    }
    "3"
    {
        # Basis + Custom
        $AppsToRemove += Read-Applist (Join-Path $scriptPath "apps_custom.txt")
        $configLabel = "Eigene Konfiguration"
    }
    default
    {
        Write-Host "Keine korrekte Auswahl. Verwende Standard-Konfiguration." -ForegroundColor Red
        $AppsToRemove += Read-Applist (Join-Path $scriptPath "apps_m365.txt")
        $configLabel = "Standard inkl. Microsoft 365 (Standard-Fallback)"
    }
}

# Duplikate entfernen
$AppsToRemove = $AppsToRemove | Sort-Object -Unique

Write-Host ""
Write-Host "==> Konfiguration: $configLabel" -ForegroundColor Green
Write-Host "==> Anzahl zu entfernender Apps: $($AppsToRemove.Count)" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 2
