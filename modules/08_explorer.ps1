# ========================================================================================================
# Abschnitt 8: Explorer-Einstellungen
# ========================================================================================================
Write-Step "Explorer und Taskleiste wird eingestellt..."

if (Confirm-Step "Explorer-Einstellungen anpassen (Dateiendungen, Chat-Symbol, Freigabeassistent)")
{
    $regPath       = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $restartNeeded = $false

    $hideExt = Get-ItemProperty -Path $regPath -Name "HideFileExt" -ErrorAction SilentlyContinue
    if ($null -eq $hideExt -or $hideExt.HideFileExt -ne 0)
    {
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value 0 -Force
        Write-Host "==> Success - Dateiendungen aktiviert." -ForegroundColor Green
        $restartNeeded = $true
    }

    $sharingWiz = Get-ItemProperty -Path $regPath -Name "SharingWizardOn" -ErrorAction SilentlyContinue
    if ($null -eq $sharingWiz -or $sharingWiz.SharingWizardOn -ne 0)
    {
        Set-ItemProperty -Path $regPath -Name "SharingWizardOn" -Value 0 -Force
        Write-Host "==> Success - Freigabeassistent deaktiviert." -ForegroundColor Green
        $restartNeeded = $true
    }

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

    if ($restartNeeded)
    {
        Write-Host "==> Info - Explorer wird neu gestartet..." -ForegroundColor Gray
        Stop-Process -Name explorer -Force
        Start-Sleep -Seconds 1
        Start-Process explorer.exe
    } else
    {
        Write-Host "===> Info - Explorer-Einstellungen sind bereits korrekt." -ForegroundColor Gray
    }
}
