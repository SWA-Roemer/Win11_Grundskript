# ========================================================================================================
# Teil 2: Registry-Einstellungen - Outlook
# ========================================================================================================
Write-Step "Setze Registry-Einstellungen..."

if (Confirm-Step "Outlook Registry-Einstellungen setzen")
{
    $OutlookDisable1 = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General"
    if (-not (Test-Path $OutlookDisable1))
    { New-Item -Path $OutlookDisable1 -Force | Out-Null
    }

    try
    {
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

    $DisableOutlookMigration = "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences"
    if (-not (Test-Path $DisableOutlookMigration))
    { New-Item -Path $DisableOutlookMigration -Force | Out-Null
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
}
Write-Host ""
