# ========================================================================================================
# Teil 3: Andere vorinstallierte Apps entfernen
# ========================================================================================================
Write-Step "Entferne andere vorinstallierte Apps..."

if (Confirm-Step "Vorinstallierte Apps ($($AppsToRemove.Count) Apps) entfernen")
{
    $RemovedCount = 0
    $FailedCount  = 0

    foreach ($App in $AppsToRemove)
    {
        # Im manuellen Modus: pro App nachfragen
        if ($ExecutionMode -eq "manual")
        {
            $appAnswer = Read-Host "     Entferne '$App'? (J/N, Enter = J)"
            if ($appAnswer -eq "N" -or $appAnswer -eq "n")
            {
                Write-Host "     ==> Übersprungen: $App" -ForegroundColor DarkGray
                continue
            }
        }

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
}
Write-Host ""
