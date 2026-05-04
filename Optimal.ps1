$ErrorActionPreference = 'silentlycontinue'
# Define the "Safe List" - No services in this list will be touched
$KeepServices = @(
    "Audiosrv",                  # Windows Audio
    "Brokerinfrastructure",      # Background Tasks Infrastructure
    "SysMain",                   # Superfetch (App launch optimization)
    "GraphicsPerfSvc",           # Graphics Performance Monitor
    "BFE",                       # Base Filtering Engine (Firewall dependency)
    "CoreMessagingRegistrar",    # Core UI Messaging
    "DcomLaunch",                # DCOM Service Launcher (Critical)
    "Dhcp",                      # DHCP Client (IP Address assignment)
    "Dnscache",                  # DNS Caching (Web browsing)
    "EventSystem",               # COM+ Event System
    "LSM",                       # Local Session Manager
    "MDCoreSvc",                 # Microsoft Desktop Center Core
    "mpssvc",                    # Windows Firewall
    "netprofm",                  # Network List Service
    "nsi",                       # Network Store Interface
    "Power",                     # Power Policy Management
    "RpcEptMapper",              # RPC Endpoint Mapper
    "RpcSs",                     # Remote Procedure Call
    "SamSs",                     # Security Accounts Manager
    "TextInputManagementService",# Keyboard/Emoji/IME Input
    "Wcmsvc",                    # Windows Connection Manager
    "WinDefend",                 # Microsoft Defender Antivirus
    "WlanSvc"                   # Wi-Fi AutoConfig
)
1..5 | ForEach-Object {
    Taskkill /F /IM explorer.exe 2>$null
    Stop-Process -Name "Searchhost"
    taskkill /F /T /IM sihost.exe 2>$null      
    taskkill /F /IM fontdrvhost.exe 2>$null    
    Get-Service | Where-Object { 
        $name = $_.Name.Trim()
        $KeepServices -notcontains $name -and $_.Status -eq 'Running' 
    } | Stop-Service
    Start-Sleep -Seconds 5
}
sndvol
