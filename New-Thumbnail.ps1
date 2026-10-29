param(
    [Parameter(Mandatory=$true)]
    [string]$ImagePath,

    [Parameter(Mandatory=$false)]
    [string]$EpisodeTag = "EPISODE 01",

    [Parameter(Mandatory=$false)]
    [string]$Title = "SLOW HERITAGE",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "Episode_01\04_Assets\Graphics_Titles\Thumbnail_Final.jpg"
)

Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $ImagePath)) {
    Write-Warning "Source image not found: $ImagePath"
    exit
}

$targetDir = Split-Path $OutputPath -Parent
if ($targetDir -and (-not (Test-Path $targetDir))) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "`nGenerating 1080p YouTube thumbnail layout..." -ForegroundColor Cyan

$canvasWidth = 1920
$canvasHeight = 1080

$bitmap = New-Object System.Drawing.Bitmap $canvasWidth, $canvasHeight
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$srcImage = [System.Drawing.Image]::FromFile((Convert-Path $ImagePath))
$scale = [Math]::Max($canvasWidth / $srcImage.Width, $canvasHeight / $srcImage.Height)
$scaledWidth = [int]($srcImage.Width * $scale)
$scaledHeight = [int]($srcImage.Height * $scale)
$xOffset = [int](($canvasWidth - $scaledWidth) / 2)
$yOffset = [int](($canvasHeight - $scaledHeight) / 2)

$graphics.DrawImage($srcImage, $xOffset, $yOffset, $scaledWidth, $scaledHeight)
$srcImage.Dispose()

$rect = New-Object System.Drawing.Rectangle 0, 0, $canvasWidth, $canvasHeight
$gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point 0, 0),
    (New-Object System.Drawing.Point 0, $canvasHeight),
    [System.Drawing.Color]::FromArgb(40, 0, 0, 0),
    [System.Drawing.Color]::FromArgb(210, 10, 10, 10)
)
$graphics.FillRectangle($gradientBrush, $rect)
$gradientBrush.Dispose()

$fontFamily = New-Object System.Drawing.FontFamily "Arial"
$tagFont = New-Object System.Drawing.Font $fontFamily, 32, [System.Drawing.FontStyle]::Bold
$titleFont = New-Object System.Drawing.Font $fontFamily, 72, [System.Drawing.FontStyle]::Bold
$subFont = New-Object System.Drawing.Font $fontFamily, 26, [System.Drawing.FontStyle]::Regular

$textBrushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$textBrushYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 190, 50))
$shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 0, 0, 0))

$startX = 120
$startY = 730

$graphics.DrawString("THE SLOW CITY PROJECT", $subFont, $textBrushWhite, $startX, ($startY - 80))
$graphics.DrawString($EpisodeTag.ToUpper(), $tagFont, $textBrushYellow, $startX, $startY)
$graphics.DrawString($Title.ToUpper(), $titleFont, $shadowBrush, ($startX + 4), ($startY + 54))
$graphics.DrawString($Title.ToUpper(), $titleFont, $textBrushWhite, $startX, ($startY + 50))

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 92L)

$bitmap.Save((Join-Path (Get-Location).Path $OutputPath), $codec, $encoderParams)

$graphics.Dispose()
$bitmap.Dispose()
$encoderParams.Dispose()

Write-Host "Thumbnail generated successfully at: $OutputPath`n" -ForegroundColor Green