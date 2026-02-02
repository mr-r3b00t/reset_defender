#Requires -RunAsAdministrator
#Requires -Version 5.0

<#
.SYNOPSIS
    Resets Microsoft Defender Antivirus to default settings.
.DESCRIPTION
    This script removes custom configurations and restores Defender to its default state.
#>

Write-Host "Resetting Microsoft Defender Antivirus to defaults..." -ForegroundColor Cyan

# Remove all exclusions
Write-Host "Removing exclusions..." -ForegroundColor Yellow
$prefs = Get-MpPreference

if ($prefs.ExclusionPath) {
    Remove-MpPreference -ExclusionPath $prefs.ExclusionPath
}
if ($prefs.ExclusionExtension) {
    Remove-MpPreference -ExclusionExtension $prefs.ExclusionExtension
}
if ($prefs.ExclusionProcess) {
    Remove-MpPreference -ExclusionProcess $prefs.ExclusionProcess
}
if ($prefs.ExclusionIpAddress) {
    Remove-MpPreference -ExclusionIpAddress $prefs.ExclusionIpAddress
}

# Reset Controlled Folder Access (Protected Folders)
Write-Host "Resetting Controlled Folder Access..." -ForegroundColor Yellow
Set-MpPreference -EnableControlledFolderAccess Disabled

if ($prefs.ControlledFolderAccessProtectedFolders) {
    Remove-MpPreference -ControlledFolderAccessProtectedFolders $prefs.ControlledFolderAccessProtectedFolders
}
if ($prefs.ControlledFolderAccessAllowedApplications) {
    Remove-MpPreference -ControlledFolderAccessAllowedApplications $prefs.ControlledFolderAccessAllowedApplications
}

# Reset Attack Surface Reduction (ASR) rules
Write-Host "Resetting Attack Surface Reduction rules..." -ForegroundColor Yellow
if ($prefs.AttackSurfaceReductionRules_Ids) {
    Remove-MpPreference -AttackSurfaceReductionRules_Ids $prefs.AttackSurfaceReductionRules_Ids
}
if ($prefs.AttackSurfaceReductionOnlyExclusions) {
    Remove-MpPreference -AttackSurfaceReductionOnlyExclusions $prefs.AttackSurfaceReductionOnlyExclusions
}

# Reset scan settings to defaults
Write-Host "Resetting scan settings..." -ForegroundColor Yellow
Set-MpPreference -ScanParameters 1                          # Quick scan (default)
Set-MpPreference -ScanScheduleDay 0                         # Every day
Set-MpPreference -ScanScheduleTime (Get-Date -Hour 2 -Minute 0)  # 2:00 AM
Set-MpPreference -ScanAvgCPULoadFactor 50                   # 50% CPU (default)
Set-MpPreference -DisableArchiveScanning $false
Set-MpPreference -DisableRemovableDriveScanning $true       # Default is disabled
Set-MpPreference -DisableEmailScanning $true                # Default is disabled

# Reset real-time protection settings
Write-Host "Resetting real-time protection..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableIOAVProtection $false              # Downloads/attachments scanning
Set-MpPreference -DisableScriptScanning $false

# Reset cloud protection settings
Write-Host "Resetting cloud protection..." -ForegroundColor Yellow
Set-MpPreference -MAPSReporting 2                           # Advanced (default)
Set-MpPreference -SubmitSamplesConsent 1                    # Safe samples (default)
Set-MpPreference -DisableBlockAtFirstSeen $false

# Reset threat actions to defaults (Quarantine is the default for all threat levels)
Write-Host "Resetting threat actions..." -ForegroundColor Yellow
Set-MpPreference -LowThreatDefaultAction Quarantine
Set-MpPreference -ModerateThreatDefaultAction Quarantine
Set-MpPreference -HighThreatDefaultAction Quarantine
Set-MpPreference -SevereThreatDefaultAction Quarantine

# Reset network protection
Write-Host "Resetting network protection..." -ForegroundColor Yellow
Set-MpPreference -EnableNetworkProtection 0                 # 0 = Disabled (default)

# Reset PUA protection
Write-Host "Resetting PUA protection..." -ForegroundColor Yellow
Set-MpPreference -PUAProtection 0                           # 0 = Disabled (default)

# Reset Exploit Protection to system defaults
Write-Host "Resetting Exploit Protection..." -ForegroundColor Yellow
Set-ProcessMitigation -System -Reset

# Update signatures
Write-Host "Updating virus definitions..." -ForegroundColor Yellow
Update-MpSignature

Write-Host "`nMicrosoft Defender has been reset to defaults." -ForegroundColor Green
Write-Host "A restart may be required for all changes to take effect." -ForegroundColor Cyan
