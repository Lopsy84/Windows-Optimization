handle -a -p wudfhost | Select-String "Enum" | ForEach-Object {
    $Deviceid = $_.Line -replace '.*\\Enum\\', '' -replace '\\Device Parameters.*', ''
    $name = (Get-PnpDevice -DeviceId $Deviceid).Friendlyname
    $response = Read-Host "Are you sure you want to disable device '$name'? (Y/N)"
        if ($response -match '^[yY]') {
        Write-Host "Disabling $Deviceid..." -ForegroundColor Yellow
        pnputil.exe /disable-device $Deviceid /force
        Write-Host "Done." -ForegroundColor Green
    } else {
        Write-Host "Skipping $Deviceid..." -ForegroundColor Cyan
    }
}
Write-Host "Disabled Drivers:"
Get-PnpDevice | Where-Object { $_.ConfigManagerErrorCode -eq 22 }
Get-PnpDevice | Where-Object { $_.ConfigManagerErrorCode -eq 22 } | Enable-PnpDevice
