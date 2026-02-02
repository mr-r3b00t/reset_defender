#Requires -RunAsAdministrator
#Requires -Version 5.0
<#
.SYNOPSIS
    Resets Microsoft Defender Antivirus to default settings, including fully clearing and disabling Controlled Folder Access.
.DESCRIPTION
    This script removes custom configurations and restores Defender to its default state.
    For Controlled Folder Access: clears all protected folders and allowed apps, then disables CFA (matches Microsoft default: off/disabled).
#>

Write-Host "Resetting Microsoft Defender Antivirus to defaults..." -ForegroundColor Cyan

# Remove all exclusions
Write-Host "Removing exclusions..." -ForegroundColor Yellow
$prefs = Get-MpPreference
if ($prefs.ExclusionPath) {
    Remove-MpPreference -ExclusionPath $prefs.ExclusionPath -ErrorAction SilentlyContinue
}
if ($prefs.ExclusionExtension) {
    Remove-MpPreference -ExclusionExtension $prefs.ExclusionExtension -ErrorAction SilentlyContinue
}
if ($prefs.ExclusionProcess) {
    Remove-MpPreference -ExclusionProcess $prefs.ExclusionProcess -ErrorAction SilentlyContinue
}
if ($prefs.ExclusionIpAddress) {
    Remove-MpPreference -ExclusionIpAddress $prefs.ExclusionIpAddress -ErrorAction SilentlyContinue
}

# Reset Controlled Folder Access: Clear protected folders, allowed apps, then disable CFA
Write-Host "Fully resetting Controlled Folder Access (clear protected folders + disable CFA)..." -ForegroundColor Yellow

# Clear all user-added protected folders
if ($prefs.ControlledFolderAccessProtectedFolders) {
    Write-Host "Removing all added protected folders..." -ForegroundColor Green
    Remove-MpPreference -ControlledFolderAccessProtectedFolders $prefs.ControlledFolderAccessProtectedFolders -ErrorAction SilentlyContinue
}

# Clear allowed applications
if ($prefs.ControlledFolderAccessAllowedApplications) {
    Write-Host "Removing all allowed applications..." -ForegroundColor Green
    Remove-MpPreference -ControlledFolderAccessAllowedApplications $prefs.ControlledFolderAccessAllowedApplications -ErrorAction SilentlyContinue
}

# Disable CFA to match default state (0 = Disabled)
Set-MpPreference -EnableControlledFolderAccess Disabled
Write-Host "Controlled Folder Access has been disabled (default state)." -ForegroundColor Green

# Reset Attack Surface Reduction (ASR) rules
Write-Host "Resetting Attack Surface Reduction rules..." -ForegroundColor Yellow
if ($prefs.AttackSurfaceReductionRules_Ids) {
    Remove-MpPreference -AttackSurfaceReductionRules_Ids $prefs.AttackSurfaceReductionRules_Ids -ErrorAction SilentlyContinue
}
if ($prefs.AttackSurfaceReductionOnlyExclusions) {
    Remove-MpPreference -AttackSurfaceReductionOnlyExclusions $prefs.AttackSurfaceReductionOnlyExclusions -ErrorAction SilentlyContinue
}

# Reset scan settings to defaults
Write-Host "Resetting scan settings..." -ForegroundColor Yellow
Set-MpPreference -ScanParameters 1                # Quick scan (default)
Set-MpPreference -ScanScheduleDay 0               # Every day
Set-MpPreference -ScanScheduleTime (Get-Date -Hour 2 -Minute 0)  # 2:00 AM
Set-MpPreference -ScanAvgCPULoadFactor 50         # 50% CPU (default)
Set-MpPreference -DisableArchiveScanning $false
Set-MpPreference -DisableRemovableDriveScanning $true   # Default is disabled
Set-MpPreference -DisableEmailScanning $true            # Default is disabled

# Reset real-time protection settings
Write-Host "Resetting real-time protection..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableIOAVProtection $false     # Downloads/attachments scanning
Set-MpPreference -DisableScriptScanning $false

# Reset cloud protection settings
Write-Host "Resetting cloud protection..." -ForegroundColor Yellow
Set-MpPreference -MAPSReporting 2                  # Advanced (default)
Set-MpPreference -SubmitSamplesConsent 1           # Safe samples (default)
Set-MpPreference -DisableBlockAtFirstSeen $false

# Reset threat actions to defaults (Quarantine is the default for all threat levels)
Write-Host "Resetting threat actions..." -ForegroundColor Yellow
Set-MpPreference -LowThreatDefaultAction Quarantine
Set-MpPreference -ModerateThreatDefaultAction Quarantine
Set-MpPreference -HighThreatDefaultAction Quarantine
Set-MpPreference -SevereThreatDefaultAction Quarantine

# Reset network protection
Write-Host "Resetting network protection..." -ForegroundColor Yellow
Set-MpPreference -EnableNetworkProtection 0        # 0 = Disabled (default)

# Reset PUA protection
Write-Host "Resetting PUA protection..." -ForegroundColor Yellow
Set-MpPreference -PUAProtection 0                  # 0 = Disabled (default)

# Reset Exploit Protection to system defaults
Write-Host "Resetting Exploit Protection..." -ForegroundColor Yellow
Set-ProcessMitigation -System -Reset

# Update signatures
Write-Host "Updating virus definitions..." -ForegroundColor Yellow
Update-MpSignature

# Final confirmation for CFA state
Write-Host "`nFinal Controlled Folder Access status:" -ForegroundColor Cyan
$finalPrefs = Get-MpPreference
Write-Host "  EnableControlledFolderAccess: $($finalPrefs.EnableControlledFolderAccess)  (0 = Disabled / default)"
Write-Host "  Protected folders added: $($finalPrefs.ControlledFolderAccessProtectedFolders.Count)"
Write-Host "  Allowed applications: $($finalPrefs.ControlledFolderAccessAllowedApplications.Count)"

Write-Host "`nMicrosoft Defender has been reset to defaults, including Controlled Folder Access fully cleared and disabled." -ForegroundColor Green
Write-Host "A restart may be required for all changes to take effect." -ForegroundColor Cyan
Write-Host "Note: Default protected folders (Documents, Pictures, etc.) remain defined but inactive until CFA is re-enabled." -ForegroundColor Yellow
