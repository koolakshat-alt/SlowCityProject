param(
    [switch]$Force
)

Write-Host "`n--- SCANNING FOR RENDER CACHE & SCRATCH FILES ---`n" -ForegroundColor Cyan

# Common NLE cache, peak, scratch, and temp render extensions/patterns
$cachePatterns = @(
    "*.pek",        # Premiere peak files
    "*.cfa",        # Premiere conform audio
    "*.ims",        # Adobe media indexer
    "*.prv",        # Preview files
    "*.tmp",        # Windows/NLE temp files
    "*.dvd",        # DaVinci optimized media markers
    "*Render Files*", # FCP / Premiere scratch folders
    "*CacheClip*"     # DaVinci Resolve render cache folders
)

$targetEpisodes = Get-ChildItem -Directory -Filter "Episode_*"

$itemsToDelete = @()

foreach ($ep in $targetEpisodes) {
    foreach ($pattern in $cachePatterns) {
        $found = Get-ChildItem -Path $ep.FullName -Recurse -Include $pattern -Force -ErrorAction SilentlyContinue
        if ($found) {
            $itemsToDelete += $found
        }
    }
}

if ($itemsToDelete.Count -eq 0) {
    Write-Host "No temporary cache or scratch files detected. Workspaces are clean!`n" -ForegroundColor Green
    exit
}

# Display detected items
$summary = $itemsToDelete | Select-Object Name, @{Name="Type"; Expression={if ($_.PSIsContainer) { "Directory" } else { "File" }}}, @{Name="Size (MB)"; Expression={if (-not $_.PSIsContainer) { [math]::Round($_.Length / 1MB, 2) } else { "-" }}}, FullName
$summary | Format-Table -AutoSize

$totalSize = ($itemsToDelete | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum
$totalMB = if ($totalSize) { [math]::Round($totalSize / 1MB, 2) } else { 0 }

Write-Host "Total reclaimable cache space: $totalMB MB" -ForegroundColor Yellow

if (-not $Force) {
    $confirm = Read-Host "`nDo you want to permanently delete these cache files? (y/n)"
    if ($confirm -ne 'y') {
        Write-Host "Operation cancelled. No files were removed." -ForegroundColor DarkGray
        exit
    }
}

foreach ($item in $itemsToDelete) {
    Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`nSuccessfully cleared cache and scratch files!" -ForegroundColor Green
