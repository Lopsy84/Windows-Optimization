$ErrorActionPreference = 'silentlycontinue'
$ConfirmPreference = "None"
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$null = $FileBrowser.ShowDialog() 
$KeepServices = @(
    "Audiosrv",                  # Windows Audio
    "Brokerinfrastructure",      # Background Tasks Infrastructure
    "SysMain",                   # Superfetch (App launch optimization)
    "GraphicsPerfSvc",           # Graphics Performance Monitor
    "CoreMessagingRegistrar",    # Core UI Messaging
    "DcomLaunch",                # DCOM Service Launcher (Critical)
    "Dhcp",                      # DHCP Client (IP Address assignment)
    "Dnscache",                  # DNS Caching (Web browsing)
    "LSM",                       # Local Session Manager
    "netprofm",                  # Network List Service
    "nsi",                       # Network Store Interface
    "Power",                     # Power Policy Management
    "RpcEptMapper",              # RPC Endpoint Mapper
    "RpcSs",                     # Remote Procedure Call
    "SamSs",                     # Security Accounts Manager
    "TextInputManagementService",# Keyboard/Emoji/IME Input
    "Wcmsvc",                    # Windows Connection Manager
    "WlanSvc"                   # Wi-Fi AutoConfig
    "EventSystem"
)

1..5 | ForEach-Object {
    taskkill /F /IM explorer.exe 2>$null
    Get-Service | Where-Object { 
        $name = $_.Name.Trim()
        $KeepServices -notcontains $name -and $_.Status -eq 'Running' 
    } | Stop-Service
    Start-Sleep -Seconds 5
}
    taskkill /F /FI "SERVICES eq BFE" 2>$null
    taskkill /F /FI "SERVICES eq mpssvc" 2>$null
    taskkill /F /FI "SERVICES eq WinHttpAutoProxySvc" 2>$null
    taskkill /F /IM fontdrvhost.exe 2>$null
    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Get-Process -IncludeUserName | Where-Object {
        $_.UserName -eq $user -and $_.Id -ne $PID
    } | Stop-Process
    Get-Service -name EventSystem | Stop-Service
if ($FileBrowser.FileName) {
    Invoke-Item $FileBrowser.FileName
    Start-Process sndvol
}
