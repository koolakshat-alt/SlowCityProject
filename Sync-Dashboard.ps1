param(
    [Parameter(Mandatory=$false)]
    [string]$Note = "Update production dashboard milestones"
)

$dashboardFile = "_Production_Docs/PRODUCTION_DASHBOARD.md"

if (-not (Test-Path $dashboardFile)) {
    Write-Warning "Dashboard file not found at: $dashboardFile"
    exit
}

# Check if there are actual modifications
$gitDiff = git status --porcelain $dashboardFile

if (-not $gitDiff) {
    Write-Host "No changes detected in $dashboardFile. Repository is up to date." -ForegroundColor Yellow
    exit
}

Write-Host "Staging and committing dashboard updates..." -ForegroundColor Cyan

git add $dashboardFile
git commit -m "$Note"
git push

Write-Host "`nDashboard successfully synced to GitHub!" -ForegroundColor Green
