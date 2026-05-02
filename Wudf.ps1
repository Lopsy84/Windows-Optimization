if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run PowerShell as an Administrator."
    Break
}

Get-PnpDevice | Where-Object { $_.Status -eq 'Error' -or $_.ConfigManagerErrorCode -eq 22 } | Select-Object FriendlyName, InstanceId, Status

Write-Host "Scanning WUDFHost processes..." -ForegroundColor Cyan

$wudfProcesses = Get-Process -Name "WUDFHost" -ErrorAction SilentlyContinue

if (-not $wudfProcesses) {
    Write-Host "No WUDFHost processes are currently running." -ForegroundColor Yellow
    exit
}

$results = @()

foreach ($proc in $wudfProcesses) {
    try {
        $driverModules = $proc.Modules | Where-Object {
            $_.FileName -match "DriverStore\\FileRepository"
        }

        foreach ($mod in $driverModules) {
            if ($mod.FileName -match "FileRepository\\([^\\]+)") {
                $infFolder = $matches[1]

                # Try to extract actual INF file name
                $infName = ($infFolder -split ".inf_")[0]

                $results += [PSCustomObject]@{
                    ProcessId = $proc.Id
                    InfFile   = $infName
                }

            }
        }
    } catch {
        Write-Warning "Access denied inspecting PID $($proc.Id)"
    }
    $Deviceid = Get-PnpDevice | Where-Object { $_.Service -like $infName } | Select-Object InstanceId
    $Deviceid= ($Deviceid -split "=")[1]
    $Deviceid= ($Deviceid -split "}")[0]
    pnputil.exe /disable-device $Deviceid /force

}
if ($results.Count -eq 0) {
    Write-Host "No INF files found."
    exit
}
