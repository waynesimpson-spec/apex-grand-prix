# Builds C:\Game\ApexGP.apk from index.html without Gradle (aapt2 -> javac -> d8 -> zipalign -> apksigner).
# Re-run this any time you change the game to get a fresh APK.
$ErrorActionPreference = 'Stop'
$B    = 'C:\Users\aaron\ApexGP-build'          # tools folder (JDK, Android SDK, three.js)
$SDK  = "$B\sdk"; $BT = "$SDK\build-tools\34.0.0"; $JAR = "$SDK\platforms\android-34\android.jar"
$env:JAVA_HOME = "$B\jdk"; $env:Path = "$B\jdk\bin;$env:Path"
$P    = $PSScriptRoot; $Game = Split-Path $P -Parent; $W = "$P\build"
function Run($exe, [string[]]$a) { & $exe @a; if ($LASTEXITCODE -ne 0) { throw "$exe failed ($LASTEXITCODE)" } }

if (Test-Path $W) { Remove-Item $W -Recurse -Force -Confirm:$false }
New-Item -ItemType Directory -Force "$W\assets","$W\gen","$W\classes","$W\dex" | Out-Null
if (-not (Test-Path "$P\res\mipmap-mdpi\ic_launcher.png")) { & "$P\make-icons.ps1" | Out-Null }

# 1. assets: the game, pointed at bundled three.js (offline) instead of the CDN
$html = [IO.File]::ReadAllText("$Game\index.html", [Text.Encoding]::UTF8)
# (assets are kept flat: aapt2 on Windows writes sub-folder paths with backslashes, which Android can't open)
$html = $html.Replace('"three":"https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js"', '"three":"./three.module.js"')
$html = $html.Replace('"three/addons/":"https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/"', '"three/addons/utils/BufferGeometryUtils.js":"./BufferGeometryUtils.js"')
if ($html.Contains('cdn.jsdelivr.net')) { throw 'import map rewrite failed' }
$html = [regex]::Replace($html, '<link rel="preconnect"[^>]*>\s*', '')
$html = [regex]::Replace($html, '<link href="https://fonts.googleapis.com[^>]*>\s*', '')
[IO.File]::WriteAllText("$W\assets\index.html", $html, (New-Object Text.UTF8Encoding($false)))
Copy-Item "$B\lib\three.module.js","$B\lib\addons\utils\BufferGeometryUtils.js" "$W\assets"
Copy-Item "$Game\manifest.json","$Game\icon-192.png","$Game\icon-512.png" "$W\assets" -ErrorAction SilentlyContinue

# 2. resources + manifest
Run "$BT\aapt2.exe" @('compile', '--dir', "$P\res", '-o', "$W\res.zip")
Run "$BT\aapt2.exe" @('link', '-o', "$W\base.apk", '-I', $JAR, '--manifest', "$P\AndroidManifest.xml", '-A', "$W\assets", '--java', "$W\gen", "$W\res.zip")

# 3. compile Java -> dex
$src = @("$P\src\com\apexgp\game\MainActivity.java") + (Get-ChildItem "$W\gen" -Recurse -Filter *.java | ForEach-Object FullName)
Run "$B\jdk\bin\javac.exe" (@('-nowarn', '-encoding', 'UTF-8', '--release', '8', '-classpath', $JAR, '-d', "$W\classes") + $src)
$classes = Get-ChildItem "$W\classes" -Recurse -Filter *.class | ForEach-Object FullName
Run "$BT\d8.bat" (@('--release', '--min-api', '24', '--lib', $JAR, '--output', "$W\dex") + $classes)

# 4. add classes.dex, align, sign
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::Open("$W\base.apk", 'Update')
[void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$W\dex\classes.dex", 'classes.dex')
$zip.Dispose()
Run "$BT\zipalign.exe" @('-p', '-f', '4', "$W\base.apk", "$W\aligned.apk")
$ks = "$P\apexgp.keystore"
if (-not (Test-Path $ks)) { Run "$B\jdk\bin\keytool.exe" @('-genkeypair', '-keystore', $ks, '-storepass', 'apexgp', '-keypass', 'apexgp', '-alias', 'apexgp', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000', '-dname', 'CN=Apex GP') }
Run "$BT\apksigner.bat" @('sign', '--ks', $ks, '--ks-pass', 'pass:apexgp', '--key-pass', 'pass:apexgp', '--out', "$Game\ApexGP.apk", "$W\aligned.apk")
Run "$BT\apksigner.bat" @('verify', "$Game\ApexGP.apk")
"Built $Game\ApexGP.apk  ($([math]::Round((Get-Item "$Game\ApexGP.apk").Length/1MB,2)) MB)"
