param(
    [Parameter(Mandatory=$true)]
    [string]$TargetFolder,

    [Parameter(Mandatory=$false)]
    [string]$Episode = "01",

    [Parameter(Mandatory=$false)]
    [ValidateSet("A", "B", "D", "Stills")]
    [string]$Camera = "A",

    [Parameter(Mandatory=$false)]
    [string]$Act = "ACT1_ColdOpen",

    [Parameter(Mandatory=$false)]
    [string]$ShotType = "TRACK",

    [switch]$DryRun
)

if (-not (Test-Path $TargetFolder)) {
    Write-Warning "Directory not found: $TargetFolder"
    exit
}

# Supported camera video and still extensions
$mediaExtensions = @(".mp4", ".mov", ".mkv", ".m4v", ".raw", ".dng", ".arw", ".cr3", ".jpg", ".png")

$files = Get-ChildItem -Path $TargetFolder -File | Where-Object { 
    $mediaExtensions -contains $_.Extension.ToLower() 
} | Sort-Object CreationTime, LastWriteTime

if ($files.Count -eq 0) {
    Write-Host "No media files found in $TargetFolder." -ForegroundColor Yellow
    exit
}

Write-Host "`nFound $($files.Count) media files in: $TargetFolder" -ForegroundColor Cyan
Write-Host "Prefix Target: SCP_EP$($Episode.PadLeft(2, '0'))_${Camera}_${Act}_${ShotType}_[Index]`n" -ForegroundColor DarkGray

$plan = @()
$counter = 1

foreach ($file in $files) {
    $paddedIndex = $counter.ToString("00")
    $ext = $file.Extension.ToLower()
    $newName = "SCP_EP$($Episode.PadLeft(2, '0'))_${Camera}_${Act}_${ShotType}_${paddedIndex}${ext}"
    
    $plan += [PSCustomObject]@{
        Index       = $paddedIndex
        Original    = $file.Name
        NewName     = $newName
        FullPath    = $file.FullName
        Destination = Join-Path $file.DirectoryName $newName
    }
    $counter++
}

# Display transformation preview table
$plan | Select-Object Original, NewName | Format-Table -AutoSize

if ($DryRun) {
    Write-Host "Dry-run complete. No files were renamed.`n" -ForegroundColor Yellow
    exit
}

$confirm = Read-Host "Proceed with renaming these $($files.Count) files? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Operation cancelled. No files renamed.`n" -ForegroundColor DarkGray
    exit
}

foreach ($item in $plan) {
    Rename-Item -Path $item.FullPath -NewName $item.NewName -ErrorAction Stop
}

Write-Host "`nSuccessfully renamed $($plan.Count) files to project standard!`n" -ForegroundColor Green