# ========================================================================================================
# Abschnitt 10: NumLock Taste aktivieren
# ========================================================================================================
Write-Step "Aktiviere NumLock..."

if (Confirm-Step "NumLock beim Start aktivieren")
{
    $regPathDefault = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard"
    $currentValue   = [int64](Get-ItemPropertyValue -Path $regPathDefault -Name "InitialKeyboardIndicators")
    if ($currentValue -eq 2147483648 -or $currentValue -eq 0)
    {
        Set-ItemProperty -Path $regPathDefault -Name "InitialKeyboardIndicators" -Value ($currentValue + 2)
        Write-Host "==> Success - NumLock global (Default-Profil) aktiviert." -ForegroundColor Green
    } else
    {
        Write-Host "==> Info - NumLock global bereits aktiviert." -ForegroundColor Gray
    }

    $regPathUser      = "HKCU:\Control Panel\Keyboard"
    $currentUserValue = [int64](Get-ItemPropertyValue -Path $regPathUser -Name "InitialKeyboardIndicators")
    if ($currentUserValue -ne 2 -and $currentUserValue -ne 2147483650)
    {
        Set-ItemProperty -Path $regPathUser -Name "InitialKeyboardIndicators" -Value 2
        Write-Host "==> Success - NumLock des aktuellen Nutzers aktiviert." -ForegroundColor Green
    } else
    {
        Write-Host "==> Info - NumLock des aktuellen Nutzers bereits aktiviert." -ForegroundColor Gray
    }
}
