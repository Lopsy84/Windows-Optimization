$NewAce = "(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)"

$Services = Get-Service | Select-Object -ExpandProperty Name

Write-Host "Starting permission update on $($Services.Count) services (Filtering Protected)..." -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------"

foreach ($ServiceName in $Services) {
    try {
        $CurrentSDDL = sc.exe sdshow $ServiceName | Select-Object -Last 1
        
        if ($null -eq $CurrentSDDL -or $CurrentSDDL -match "Error") {
            Write-Warning "[!] Skipping ${ServiceName}: Access Denied or Service not found."
            continue
        }

        if ($CurrentSDDL.Contains($NewAce)) {
            Write-Host "[~] Skipping ${ServiceName}: ACE already present." -ForegroundColor DarkGray
            continue
        }

        if ($CurrentSDDL -match '^D:') {
            $UpdatedSDDL = $CurrentSDDL -replace '^D:', "D:$NewAce"
            
            $Result = sc.exe sdset $ServiceName $UpdatedSDDL
            
            if ($Result -match "SUCCESS") {
                Write-Host "[+] Successfully updated: $ServiceName" -ForegroundColor Green
            } else {
                Write-Warning "[!] Failed to update ${ServiceName}: $Result"
            }
        }
    }
    catch {
        Write-Warning "[!] Error processing ${ServiceName}: $_"
    }
}

$services = Get-CimInstance -ClassName Win32_Service
foreach ($service in $services) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
    
    $regKey = Get-ItemProperty -Path $regPath -Name FailureActions -ErrorAction SilentlyContinue
    
    if ($regKey -and $regKey.FailureActions -and $regKey.FailureActions.Length -ge 20) {
        $bytes = $regKey.FailureActions
        
        $actionCount = [BitConverter]::ToInt32($bytes, 12)
        $hasReboot = $false
        
        for ($i = 0; $i -lt $actionCount; $i++) {
            $offset = 20 + ($i * 8)
            
            if (($offset + 4) -le $bytes.Length) {
                $actionType = [BitConverter]::ToInt32($bytes, $offset)
                
                if ($actionType -eq 2) {
                    $hasReboot = $true
                    break
                }
            }
        }
        
        if ($hasReboot) {
            sc.exe failure $Service.name reset= 86400 actions= restart/0/restart/0/restart/0
            Write-Host $service.name
        }
    }
}

reg add HKEY_LOCAL_MACHINE\System\ControlSet001\Control\FeatureManagement\Overrides\8\1387020943 /v EnabledStateOptions /t REG_DWORD /d 0
reg add HKEY_LOCAL_MACHINE\System\ControlSet001\Control\FeatureManagement\Overrides\8\1387020943 /v EnabledState /t REG_DWORD /d 1
reg add HKEY_LOCAL_MACHINE\System\ControlSet001\Control\FeatureManagement\Overrides\8\1387020943 /v Variant /t REG_DWORD /d 0
reg add HKEY_LOCAL_MACHINE\System\ControlSet001\Control\FeatureManagement\Overrides\8\1387020943 /v VariantPayload /t REG_DWORD /d 0
reg add HKEY_LOCAL_MACHINE\System\ControlSet001\Control\FeatureManagement\Overrides\8\1387020943 /v VariantPayloadKind /t REG_DWORD /d 0


#Safe to disable wuauserv,FontCache,NPSMSvc,Wersvc,winmgmt,DPS
