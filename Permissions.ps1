# Define the ACE to add (Full Control for Built-in Administrators)
$NewAce = "(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)"

# Get all service names
$Services = Get-Service | Select-Object -ExpandProperty Name

Write-Host "Starting permission update on $($Services.Count) services (Filtering Protected)..." -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------"

foreach ($ServiceName in $Services) {
    try {
        # 2. Fetch current SDDL
        $CurrentSDDL = sc.exe sdshow $ServiceName | Select-Object -Last 1
        
        # 3. Skip if SDDL is inaccessible or already contains the ACE
        if ($null -eq $CurrentSDDL -or $CurrentSDDL -match "Error") {
            Write-Warning "[!] Skipping ${ServiceName}: Access Denied or Service not found."
            continue
        }

        if ($CurrentSDDL.Contains($NewAce)) {
            Write-Host "[~] Skipping ${ServiceName}: ACE already present." -ForegroundColor DarkGray
            continue
        }

        # 4. Inject the NewAce after the 'D:' prefix
        if ($CurrentSDDL -match '^D:') {
            $UpdatedSDDL = $CurrentSDDL -replace '^D:', "D:$NewAce"
            
            # 5. Apply the updated SDDL
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

Write-Host "----------------------------------------------------------------"


#Safe to disable wuauserv,FontCache,NPSMSvc,Wersvc