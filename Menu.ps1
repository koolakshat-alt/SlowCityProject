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
            if (Test-Path ".\Show-Dashboard.ps1") {
                .\Show-Dashboard.ps1
            } else {
                Write-Warning "Show-Dashboard.ps1 not found in current directory."
            }
            Pause
        }
        "2" {
            if (Test-Path ".\New-Episode.ps1") {
                $epNum = Read-Host "Enter episode number to scaffold (e.g., 2, 3)"
                $epTitle = Read-Host "Enter episode title (optional)"
                if ($epTitle) {
                    .\New-Episode.ps1 -EpisodeNumber $epNum -EpisodeTitle $epTitle
                } else {
                    .\New-Episode.ps1 -EpisodeNumber $epNum
                }
            } else {
                Write-Warning "New-Episode.ps1 not found in current directory."
            }
            Pause
        }
        "3" {
            if (Test-Path ".\Test-EpisodeAssets.ps1") {
                $ep = Read-Host "Enter episode number to test (e.g., 1)"
                .\Test-EpisodeAssets.ps1 -Episode $ep -Detailed
            } else {
                Write-Warning "Test-EpisodeAssets.ps1 not found in current directory."
            }
            Pause
        }
        "4" {
            if (Test-Path ".\Test-AudioCompliance.ps1") {
                $audioPath = Read-Host "Enter path to audio file or directory to scan"
                .\Test-AudioCompliance.ps1 -Target $audioPath
            } else {
                Write-Warning "Test-AudioCompliance.ps1 not found in current directory."
            }
            Pause
        }
        "5" {
            if (Test-Path ".\New-Thumbnail.ps1") {
                $ep = Read-Host "Enter episode number for thumbnail"
                .\New-Thumbnail.ps1 -Episode $ep
            } else {
                Write-Warning "New-Thumbnail.ps1 not found in current directory."
            }
            Pause
        }
        "6" {
            if (Test-Path ".\Clear-RenderCache.ps1") {
                .\Clear-RenderCache.ps1
            } else {
                Write-Warning "Clear-RenderCache.ps1 not found in current directory."
            }
            Pause
        }
        "7" {
            if (Test-Path ".\Export-Dashboard.ps1") {
                .\Export-Dashboard.ps1
            } else {
                Write-Warning "Export-Dashboard.ps1 not found in current directory."
            }
            Pause
        }
        "8" {
            if (Test-Path ".\Sync-Dashboard.ps1") {
                .\Sync-Dashboard.ps1
            } else {
                Write-Warning "Sync-Dashboard.ps1 not found in current directory."
            }
            Pause
        }
        "9" {
            if (Test-Path ".\Rename-RawFootage.ps1") {
                $folder = Read-Host "Enter target folder path containing raw media"
                $ep = Read-Host "Enter Episode Number (e.g., 01)"
                $cam = Read-Host "Enter Camera identifier (A, B, D, or Stills) [Default: A]"
                if (-not $cam) { $cam = "A" }
                $act = Read-Host "Enter Act name (e.g., ACT1_ColdOpen) [Default: ACT1_ColdOpen]"
                if (-not $act) { $act = "ACT1_ColdOpen" }
                $shot = Read-Host "Enter Shot Type (e.g., TRACK, CU, EST) [Default: TRACK]"
                if (-not $shot) { $shot = "TRACK" }

                $isDry = Read-Host "Run as a dry-run preview first? (y/n) [Default: y]"
                if ($isDry -ne 'n') {
                    .\Rename-RawFootage.ps1 -TargetFolder $folder -Episode $ep -Camera $cam -Act $act -ShotType $shot -DryRun
                } else {
                    .\Rename-RawFootage.ps1 -TargetFolder $folder -Episode $ep -Camera $cam -Act $act -ShotType $shot
                }
            } else {
                Write-Warning "Rename-RawFootage.ps1 not found in current directory."
            }
            Pause
        }
        "Q" {
            Write-Host "`nExiting Slow City Project CLI. See you next session!`n" -ForegroundColor Cyan
        }
        default {
            Write-Warning "Invalid option. Please choose a number from 1 to 9, or Q to quit."
            Start-Sleep -Seconds 1
        }
    }
} while ($selection -ne "Q" -and $selection -ne "q")