# Generates the Apex GP launcher icons (Android mipmaps + web icons)
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
function Draw-Icon([int]$size, [string]$path) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
    $rect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.Color]::FromArgb(255,10,16,30)), ([System.Drawing.Color]::FromArgb(255,28,8,14)), 45.0
    $g.FillRectangle($bg, $rect)
    # red speed stripes
    $red = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255,255,59,48))
    $s = $size / 100.0
    $pts = @((New-Object System.Drawing.PointF (18*$s),(78*$s)), (New-Object System.Drawing.PointF (92*$s),(78*$s)), (New-Object System.Drawing.PointF (86*$s),(86*$s)), (New-Object System.Drawing.PointF (12*$s),(86*$s)))
    $g.FillPolygon($red, $pts)
    $font = New-Object System.Drawing.Font 'Arial Black', ([float](38*$s)), ([System.Drawing.FontStyle]::Italic), ([System.Drawing.GraphicsUnit]::Pixel)
    $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
    $g.DrawString('GP', $font, $white, (New-Object System.Drawing.RectangleF 0, (8*$s), $size, (62*$s)), $fmt)
    $g.Dispose(); $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}
$dens = @{ 'mdpi'=48; 'hdpi'=72; 'xhdpi'=96; 'xxhdpi'=144; 'xxxhdpi'=192 }
foreach ($d in $dens.Keys) {
    $dir = Join-Path $PSScriptRoot "res\mipmap-$d"; New-Item -ItemType Directory -Force $dir | Out-Null
    Draw-Icon $dens[$d] (Join-Path $dir 'ic_launcher.png')
}
Draw-Icon 192 (Join-Path $root 'icon-192.png')
Draw-Icon 512 (Join-Path $root 'icon-512.png')
'icons done'
