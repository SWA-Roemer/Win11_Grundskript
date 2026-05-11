# ========================================================================================================
# Teil 4: Energieoptionen
# ========================================================================================================
Write-Step "Energieoptionen werden angepasst..."

if (Confirm-Step "Energieoptionen (alle Timeouts auf nie) setzen")
{
    powercfg -X -monitor-timeout-ac 0
    powercfg -X -disk-timeout-ac 0
    powercfg -X -standby-timeout-ac 0
    powercfg -X -hibernate-timeout-ac 0
    Write-Host "==> Success - Alle AC-Timeouts auf 0 gesetzt." -ForegroundColor Green
}
Write-Host ""
