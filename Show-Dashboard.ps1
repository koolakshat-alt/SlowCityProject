Clear-Host

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "             THE SLOW CITY PROJECT - DASHBOARD                 " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor DarkGray

# 1. Project Directory Verification
$episodes = Get-ChildItem -Directory -Filter "Episode_*" | Sort-Object Name

if ($episodes.Count -eq 0) {
    Write-Host "No episode directories detected in $(Get-Location)." -ForegroundColor Yellow
} else {
    Write-Host "--- Episode Pipelines ---" -ForegroundColor Yellow
    $dashboardData = @()

    foreach ($ep in $episodes) {
        $footage = (Get-ChildItem -Path "$($ep.FullName)\02_Footage" -Recurse -File -ErrorAction SilentlyContinue).Count
        $audio   = (Get-ChildItem -Path "$($ep.FullName)\03_Audio" -Recurse -File -ErrorAction SilentlyContinue).Count
        $assets  = (Get-ChildItem -Path "$($ep.FullName)\04_Assets" -Recurse -File -ErrorAction SilentlyContinue).Count
        $renders = (Get-ChildItem -Path "$($ep.FullName)\05_Renders_Review" -Recurse -File -ErrorAction SilentlyContinue).Count
        
        $status = if ($renders -gt 0) { "Render Review" }
                  elseif ($footage -gt 0 -or $audio -gt 0) { "In Production" }
                  else { "Scaffolded / Empty" }

        $dashboardData += [PSCustomObject]@{
            "Episode"   = $ep.Name
            "Status"    = $status
            "Footage"   = $footage
            "Audio"     = $audio
            "Assets"    = $assets
            "Renders"   = $renders
        }
    }

    $dashboardData | Format-Table -AutoSize
}

# 2. Local Avatar Assets Summary
$desktopPath = [Environment]::GetFolderPath('Desktop')
$avatarDir = if (Test-Path "$desktopPath\Akshat's Avatar") { "$desktopPath\Akshat's Avatar" } else { "$desktopPath\Akshats Avatar" }

Write-Host "--- Local Avatar Directory ---" -ForegroundColor Yellow
if (Test-Path $avatarDir) {
    $avatarFiles = Get-ChildItem -Path $avatarDir -Recurse -File -ErrorAction SilentlyContinue
    $totalAvatarMB = [math]::Round((($avatarFiles | Measure-Object -Property Length -Sum).Sum / 1MB), 2)
    Write-Host "Path:   $avatarDir" -ForegroundColor DarkGray
    Write-Host "Files:  $($avatarFiles.Count) files ($totalAvatarMB MB)" -ForegroundColor Green
} else {
    Write-Host "Avatar folder not located on Desktop." -ForegroundColor DarkGray
}

# 3. Git Status Summary
Write-Host "`n--- Git Working Tree ---" -ForegroundColor Yellow
$gitBranch = git branch --show-current 2>$null
$gitStatus = git status --short 2>$null

if ($gitBranch) {
    Write-Host "Active Branch: $gitBranch" -ForegroundColor DarkGray
    if ($gitStatus) {
        Write-Host "Uncommitted changes present ($($gitStatus.Count) items modified/untracked)." -ForegroundColor Yellow
    } else {
        Write-Host "Working tree clean. All scripts and tracked files synchronized." -ForegroundColor Green
    }
} else {
    Write-Host "Not inside an initialized Git repository." -ForegroundColor DarkGray
}

Write-Host "`n===============================================================" -ForegroundColor Cyan