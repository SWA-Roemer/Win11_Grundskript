# ========================================================================================================
# Teil 5: Windows Features aktivieren
# ========================================================================================================
Write-Step "Windows Features werden aktiviert..."

if (Confirm-Step "Windows Features aktivieren (.NET 3.5, SimpleTCP)")
{
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
}
Write-Host ""
