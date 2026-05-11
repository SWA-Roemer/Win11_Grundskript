# ========================================================================================================
# Windows Bloatware Entfernungs-Skript
# ========================================================================================================
# WICHTIG: Als Administrator starten!

$step = 0
$totalSteps = 13

# ==============================================================================
# ADMIN-CHECK
# ==============================================================================
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "Dieses Skript muss als Administrator gestartet werden!"
    Write-Host "Rechtsklick auf die Datei -> 'Als Administrator starten'" -ForegroundColor Yellow
    Pause
    exit
}

# ==============================================================================
# AUSFÜHRUNGSMODUS
# ==============================================================================
function Select-ExecutionMode
{
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "     Skriptmodus aussuchen" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Automatisch  - Alle Schritte ohne fragen aktivieren" -ForegroundColor White
    Write-Host "  [2] Manuell      - Jeden Schritt abfragen" -ForegroundColor White
    Write-Host "  [3] Entwicklung  - Entwicklungsmodus (Deaktiviert Updater)" -ForegroundColor White
    Write-Host ""
    $modeChoice = Read-Host "==> Deine Wahl (1-3)"
    switch ($modeChoice)
    {
        "3"
        { return "dev"
        }
        "2"
        { return "manual"
        }
        default
        { return "auto"
        }
    }
}

function Confirm-Step($stepName)
{
    if ($script:ExecutionMode -eq "manual")
    {
        Write-Host ""
        Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan
        Write-Host "  Schritt: $stepName" -ForegroundColor Cyan
        Write-Host "------------------------------------------------------------" -ForegroundColor DarkCyan
        $answer = Read-Host "==> Diesen Schritt aktivieren? (J/N, Enter = J)"
        if ($answer -eq "N" -or $answer -eq "n")
        {
            Write-Host "==> Nicht aktiviert." -ForegroundColor DarkGray
            return $false
        }
    }
    return $true
}

function Write-Step($msg)
{
    $script:step++
    Write-Host "[$script:step/$totalSteps] $msg" -ForegroundColor Green
}

# ==============================================================================
# AUTO-UPDATE (wird im Dev-Modus übersprungen)
# ==============================================================================
if ($script:ExecutionMode -eq "dev")
{
    Write-Host "==> [DEV-MODUS] Auto-Updater deaktiviert." -ForegroundColor Magenta
} else
{
    $GH_USER  = "SWA-Roemer"
    $GH_REPO  = "Win11_Grundskript"
    $ZIP_NAME = "Win11_Grundskript.zip"

    $headers     = @{ Accept = "application/vnd.github+json" }
    $selfPath    = $MyInvocation.MyCommand.Path
    $scriptDir   = Split-Path -Parent $selfPath
    $versionFile = Join-Path $scriptDir "version.txt"

    if (Test-Path $versionFile)
    {
        $localVersion = (Get-Content $versionFile -Raw).Trim()
    } else
    {
        $localVersion = "v0.0.0"
        Write-Host "==> Info - Keine version.txt gefunden, nehme $localVersion an." -ForegroundColor Gray
    }

    Write-Host "==> Lokale Version:  $localVersion" -ForegroundColor Cyan

    try
    {
        $releaseApi    = "https://api.github.com/repos/$GH_USER/$GH_REPO/releases/latest"
        $release       = Invoke-RestMethod -Uri $releaseApi -Headers $headers -TimeoutSec 5
        $remoteVersion = $release.tag_name
        Write-Host "==> Remote Version:  $remoteVersion" -ForegroundColor Cyan

        if ([version]($remoteVersion -replace 'v','') -gt [version]($localVersion -replace 'v',''))
        {
            Write-Host "==> Neue Version verfuegbar! Update wird geladen..." -ForegroundColor Yellow

            # ZIP-Asset aus dem Release suchen
            $asset = $release.assets | Where-Object { $_.name -eq $ZIP_NAME } | Select-Object -First 1

            if (-not $asset)
            {
                Write-Host "==> Warn - Kein ZIP-Asset '$ZIP_NAME' im Release gefunden. Update übersprungen." -ForegroundColor Yellow
            } else
            {
                $zipPath = Join-Path $env:TEMP $ZIP_NAME

                # ZIP herunterladen
                Invoke-WebRequest -Uri $asset.browser_download_url `
                    -Headers $headers `
                    -OutFile $zipPath `
                    -UseBasicParsing `
                    -TimeoutSec 30

                # Backup des aktuellen Verzeichnisses anlegen
                $backupDir = "$scriptDir.bak"
                if (Test-Path $backupDir)
                { Remove-Item $backupDir -Recurse -Force 
                }
                Copy-Item -Path $scriptDir -Destination $backupDir -Recurse -Force
                Write-Host "==> Info - Backup angelegt unter: $backupDir" -ForegroundColor Gray

                # ZIP ins Skriptverzeichnis entpacken (überschreibt alle Dateien)
                Expand-Archive -Path $zipPath -DestinationPath $scriptDir -Force
                Remove-Item $zipPath -Force

                Write-Host "==> Update auf $remoteVersion erfolgreich! Neustart..." -ForegroundColor Green
                Start-Sleep -Seconds 2

                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$selfPath`"" -Verb RunAs
                exit
            }
        } else
        {
            Write-Host "==> Skript ist aktuell, kein Update noetig." -ForegroundColor Green
        }
    } catch
    {
        Write-Host "==> Info - Offline oder Fehler, nutze lokale Version ($localVersion)" -ForegroundColor Gray
    }
}

Write-Host ""

# ==============================================================================
# MODUS WÄHLEN
# ==============================================================================
$ExecutionMode = Select-ExecutionMode

Write-Host ""

switch ($ExecutionMode)
{
    "manual"
    {
        Write-Host "==> Manueller Modus aktiv - Jeden Schritt einzeln erledigen." -ForegroundColor Yellow
    }
    "auto"
    {
        Write-Host "==> Automatischer Modus aktiv - Alle Schritte werden aktiviert." -ForegroundColor Green
    }
    "dev"
    {
        Write-Host "==> Entwicklungsmodus aktiv - Alle Schritte werden aktiviert ohne automatisches Update" -ForegroundColor Green
    }
    default
    {
        Write-Host "==> Kein Modus gefunden. Kontaktiere den Entwickler!" -ForegroundColor Red
    }
}

if ($ExecutionMode -eq "manual")
{

} else
{

}
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$scriptPath\modules\00_config_file.ps1"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Windows Bloatware Entfernungs-Skript" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

. "$scriptPath\modules\01_outlook_removal.ps1"
. "$scriptPath\modules\02_outlook_registry.ps1"
. "$scriptPath\modules\03_app_removal.ps1"
. "$scriptPath\modules\04_energy_options.ps1"
. "$scriptPath\modules\05_win_features.ps1"
. "$scriptPath\modules\06_firewall_rdp.ps1"
. "$scriptPath\modules\07_rdp.ps1"
. "$scriptPath\modules\08_explorer.ps1"
. "$scriptPath\modules\09_disconnect.ps1"
. "$scriptPath\modules\10_numlock.ps1"
. "$scriptPath\modules\11_telemetry.ps1"
. "$scriptPath\modules\12_bing_search.ps1"
. "$scriptPath\modules\13_lockscreen.ps1"
Write-Host ""
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Success - Skript abgeschlossen!" -ForegroundColor Green
Write-Host "     Ein Neustart wird empfohlen!" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Read-Host "Enter zum Schliessen"
