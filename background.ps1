# 1. Disable global background app permissions for the current user
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
$Name = "GlobalUserDisabled"
$Value = 1

if (-not (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force | Out-Null

# 2. Force background permission to "Never" for all modern (UWP) packages
$AppRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\JumplistData"
# This clears out the 'recently used' triggers that can wake apps up
Remove-ItemProperty -Path $AppRegistryPath -Name "*" -ErrorAction SilentlyContinue

# 3. Apply the "LetAppsRunInBackground" policy to the local machine
$PolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
if (-not (Test-Path $PolicyPath)) {
    New-Item -Path $PolicyPath -Force | Out-Null
}

# Value 2 = Force Deny
New-ItemProperty -Path $PolicyPath -Name "LetAppsRunInBackground" -Value 2 -PropertyType DWORD -Force | Out-Null

Write-Host "Background permissions have been disabled for all apps." -ForegroundColor Cyan
Write-Host "Please restart your computer for changes to take full effect." -ForegroundColor Yellow

Write-Host "Process complete." -ForegroundColor Cyan