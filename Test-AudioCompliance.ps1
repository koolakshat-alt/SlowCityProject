param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath,

    [string]$Filter = "*.*",

    [double]$TargetLUFS = -14.0,
    [double]$TargetMaxPeak = -1.0
)

# 1. Dependency Check: ffmpeg
$hasFFmpeg = Get-Command "ffmpeg" -ErrorAction SilentlyContinue

if (-not $hasFFmpeg) {
    Write-Warning "FFmpeg is not detected in your PATH."
    Write-Host "Install via winget: 'winget install Gyan.FFmpeg' to run live EBU/LUFS analysis." -ForegroundColor Yellow
    Write-Host "Falling back to basic file structure and extension checks...`n" -ForegroundColor DarkGray
}

# 2. Resolve Target Files
if (Test-Path $TargetPath -PathType Container) {
    $audioFiles = Get-ChildItem -Path $TargetPath -Recurse -Filter $Filter -File | Where-Object {
        @(".wav", ".mp3", ".flac", ".m4a", ".aac") -contains $_.Extension.ToLower()
    }
} elseif (Test-Path $TargetPath -PathType Leaf) {
    $audioFiles = @(Get-Item -Path $TargetPath)
} else {
    Write-Error "Target path not found: $TargetPath"
    exit
}

if ($audioFiles.Count -eq 0) {
    Write-Warning "No audio matching '$Filter' found in $TargetPath."
    exit
}

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "             AUDIO EBU / LOUDNESS COMPLIANCE SCAN              " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Path:     $TargetPath" -ForegroundColor DarkGray
Write-Host "Filter:   $Filter" -ForegroundColor DarkGray
Write-Host "Standard: YouTube/Streaming ($TargetLUFS LUFS, Max True Peak: $TargetMaxPeak dBTP)`n" -ForegroundColor DarkGray

$results = @()

foreach ($file in $audioFiles) {
    $fileName   = $file.Name
    $fileSizeMB = [math]::Round($file.Length / 1MB, 2)
    $ext        = $file.Extension.ToUpper()

    if ($hasFFmpeg) {
        $cmd = "ffmpeg -nostats -i `"$($file.FullName)`" -filter_complex ebur128=peak=true -f null - 2>&1"
        $output = Invoke-Expression $cmd

        $lufsMatch = ($output | Select-String -Pattern 'I:\s+(-?\d+\.?\d*)\s+LUFS')
        $peakMatch = ($output | Select-String -Pattern 'Peak:\s+(-?\d+\.?\d*)\s+dBFS')

        $integratedLUFS = if ($lufsMatch) { [double]$lufsMatch.Matches[0].Groups[1].Value } else { $null }
        $truePeak       = if ($peakMatch) { [double]$peakMatch.Matches[0].Groups[1].Value } else { $null }

        $isCompliant = $true
        $notes = @()

        if ($null -ne $integratedLUFS) {
            $diff = [math]::Abs($integratedLUFS - $TargetLUFS)
            if ($diff -gt 2.0) {
                $isCompliant = $false
                if ($integratedLUFS -gt $TargetLUFS) { $notes += "Too Loud" } else { $notes += "Too Quiet" }
            }
        }

        if ($null -ne $truePeak -and $truePeak -gt $TargetMaxPeak) {
            $isCompliant = $false
            $notes += "Clipping Risk (> $TargetMaxPeak dBTP)"
        }

        $statusStr = if ($isCompliant) { "PASS" } else { "CHECK" }

        $results += [PSCustomObject]@{
            "File"       = $fileName
            "Format"     = $ext
            "Size (MB)"  = $fileSizeMB
            "LUFS"       = if ($null -ne $integratedLUFS) { "$integratedLUFS" } else { "N/A" }
            "True Peak"  = if ($null -ne $truePeak) { "$truePeak dB" } else { "N/A" }
            "Status"     = $statusStr
            "Notes"      = if ($notes.Count -gt 0) { $notes -join ", " } else { "Within Spec" }
        }
    } else {
        $isWav = $ext -eq ".WAV"
        $results += [PSCustomObject]@{
            "File"       = $fileName
            "Format"     = $ext
            "Size (MB)"  = $fileSizeMB
            "LUFS"       = "N/A (No ffmpeg)"
            "True Peak"  = "N/A"
            "Status"     = if ($isWav) { "READY" } else { "COMPRESSED" }
            "Notes"      = if ($isWav) { "Uncompressed WAV" } else { "Compressed audio format" }
        }
    }
}

$results | Format-Table -AutoSize
Write-Host "===============================================================" -ForegroundColor Cyan