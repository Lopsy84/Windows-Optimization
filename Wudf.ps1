# Requires "Run as Administrator" to read process modules
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run PowerShell as an Administrator to see process modules."
    Break
}

Write-Host "Scanning active WUDFHost processes for loaded user-mode drivers..." -ForegroundColor Cyan

# Get all running instances of WUDFHost
$wudfProcesses = Get-Process -Name "WUDFHost" -ErrorAction SilentlyContinue

if (-not $wudfProcesses) {
    Write-Host "No WUDFHost processes are currently running." -ForegroundColor Yellow
    exit
}

$results = @()

foreach ($proc in $wudfProcesses) {
    try {
        # Filter loaded modules for paths typical of User-Mode drivers
        $driverModules = $proc.Modules | Where-Object {
            $_.FileName -match "System32\\drivers\\UMDF" -or
            $_.FileName -match "System32\\DriverStore\\FileRepository"
        }

        if ($driverModules) {
            foreach ($mod in $driverModules) {
                $results += [PSCustomObject]@{
                    ProcessId       = $proc.Id
                    DriverName      = $mod.ModuleName
                    FileDescription = $mod.FileVersionInfo.FileDescription
                    Company         = $mod.FileVersionInfo.CompanyName
                    FilePath        = $mod.FileName
                }
            }
        } else {
             $results += [PSCustomObject]@{
                ProcessId       = $proc.Id
                DriverName      = "[Unknown or System Core]"
                FileDescription = "N/A"
                Company         = "N/A"
                FilePath        = "No UMDF/DriverStore modules detected in this instance"
            }
        }
    } catch {
        Write-Warning "Access denied inspecting PID $($proc.Id). Are you running as Admin?"
    }
}

# Display results cleanly
if ($results.Count -gt 0) {
    $results | Sort-Object ProcessId | Format-Table -AutoSize
} else {
    Write-Host "Could not map any specific drivers to the running WUDFHost processes."
}