Get-CimInstance -ClassName Win32_PnPEntity | Where-Object Service -eq "WUDFRd"
$response = Read-Host "Are you sure you want to disable the device ? (Y/N)"
    if ($response -match '^[yY]') {
        Write-Host "Disabling ..." -ForegroundColor Yellow
        pnputil.exe /disable-device (Get-CimInstance -ClassName Win32_PnPEntity | Where-Object Service -eq "WUDFRd").InstanceId /force
        Write-Host "Done." -ForegroundColor Green
    } else {
        Write-Host "Skipping ..." -ForegroundColor Cyan
    }
Get-PnpDevice -Status "OK" | ForEach-Object {
    $filters = Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName 'DEVPKEY_Device_UpperFilters','DEVPKEY_Device_LowerFilters' -ErrorAction SilentlyContinue
    if ($filters.Data -eq "WUDFRd") {
        [PSCustomObject]@{
            FriendlyName = $_.FriendlyName
            InstanceId   = $_.InstanceId
        }
    $response = Read-Host "Are you sure you want to disable the device ? (Y/N)"
    
    if ($response -match '^[yY]') {
        Write-Host "Disabling ..." -ForegroundColor Yellow
        pnputil.exe /disable-device $_.InstanceId  /force
        Write-Host "Done." -ForegroundColor Green
    } else {
        Write-Host "Skipping ..." -ForegroundColor Cyan
    }
    }
}
taskkill /F /IM WUDFHost.exe
Start-Sleep -Seconds 2
Write-Host "Disabled Drivers:"
Get-PnpDevice | Where-Object { $_.ConfigManagerErrorCode -eq 22 }
Get-PnpDevice | Where-Object { $_.ConfigManagerErrorCode -eq 22 } | Enable-PnpDevice
