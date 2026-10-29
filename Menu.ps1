function Show-MainMenu {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "   THE SLOW CITY PROJECT - WORKFLOW CLI   " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "1. View Production Dashboard"
    Write-Host "2. Scaffold New Episode(s)"
    Write-Host "3. Export Dashboard Snapshot (JSON / CSV)"
    Write-Host "4. Sync Dashboard Changes to GitHub"
    Write-Host "5. Check Git Status"
    Write-Host "Q. Quit"
    Write-Host "------------------------------------------"
}

do {
    Show-MainMenu
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" {
            Clear-Host
            if (Test-Path ".\Show-Dashboard.ps1") {
                .\Show-Dashboard.ps1
            } else {
                Write-Warning "Show-Dashboard.ps1 not found."
            }
            Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Clear-Host
            Write-Host "--- Scaffold New Episode(s) ---`n" -ForegroundColor Cyan
            $start = Read-Host "Enter Start Episode Number (e.g. 12)"
            $end = Read-Host "Enter End Episode Number (press Enter to create only Episode $start)"

            if ($end -match '^\d+$') {
                .\New-Episode.ps1 -Start ([int]$start) -End ([int]$end)
            } elseif ($start -match '^\d+$') {
                .\New-Episode.ps1 -Start ([int]$start)
            } else {
                Write-Warning "Invalid episode number provided."
            }

            $pushNow = Read-Host "Stage and push new folders to GitHub now? (y/n)"
            if ($pushNow -eq 'y') {
                git add Episode_*
                git commit -m "Scaffold new episode batch"
                git push
            }
            Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Clear-Host
            Write-Host "--- Export Dashboard Snapshot ---`n" -ForegroundColor Cyan
            Write-Host "Formats: 1 = All, 2 = JSON, 3 = CSV"
            $fmtChoice = Read-Host "Select format (Default: 1)"
            
            $fmt = switch ($fmtChoice) {
                "2" { "json" }
                "3" { "csv" }
                default { "all" }
            }
            
            if (Test-Path ".\Export-Dashboard.ps1") {
                .\Export-Dashboard.ps1 -Format $fmt
            } else {
                Write-Warning "Export-Dashboard.ps1 not found."
            }
            Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            Clear-Host
            Write-Host "--- Sync Dashboard to GitHub ---`n" -ForegroundColor Cyan
            $note = Read-Host "Enter commit message (Leave blank for default)"
            
            if (Test-Path ".\Sync-Dashboard.ps1") {
                if ([string]::IsNullOrWhiteSpace($note)) {
                    .\Sync-Dashboard.ps1
                } else {
                    .\Sync-Dashboard.ps1 -Note $note
                }
            } else {
                Write-Warning "Sync-Dashboard.ps1 not found."
            }
            Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" {
            Clear-Host
            Write-Host "--- Current Git Status ---`n" -ForegroundColor Cyan
            git status
            Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($choice -notmatch '^[Qq]$')

Clear-Host
Write-Host "Exited Slow City Project CLI." -ForegroundColor Green
