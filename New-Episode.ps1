param(
    [Parameter(Mandatory=$true)]
    [int]$Start,

    [Parameter(Mandatory=$false)]
    [int]$End = $Start
)

$subfolders = @(
    "01_Project_Files/Auto_Saves",
    "01_Project_Files/Master_Projects",
    "02_Footage/Cam_A",
    "02_Footage/Cam_B",
    "02_Footage/Drones_Gimbals",
    "02_Footage/Screen_Recordings",
    "03_Audio/Dialogue_VO",
    "03_Audio/Music",
    "03_Audio/SFX_Ambience",
    "04_Assets/Graphics_Titles",
    "04_Assets/AI_Generated",
    "04_Assets/Subtitles_Transcripts",
    "05_Exports/Rough_Cuts",
    "05_Exports/Review_Copies",
    "05_Exports/Final_Masters",
    "06_Docs_Reference/Script_Storyboards",
    "06_Docs_Reference/Licensing_Releases"
)

$templatePath = "_Production_Docs\EPISODE_TEMPLATE.md"

$Start..$End | ForEach-Object {
    $epName = "Episode_{0:D2}" -f $_
    Write-Host "Creating structure for $epName..." -ForegroundColor Cyan

    foreach ($sub in $subfolders) {
        $fullPath = Join-Path $epName $sub
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        New-Item -ItemType File -Path (Join-Path $fullPath ".gitkeep") -Force | Out-Null
    }

    # Copy and customize the metadata template if it exists
    if (Test-Path $templatePath) {
        $metaDest = Join-Path $epName "06_Docs_Reference\Script_Storyboards\$($epName)_Metadata.md"
        $content = Get-Content -Path $templatePath -Raw
        $customized = $content -replace "EP__", ("EP{0:D2}" -f $_)
        Set-Content -Path $metaDest -Value $customized -Encoding UTF8
        Write-Host "Injected metadata template: $metaDest" -ForegroundColor Green
    }
}

Write-Host "Done! Episode structure(s) generated." -ForegroundColor Green
