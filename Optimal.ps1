$ErrorActionPreference = 'silentlycontinue'
$ConfirmPreference = "None"
# Define the "Safe List" - No services in this list will be touched
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
    Taskkill /F /IM explorer.exe 2>$null
    Stop-Process -Name "Searchhost"
    taskkill /F /T /IM sihost.exe 2>$null       
    Get-Service | Where-Object { 
        $name = $_.Name.Trim()
        $KeepServices -notcontains $name -and $_.Status -eq 'Running' 
    } | Stop-Service
    Start-Sleep -Seconds 5
}
    taskkill /F /FI "SERVICES eq BFE" 2>$null
    taskkill /F /FI "SERVICES eq mpssvc" 2>$null
    taskkill /F /FI "SERVICES eq WinHttpAutoProxySvc" 2>$null
    taskkill /F /FI "SERVICES eq SecurityHealthService" 2>$null
    taskkill /F /IM fontdrvhost.exe 2>$null   
    Get-Service -name EventSystem | Stop-Service
sndvol

