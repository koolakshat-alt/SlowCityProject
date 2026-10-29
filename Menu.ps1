function Show-Menu {
    Clear-Host
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host "             THE SLOW CITY PROJECT - CLI MENU                  " -ForegroundColor Cyan
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host "  1. Show Project Dashboard           (Show-Dashboard.ps1)"
    Write-Host "  2. Scaffold New Episode             (New-Episode.ps1)"
    Write-Host "  3. Scan Episode Ingested Assets     (Test-EpisodeAssets.ps1)"
    Write-Host "  4. Check Audio EBU Compliance       (Test-AudioCompliance.ps1)"
    Write-Host "  5. Generate Thumbnail Template      (New-Thumbnail.ps1)"
    Write-Host "  6. Clear DaVinci / Render Cache     (Clear-RenderCache.ps1)"
    Write-Host "  7. Export Dashboard Status to JSON  (Export-Dashboard.ps1)"
    Write-Host "  8. Sync Dashboard to Cloud / Git    (Sync-Dashboard.ps1)"
    Write-Host "  9. Batch Rename Raw Camera Footage  (Rename-RawFootage.ps1)"
    Write-Host "  Q. Quit"
    Write-Host "===============================================================" -ForegroundColor Cyan
}

do {
    Show-Menu
    $selection = Read-Host "`nEnter option [1-9 or Q]"

    switch ($selection) {
        "1" {
            if (Test-Path ".\Show-Dashboard.ps1") { .\Show-Dashboard.ps1 } else { Write-Warning "Show-Dashboard.ps1 not found." }
            Pause
        }
        "2" {
            if (Test-Path ".\New-Episode.ps1") { .\New-Episode.ps1 } else { Write-Warning "New-Episode.ps1 not found." }
            Pause
        }
        "3" {
            if (Test-Path ".\Test-EpisodeAssets.ps1") { .\Test-EpisodeAssets.ps1 } else { Write-Warning "Test-EpisodeAssets.ps1 not found." }
            Pause
        }
        "4" {
            if (Test-Path ".\Test-AudioCompliance.ps1") {
                $audioPath = Read-Host "Enter path to audio file or directory to scan"
                $filter = Read-Host "Enter filter (e.g., *.wav, *.mp3) [Default: *.*]"
                if (-not $filter) { $filter = "*.*" }
                .\Test-AudioCompliance.ps1 -TargetPath $audioPath -Filter $filter
            } else {
                Write-Warning "Test-AudioCompliance.ps1 not found."
            }
            Pause
        }
        "5" {
            if (Test-Path ".\New-Thumbnail.ps1") { .\New-Thumbnail.ps1 } else { Write-Warning "New-Thumbnail.ps1 not found." }
            Pause
        }
        "6" {
            if (Test-Path ".\Clear-RenderCache.ps1") { .\Clear-RenderCache.ps1 } else { Write-Warning "Clear-RenderCache.ps1 not found." }
            Pause
        }
        "7" {
            if (Test-Path ".\Export-Dashboard.ps1") { .\Export-Dashboard.ps1 } else { Write-Warning "Export-Dashboard.ps1 not found." }
            Pause
        }
        "8" {
            if (Test-Path ".\Sync-Dashboard.ps1") { .\Sync-Dashboard.ps1 } else { Write-Warning "Sync-Dashboard.ps1 not found." }
            Pause
        }
        "9" {
            if (Test-Path ".\Rename-RawFootage.ps1") { .\Rename-RawFootage.ps1 } else { Write-Warning "Rename-RawFootage.ps1 not found." }
            Pause
        }
        "Q" {
            Write-Host "`nExiting Slow City Project CLI. Goodbye!`n" -ForegroundColor Green
        }
        "q" {
            Write-Host "`nExiting Slow City Project CLI. Goodbye!`n" -ForegroundColor Green
        }
        Default {
            Write-Warning "Invalid choice. Please pick 1-9 or Q."
            Start-Sleep -Seconds 1
        }
    }
} while ($selection -ne "Q" -and $selection -ne "q")
