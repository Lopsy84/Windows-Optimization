handle -a -p wudfhost | Select-String "Enum" | ForEach-Object {
    $_.Line -replace '.*\\Enum\\', '' -replace '\\Device Parameters.*', ''
} | Sort-Object -Unique | ForEach-Object {
    
    $Deviceid = $_
    
    if ([string]::IsNullOrWhiteSpace($Deviceid)) { return }

    $device = Get-PnpDevice -InstanceId $Deviceid -ErrorAction SilentlyContinue
    
    $name = if ($device.FriendlyName) { $device.FriendlyName } else { "Unknown Device ($Deviceid)" }
    
    $response = Read-Host "Are you sure you want to disable device '$name'? (Y/N)"
    
    if ($response -match '^[yY]') {
        Write-Host "Disabling $Deviceid..." -ForegroundColor Yellow
        pnputil.exe /disable-device $Deviceid /force
        taskkill /F /IM WUDFHost.exe
        Write-Host "Done." -ForegroundColor Green
    } else {
        Write-Host "Skipping $Deviceid..." -ForegroundColor Cyan
    }
}
Start-Sleep -Seconds 2
Write-Host "Disabled Drivers:"
Get-PnpDevice | Where-Object { $_.ConfigManagerErrorCode -eq 22 }
Get-PnpDevice | Where-Object { $_.ConfigManagerErrorCode -eq 22 } | Enable-PnpDevice
