param(
    [Parameter(Mandatory=$false)]
    [int]$Episode = 1
)

$epFolder = "Episode_{0:D2}" -f $Episode
$epPath = Join-Path $PSScriptRoot $epFolder

if (-not (Test-Path $epPath)) {
    Write-Warning "Directory not found: $epPath"
    exit
}

Write-Host "`nScanning assets for $epFolder...`n" -ForegroundColor Cyan

# Gather all directories inside the episode folder
$dirs = Get-ChildItem -Path $epPath -Recurse -Directory

$report = foreach ($dir in $dirs) {
    # Count files excluding .gitkeep
    $files = Get-ChildItem -Path $dir.FullName -File | Where-Object { $_.Name -ne ".gitkeep" }
    $fileCount = ($files | Measure-Object).Count
    
    # Calculate folder size
    $totalBytes = ($files | Measure-Object -Property Length -Sum).Sum
    $sizeMB = if ($totalBytes) { [math]::Round($totalBytes / 1MB, 2) } else { 0 }

    # Relative path display
    $relPath = $dir.FullName.Substring($epPath.Length + 1)

    [PSCustomObject]@{
        Subfolder = $relPath
        Files     = $fileCount
        "Size (MB)" = $sizeMB
        Status    = if ($fileCount -gt 0) { "🟢 Ingested" } else { "⚪ Empty" }
    }
}

$report | Format-Table -AutoSize

$totalAssets = ($report | Measure-Object -Property Files -Sum).Sum
$totalSize = [math]::Round(($report | Measure-Object -Property "Size (MB)" -Sum).Sum, 2)

Write-Host "Total Files (excl. .gitkeep): $totalAssets" -ForegroundColor Yellow
Write-Host "Total Size: $totalSize MB`n" -ForegroundColor Yellow
