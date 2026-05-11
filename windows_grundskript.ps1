# ========================================================================================================
# Windows Bloatware Entfernungs-Skript
# ========================================================================================================
# WICHTIG: Als Administrator starten!

$step = 0
$totalSteps = 13  # Einmal oben anpassen

function Write-Step($msg)
{
    $script:step++
    Write-Host "[$script:step/$totalSteps] $msg" -ForegroundColor Green
}

# Checken ob das Skript als Administrator gestartet wurde
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{

    Write-Warning "Dieses Skript muss als Administrator gestartet werden!"
    Write-Host "Rechtsklick auf die Datei -> 'Als Administrator starten'" -ForegroundColor Yellow
    Pause
    exit
}

# ==============================================================================
# AUTO-UPDATE (GitHub Releases, version.txt, Offline-Fallback)
# ==============================================================================
$GH_USER  = "SWA-Roemer"
$GH_REPO  = "Win11_Grundskript"

$headers = @{
    Accept        = "application/vnd.github+json"
}

$selfPath    = $MyInvocation.MyCommand.Path
$scriptDir   = Split-Path -Parent $selfPath
$versionFile = Join-Path $scriptDir "version.txt"

# Lokale Version lesen (falls Datei fehlt → "v0.0.0" als Fallback)
if (Test-Path $versionFile)
{
    $localVersion = (Get-Content $versionFile -Raw).Trim()
} else
{
    $localVersion = "v0.0.0"
    Write-Host "==> Info - Keine version.txt gefunden, nehme $localVersion an." -ForegroundColor Gray
}

Write-Host "==> Lokale Version: $localVersion" -ForegroundColor Cyan

try
{
    # Neuesten Release von GitHub abrufen
    $releaseApi = "https://api.github.com/repos/$GH_USER/$GH_REPO/releases/latest"
    $release    = Invoke-RestMethod -Uri $releaseApi -Headers $headers -TimeoutSec 5

    $remoteVersion = $release.tag_name  # z.B. "v1.2.0"
    Write-Host "==> Remote Version:  $remoteVersion" -ForegroundColor Cyan

    if ([version]($remoteVersion -replace 'v','') -gt [version]($localVersion -replace 'v',''))
    {
        Write-Host "==> Neue Version verfuegbar! Update wird geladen..." -ForegroundColor Yellow

        # Skript herunterladen (aus dem getaggten Commit)
        $rawUrl    = "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/refs/tags/$remoteVersion/windows_grundskript.ps1"
        $newScript = (Invoke-WebRequest -Uri $rawUrl -Headers $headers -UseBasicParsing -TimeoutSec 10).Content

        # Backup anlegen
        Copy-Item -Path $selfPath -Destination "$selfPath.bak" -Force

        # Neues Skript speichern
        Set-Content -Path $selfPath -Value $newScript -Encoding UTF8

        # Version lokal aktualisieren
        Set-Content -Path $versionFile -Value $remoteVersion -Encoding UTF8

        Write-Host "==> Update auf $remoteVersion erfolgreich! Neustart..." -ForegroundColor Green
        Start-Sleep -Seconds 2

        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$selfPath`"" -Verb RunAs
        exit

    } else
    {
        Write-Host "==> Skript ist aktuell, kein Update noetig." -ForegroundColor Green
    }

} catch
{
    Write-Host "==> Info - Offline oder Fehler, nutze lokale Version ($localVersion)" -ForegroundColor Gray
}

Write-Host ""
# ==============================================================================
# ENDE AUTO-UPDATE
# ==============================================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Windows Bloatware Entfernungs-Skript Vorbereitung" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
# ========================================================================================================
# Teil 0: Konfigurationsdatei nutzen
# ========================================================================================================
Write-Host "Bitte selektiere eine Konfiguration:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Standard (entfernt alle Bloatware inkl. Microsoft 365) [apps_standard.txt]" -ForegroundColor White
Write-Host "  [2] Standard, aber Microsoft 365 behalten [apps_exkl_m365.txt]" -ForegroundColor White
Write-Host "  [3] Eigene Datei [apps_custom.txt]" -ForegroundColor White
Write-Host ""

$choice = Read-Host "==> Deine Wahl (1-3)"

# Standard-Pfad ist das Verzeichnis, in dem das Skript liegt
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

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

# Testen ob Datei existiert
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

# Apps aus Datei einlesen (ignoriere Kommentare und leere Zeilen)
$AppsToRemove = Get-Content $configFile | Where-Object {
    $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$'
} | ForEach-Object { $_.Trim() }

Write-Host ""
Write-Host "==> Verwende Konfiguration: $configFile" -ForegroundColor Green
Write-Host "==> Anzahl zu entfernender Apps: $($AppsToRemove.Count)" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 2

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Windows Bloatware Entfernungs-Skript" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ========================================================================================================
# Teil 1: Outlook (new) deinstallieren
# ========================================================================================================
Write-Step "Deinstalliere Outlook (new)..." -ForegroundColor Green

# Outlook (new) ist eine AppX-Anwendung und nennt sich "Microsoft.OutlookForWindows"
$OutlookApp = Get-AppxPackage -Name "Microsoft.OutlookForWindows" -AllUsers

if ($OutlookApp)
{
    Write-Host "==> Gefunden: $($OutlookApp.Name) Version $($OutlookApp.Version)" -ForegroundColor Yellow
    try
    {
        Remove-AppxPackage -Package $OutlookApp.PackageFullName -AllUsers
        Write-Host "==> Success - Outlook (new) wurde deinstalliert" -ForegroundColor Green
    } catch
    {
        Write-Host "==> Error - Fehler beim Deinstallieren: $($_.Exception.Message)" -ForegroundColor Red
    }
} else
{
    Write-Host "==> Success - Outlook (new) ist nicht installiert" -ForegroundColor Green
}

# Auch provisionierte Version entfernen (verhindert automatische Installation bei neuen Benutzern)
$ProvisionedOutlook = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq "Microsoft.OutlookForWindows"
if ($ProvisionedOutlook)
{
    try
    {
        Remove-AppxProvisionedPackage -Online -PackageName $ProvisionedOutlook.PackageName
        Write-Host "==> Success - Outlook (new) aus Provisioning entfernt" -ForegroundColor Green
    } catch
    {
        Write-Host "==> Error - Fehler beim Entfernen aus Provisioning: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# ========================================================================================================
# Teil 2: Registry-Einstellungen - Outlook
# ========================================================================================================
Write-Step "Setze Registry-Einstellungen..." -ForegroundColor Green

# ===== Consumer Features deaktivieren (verhindert automatische App-Installationen) =====
$OutlookDisable1 = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"

if (-not (Test-Path $OutlookDisable1))
{
    New-Item -Path $OutlookDisable1 -Force | Out-Null
}

try
{
    # Testen, ob der Wert existiert
    if (-not (Get-ItemProperty -Path $OutlookDisable1 -Name "HideNewOutlookToggle" -ErrorAction SilentlyContinue))
    {
        New-ItemProperty -Path $OutlookDisable1 -Name "HideNewOutlookToggle" -Value 0 -PropertyType DWord -Force | Out-Null
    } else
    {
        Set-ItemProperty -Path $OutlookDisable1 -Name "HideNewOutlookToggle" -Value 0 | Out-Null
    }
    Write-Host "==> Success - Windows Consumer Features deaktiviert" -ForegroundColor Green
} catch
{
    Write-Host "==> Error - Registry Key: HideNewOutlookToggle - Fehler: $($_.Exception.Message)" -ForegroundColor Red
}


# ===== Soll Outlook updates verhindern =====
$OutlookDisableUpdate = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate"

try
{
    if (Test-Path $OutlookDisableUpdate)
    {
        Remove-Item -Path $OutlookDisableUpdate -Recurse -Force | Out-Null
        Write-Host "==> Success - Windows Outlook Update deaktiviert" -ForegroundColor Green
    } else
    {
        Write-Host "==> Info - Kein OutlookUpdate-Key gefunden (bereits deaktiviert)" -ForegroundColor Gray
    }
} catch
{
    Write-Host "==> Error - Entfernen des Registry-Pfads OutlookUpdate - Fehler: $($_.Exception.Message)" -ForegroundColor Red
}

# ===== Outlook Migration verhindern =====
$DisableOutlookMigration = "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences"

if (-not (Test-Path $DisableOutlookMigration))
{
    New-Item -Path $DisableOutlookMigration -Force | Out-Null
}

try
{
    if (-not (Get-ItemProperty -Path $DisableOutlookMigration -Name "NewOutlookMigrationUserSetting" -ErrorAction SilentlyContinue))
    {
        New-ItemProperty -Path $DisableOutlookMigration -Name "NewOutlookMigrationUserSetting" -Value 0 -PropertyType DWord -Force | Out-Null
    } else
    {
        Set-ItemProperty -Path $DisableOutlookMigration -Name "NewOutlookMigrationUserSetting" -Value 0 | Out-Null
    }
    Write-Host "==> Success - Outlook Migration deaktiviert" -ForegroundColor Green
} catch
{
    Write-Host "==> Error - Registry Key: NewOutlookMigrationUserSetting - Fehler: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# ========================================================================================================
# Teil 3: Andere vorinstallierte Apps entfernen
# ========================================================================================================
Write-Step "Entferne andere vorinstallierte Apps..." -ForegroundColor Green

$RemovedCount = 0
$FailedCount = 0

foreach ($App in $AppsToRemove)
{
    $Package = Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue

    if ($Package)
    {
        foreach ($UserPackage in $Package)
        {
            Write-Host "Entferne: $($UserPackage.Name)" -ForegroundColor Yellow
            try
            {
                Remove-AppxPackage -Package $UserPackage.PackageFullName -AllUsers -ErrorAction Stop
                $RemovedCount++
                Write-Host "===> Success - Erfolgreich entfernt" -ForegroundColor Green
            } catch
            {
                $FailedCount++
                Write-Host "===> Error - Fehler: $($_.Exception.Message)" -ForegroundColor Red
            }
        }

        # Auch aus Provisioning entfernen
        $ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $App
        if ($ProvisionedPackage)
        {
            try
            {
                Remove-AppxProvisionedPackage -Online -PackageName $ProvisionedPackage.PackageName -ErrorAction Stop | Out-Null
                Write-Host "==> Success - Aus Provisioning entfernt" -ForegroundColor Green
            } catch
            {
                Write-Host "==> Warn - Konnte nicht aus Provisioning entfernt werden" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Zusammenfassung:" -ForegroundColor Cyan
Write-Host "     Erfolgreich entfernt: $RemovedCount Apps" -ForegroundColor Green
if ($FailedCount -gt 0)
{
    Write-Host "     Fehlgeschlagen: $FailedCount Apps" -ForegroundColor Red
}
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
# ========================================================================================================
# Teil 4: Energieoptionen & Firewall (legacy)
# ========================================================================================================

Write-Step "Energieoptionen werden angepasst..." -ForegroundColor Green

# Energieoptionen: Timeout auf 0 (nie)
powercfg -X -monitor-timeout-ac 0
powercfg -X -disk-timeout-ac 0
powercfg -X -standby-timeout-ac 0
powercfg -X -hibernate-timeout-ac 0
Write-Host ""
# ========================================================================================================
# Teil 5: Windows Features aktivieren
# ========================================================================================================

Write-Step "Windows Features werden aktiviert..." -ForegroundColor Green

# .NET Framework 3.5 aktivieren
$netfx3 = Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart -ErrorAction SilentlyContinue
if ($netfx3.RestartNeeded -eq $true -or $netfx3.State -eq "Enabled")
{
    Write-Host "==> Success - .NET Framework 3.5 wurde erfolgreich aktiviert." -ForegroundColor Green
} elseif ($netfx3.State -eq "EnablePending")
{
    Write-Host "==> Info - .NET Framework 3.5 wird beim Neustart aktiviert." -ForegroundColor Gray
} elseif ((Get-WindowsOptionalFeature -Online -FeatureName NetFx3).State -eq "Enabled")
{
    Write-Host "==> Info - .NET Framework 3.5 ist bereits installiert" -ForegroundColor Gray
} else
{
    Write-Host "==> Error - .NET Framework 3.5 konnte nicht installiert werden" -ForegroundColor Red
}

# Simple TCP/IP Services (z.B. Echo, Daytime etc.)
$simpletcp = Enable-WindowsOptionalFeature -Online -FeatureName "SimpleTCP" -All -NoRestart -ErrorAction SilentlyContinue

if ($simpletcp.RestartNeeded -eq $true -or $simpletcp.State -eq "Enabled")
{
    Write-Host "==> Success - Simple TCP/IP Services wurden erfolgreich aktiviert." -ForegroundColor Green
} elseif ($simpletcp.State -eq "EnablePending")
{
    Write-Host "==> Info - Simple TCP/IP Services werden beim Neustart aktiviert." -ForegroundColor Gray
} elseif ((Get-WindowsOptionalFeature -Online -FeatureName "SimpleTCP").State -eq "Enabled")
{
    Write-Host "==> Info - Simple TCP/IP Services sind bereits installiert." -ForegroundColor Gray
} else
{
    Write-Host "==> Error - Simple TCP/IP Services konnten nicht installiert werden." -ForegroundColor Red
}

Write-Host ""
# ========================================================================================================
# Abschnitt 6: Firewall-Einstellungen
# ========================================================================================================
Write-Step "Firewall regeln werden eingestellt..." -ForegroundColor Green

Write-Host "==> Info - Aktiviere RDP Regeln" -ForegroundColor Gray

# RDP-Regeln anzeigen
Get-NetFirewallRule | Where-Object {
    ($_.DisplayName -like "*remotedesktop*") -and
    $_.Enabled -eq $true
} | Select-Object DisplayName, Direction, Profile | Format-Table -AutoSize

# RDP-Regeln aktivieren
Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like "*remotedesktop*"
} | Enable-NetFirewallRule

Write-Host "==> Success - RDP Firewall regeln wurden aktiviert." -ForegroundColor Green

Write-Host "==> Info - Aktiviere ICMP Regeln" -ForegroundColor Gray

# ICMP-Regeln anzeigen
Get-NetFirewallRule | Where-Object {
    ($_.DisplayName -like "*ICMP*" -or $_.Protocol -eq "ICMPv4" -or $_.Protocol -eq "ICMPv6") -and
    $_.Enabled -eq $true
} | Select-Object DisplayName, Direction, Profile | Format-Table -AutoSize

# ICMP-Regeln aktivieren (Ping)
Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like "*ICMP*" -or
    ($_.Protocol -eq "ICMPv4") -or
    ($_.Protocol -eq "ICMPv6")
} | Enable-NetFirewallRule

Write-Host "==> Success - ICMP Firewall regeln wurden aktiviert." -ForegroundColor Green

# ========================================================================================================
# Abschnitt 7: Explorer-Einstellungen
# ========================================================================================================

Write-Step "Explorer und Taskleiste wird eingestellt..." -ForegroundColor Green

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$restartNeeded = $false

# 1. Anzeige von Dateiendungen aktivieren
$hideExt = Get-ItemProperty -Path $regPath -Name "HideFileExt" -ErrorAction SilentlyContinue
if ($null -eq $hideExt -or $hideExt.HideFileExt -ne 0)
{
    Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value 0 -Force
    Write-Host "==> Success - Dateiendungen aktiviert." -ForegroundColor Green
    $restartNeeded = $true
}

# 2. Freigabeassistent deaktivieren
$sharingWiz = Get-ItemProperty -Path $regPath -Name "SharingWizardOn" -ErrorAction SilentlyContinue
if ($null -eq $sharingWiz -or $sharingWiz.SharingWizardOn -ne 0)
{
    Set-ItemProperty -Path $regPath -Name "SharingWizardOn" -Value 0 -Force
    Write-Host "==> Success - Freigabeassistent deaktiviert." -ForegroundColor Green
    $restartNeeded = $true
}

# 3. Chat (Microsoft Teams) aus der Taskleiste entfernen
Write-Host "Deaktiviere Chat-Symbol..." -ForegroundColor Cyan
try
{
    if (-not (Get-ItemProperty -Path $regPath -Name "TaskbarMn" -ErrorAction SilentlyContinue))
    {
        New-ItemProperty -Path $regPath -Name "TaskbarMn" -Value 0 -PropertyType DWord -Force | Out-Null
    } else
    {
        Set-ItemProperty -Path $regPath -Name "TaskbarMn" -Value 0 -Force
    }
    Write-Host "==> Success - Chat-Symbol deaktiviert." -ForegroundColor Green
    $restartNeeded = $true
} catch
{
    Write-Host "==> Warn - Chat-Symbol konnte nicht deaktiviert werden: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Explorer nur neu starten, wenn wirklich eine Änderung vorgenommen wurde
if ($restartNeeded)
{
    Write-Host "==> Info - Explorer wird neu gestartet..." -ForegroundColor Gray
    Stop-Process -Name explorer -Force
    # Kurze Pause, damit der Prozess sauber beendet wird, bevor er neu startet
    Start-Sleep -Seconds 1
    Start-Process explorer.exe
} else
{
    Write-Host "===> Info - Explorer-Einstellungen sind bereits korrekt." -ForegroundColor Gray
}
# ========================================================================================================
# Abschnitt 8: Verbindungsunterbrechung verhindern
# ========================================================================================================
Write-Step "Deaktiviere automatische Verbindungsunterbrechung..." -ForegroundColor Green
Start-Process -FilePath "net" -ArgumentList "config server /autodisconnect:-1" -Verb RunAs -Wait
Write-Host "==> Info - Einstellung wurde angewendet."

# ========================================================================================================
# Abschnitt 9: NumLock Taste aktivieren
# ========================================================================================================
Write-Step "Aktiviere NumLock..." -ForegroundColor Green

# Für neue/nicht angemeldete Benutzer (Default-Profil)
$regPathDefault = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard"
$currentValue = [int64](Get-ItemPropertyValue -Path $regPathDefault -Name "InitialKeyboardIndicators")

if ($currentValue -eq 2147483648 -or $currentValue -eq 0)
{
    Set-ItemProperty -Path $regPathDefault -Name "InitialKeyboardIndicators" -Value ($currentValue + 2)
    Write-Host "==> Success - NumLock global (Default-Profil) aktiviert." -ForegroundColor Green
} else
{
    Write-Host "==> Info - NumLock global bereits aktiviert." -ForegroundColor Gray
}

# Für den aktuell angemeldeten Benutzer
$regPathUser = "HKCU:\Control Panel\Keyboard"
$currentUserValue = [int64](Get-ItemPropertyValue -Path $regPathUser -Name "InitialKeyboardIndicators")

if ($currentUserValue -ne 2 -and $currentUserValue -ne 2147483650)
{
    Set-ItemProperty -Path $regPathUser -Name "InitialKeyboardIndicators" -Value 2
    Write-Host "==> Success - NumLock des aktuellen Nutzers Benutzers aktiviert." -ForegroundColor Green
} else
{
    Write-Host "==> Info - NumLock des aktuellen Nutzers bereits aktiviert." -ForegroundColor Gray
}

# ==============================================================================
# ABSCHNITT 10: DATENSCHUTZ & TELEMETRIE
# ==============================================================================
Write-Step "Deaktiviere Telemetrie und Datenerfassung..." -ForegroundColor Green

# DiagTrack und dmwappushservice stoppen & deaktivieren
foreach ($svc in @("DiagTrack", "dmwappushservice"))
{
    try
    {
        Set-Service -Name $svc -StartupType Disabled -ErrorAction Stop
        Stop-Service -Name $svc -Force -ErrorAction Stop
        Write-Host "==> Success - Dienst '$svc' deaktiviert." -ForegroundColor Green
    } catch
    {
        Write-Host "==> Warn - Dienst '$svc' konnte nicht deaktiviert werden: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# --- Telemetrie-Level ---
# Per Policy setzen (höchste Priorität)
$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $telemetryPath))
{ New-Item -Path $telemetryPath -Force | Out-Null
}
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry"          -Value 0 -Type DWord -Force
Write-Host "==> Success - Telemetrie-Level auf 0 gesetzt (Policy)." -ForegroundColor Green

# Direkt in der Systemkonfiguration setzen (greift auch ohne GPO)
$telemetryPathSys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
if (-not (Test-Path $telemetryPathSys))
{ New-Item -Path $telemetryPathSys -Force | Out-Null
}
Set-ItemProperty -Path $telemetryPathSys -Name "AllowTelemetry"             -Value 0 -Type DWord -Force
Set-ItemProperty -Path $telemetryPathSys -Name "MaxTelemetryAllowed"        -Value 0 -Type DWord -Force
Set-ItemProperty -Path $telemetryPathSys -Name "AllowDeviceNameInTelemetry" -Value 0 -Type DWord -Force
Write-Host "==> Success - Telemetrie-Level auf 0 gesetzt (System)." -ForegroundColor Green

# --- Feedback-Häufigkeit ---
$feedbackPath = "HKCU:\Software\Microsoft\Siuf\Rules"
if (-not (Test-Path $feedbackPath))
{ New-Item -Path $feedbackPath -Force | Out-Null
}
Set-ItemProperty -Path $feedbackPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -Force
Write-Host "==> Success - Feedback-Anfragen deaktiviert." -ForegroundColor Green

# --- Aktivitätsverlauf (Activity History) ---
$activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
if (-not (Test-Path $activityPath))
{ New-Item -Path $activityPath -Force | Out-Null
}
Set-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $activityPath -Name "EnableActivityFeed"    -Value 0 -Type DWord -Force
Set-ItemProperty -Path $activityPath -Name "UploadUserActivities"  -Value 0 -Type DWord -Force
Write-Host "==> Success - Aktivitätsverlauf deaktiviert." -ForegroundColor Green

# --- Cortana ---
$cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $cortanaPath))
{ New-Item -Path $cortanaPath -Force | Out-Null
}
Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
Write-Host "==> Success - Cortana deaktiviert." -ForegroundColor Green

# --- Werbe-ID (personalisierte Werbung) ---
$advPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $advPath))
{ New-Item -Path $advPath -Force | Out-Null
}
Set-ItemProperty -Path $advPath -Name "Enabled" -Value 0 -Type DWord -Force
Write-Host "==> Success - Werbe-ID deaktiviert." -ForegroundColor Green

# --- App Tracking ---
$privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
if (-not (Test-Path $privacyPath))
{ New-Item -Path $privacyPath -Force | Out-Null
}
Set-ItemProperty -Path $privacyPath -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -Force
Write-Host "==> Success - App-Tracking deaktiviert." -ForegroundColor Green

Write-Host ""
Write-Host "==> Info - Telemetrie und Datenerfassung vollständig deaktiviert." -ForegroundColor Green

# ==============================================================================
# ABSCHNITT 11: BING-WEBSUCHE IM STARTMENÜ DEAKTIVIEREN
# ==============================================================================
Write-Step "Deaktiviere Bing-Websuche im Startmenue..." -ForegroundColor Green

$searchPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"

if (-not (Test-Path $searchPath))
{
    New-Item -Path $searchPath -Force | Out-Null
}

try
{
    Set-ItemProperty -Path $searchPath -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
    Write-Host "==> Success - Bing-Websuche im Startmenue deaktiviert." -ForegroundColor Green
} catch
{
    Write-Host "==> Error - Fehler beim Deaktivieren der Bing-Suche: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# ==============================================================================
# ABSCHNITT 12: SPERRBILDSCHIRM-WERBUNG & TIPPS DEAKTIVIEREN
# ==============================================================================
Write-Step "Deaktiviere Werbung und Tipps (Content Delivery Manager)..." -ForegroundColor Green

$contentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

if (-not (Test-Path $contentPath))
{
    New-Item -Path $contentPath -Force | Out-Null
}

try
{
    # Deaktiviert Tipps und Tricks auf dem Sperrbildschirm
    Set-ItemProperty -Path $contentPath -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord -Force

    # Deaktiviert automatisch installierte gesponserte Apps (z.B. Candy Crush)
    Set-ItemProperty -Path $contentPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force

    # Deaktiviert "Vorgeschlagene Apps" im Startmenü
    Set-ItemProperty -Path $contentPath -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force

    Write-Host "==> Success - Sperrbildschirm-Werbung, Tipps und gesponserte Apps deaktiviert." -ForegroundColor Green
} catch
{
    Write-Host "==> Error - Fehler bei den Sperrbildschirm-Einstellungen: $($_.Exception.Message)" -ForegroundColor Red
}

# ==============================================================================
# ABSCHNITT 13: Remote Desktop aktivieren
# ==============================================================================
Write-Step "Aktiviere Remote Desktop Verbindung" -ForegroundColor Green

# Remote Desktop aktivieren
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# Netzwerkebenen-Authentifizierung (NLA) deaktivieren
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

Write-Host ""
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "     Success - Skript abgeschlossen!" -ForegroundColor Green
Write-Host "     Ein Neustart wird empfohlen!" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Read-Host "Enter zum Schliessen"
