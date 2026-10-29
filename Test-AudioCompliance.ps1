param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [double]$TargetLUFS = -14.0,
    [double]$TargetMaxPeak = -1.0
)

# Verify FFmpeg is installed
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Error "FFmpeg is not installed or not in PATH. Please install FFmpeg (e.g., via 'winget install Gyan.FFmpeg')."
    exit
}

if (-not (Test-Path $FilePath)) {
    Write-Warning "File not found: $FilePath"
    exit
}

Write-Host "`nAnalyzing audio loudness for: $(Split-Path $FilePath -Leaf)..." -ForegroundColor Cyan
Write-Host "Standards Target: Integrated Loudness = $TargetLUFS LUFS | True Peak <= $TargetMaxPeak dBTP`n" -ForegroundColor DarkGray

# Run ffmpeg ebur128 dual-pass analysis filter
$ffmpegCmd = "ffmpeg -nostats -i `"$FilePath`" -filter_complex ebur128=peak=true -f null - 2>&1"
$output = Invoke-Expression $ffmpegCmd

# Parse output lines
$summarySection = $false
$integratedLoudness = $null
$truePeak = $null
$loudnessRange = $null

foreach ($line in $output) {
    if ($line -match "Summary:") { $summarySection = $true }
    if ($summarySection) {
        if ($line -match "I:\s+(-?[\d\.]+)\s+LUFS") { $integratedLoudness = [double]$matches[1] }
        if ($line -match "Peak:\s+(-?[\d\.]+)\s+dBTP") { $truePeak = [double]$matches[1] }
        if ($line -match "LRA:\s+([\d\.]+)\s+LU") { $loudnessRange = [double]$matches[1] }
    }
}

if ($null -eq $integratedLoudness -or $null -eq $truePeak) {
    Write-Warning "Could not extract complete loudness parameters. Verify the audio stream is valid."
    exit
}

# Evaluate compliance
$lufsDiff = [math]::Round($integratedLoudness - $TargetLUFS, 2)
$lufsStatus = if ([math]::Abs($integratedLoudness - $TargetLUFS) -le 1.0) { "🟢 Optimal" } elseif ($integratedLoudness -gt $TargetLUFS) { "🔴 Too Loud (YouTube will attenuate)" } else { "🟡 Quiet (YouTube will not boost)" }
$peakStatus = if ($truePeak -le $TargetMaxPeak) { "🟢 Pass (No inter-sample clipping)" } else { "🔴 Fail (Risk of clipping on lossy transcode)" }

[PSCustomObject]@{
    "Integrated Loudness" = "$integratedLoudness LUFS"
    "Target Offset"       = "$lufsDiff dB"
    "Loudness Status"     = $lufsStatus
    "True Peak"           = "$truePeak dBTP"
    "True Peak Status"    = $peakStatus
    "Loudness Range (LRA)" = "$loudnessRange LU"
} | Format-List

if ($integratedLoudness -gt $TargetLUFS -or $truePeak -gt $TargetMaxPeak) {
    Write-Host "Recommendation: Apply a True Peak Limiter with ceiling at $TargetMaxPeak dBTP and adjust master gain by $($lufsDiff * -1) dB.`n" -ForegroundColor Yellow
} else {
    Write-Host "Audio is within broadcast tolerances for YouTube delivery!`n" -ForegroundColor Green
}
