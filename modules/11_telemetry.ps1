# ==============================================================================
# ABSCHNITT 11: DATENSCHUTZ & TELEMETRIE
# ==============================================================================
Write-Step "Deaktiviere Telemetrie und Datenerfassung..."

if (Confirm-Step "Telemetrie, Cortana, Werbe-ID und Activity History deaktivieren")
{
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

    $telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $telemetryPath))
    { New-Item -Path $telemetryPath -Force | Out-Null
    }
    Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    Write-Host "==> Success - Telemetrie-Level auf 0 gesetzt (Policy)." -ForegroundColor Green

    $telemetryPathSys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    if (-not (Test-Path $telemetryPathSys))
    { New-Item -Path $telemetryPathSys -Force | Out-Null
    }
    Set-ItemProperty -Path $telemetryPathSys -Name "AllowTelemetry"             -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $telemetryPathSys -Name "MaxTelemetryAllowed"        -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $telemetryPathSys -Name "AllowDeviceNameInTelemetry" -Value 0 -Type DWord -Force
    Write-Host "==> Success - Telemetrie-Level auf 0 gesetzt (System)." -ForegroundColor Green

    $feedbackPath = "HKCU:\Software\Microsoft\Siuf\Rules"
    if (-not (Test-Path $feedbackPath))
    { New-Item -Path $feedbackPath -Force | Out-Null
    }
    Set-ItemProperty -Path $feedbackPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -Force
    Write-Host "==> Success - Feedback-Anfragen deaktiviert." -ForegroundColor Green

    $activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (-not (Test-Path $activityPath))
    { New-Item -Path $activityPath -Force | Out-Null
    }
    Set-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $activityPath -Name "EnableActivityFeed"    -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $activityPath -Name "UploadUserActivities"  -Value 0 -Type DWord -Force
    Write-Host "==> Success - Aktivitätsverlauf deaktiviert." -ForegroundColor Green

    $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $cortanaPath))
    { New-Item -Path $cortanaPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
    Write-Host "==> Success - Cortana deaktiviert." -ForegroundColor Green

    $advPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    if (-not (Test-Path $advPath))
    { New-Item -Path $advPath -Force | Out-Null
    }
    Set-ItemProperty -Path $advPath -Name "Enabled" -Value 0 -Type DWord -Force
    Write-Host "==> Success - Werbe-ID deaktiviert." -ForegroundColor Green

    $privacyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
    if (-not (Test-Path $privacyPath))
    { New-Item -Path $privacyPath -Force | Out-Null
    }
    Set-ItemProperty -Path $privacyPath -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -Force
    Write-Host "==> Success - App-Tracking deaktiviert." -ForegroundColor Green

    Write-Host ""
    Write-Host "==> Info - Telemetrie und Datenerfassung vollständig deaktiviert." -ForegroundColor Green
}
