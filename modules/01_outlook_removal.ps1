# ========================================================================================================
# Teil 1: Outlook (new) deinstallieren
# ========================================================================================================
Write-Step "Deinstalliere Outlook (new)..."

if (Confirm-Step "Outlook (new) deinstallieren")
{
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
}
Write-Host ""
