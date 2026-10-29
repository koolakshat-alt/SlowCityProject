$path = Join-Path $PSScriptRoot "_Production_Docs\PRODUCTION_DASHBOARD.md"

if (-not (Test-Path $path)) {
    Write-Warning "Dashboard file not found at: $path"
    exit
}

Write-Host "`n--- THE SLOW CITY PROJECT: PRODUCTION STATUS ---`n" -ForegroundColor Cyan

Get-Content $path | 
    Where-Object { $_ -match '^\|\s*\*\*EP' } | 
    ForEach-Object {
        $cols = $_.Split('|') | ForEach-Object { $_.Trim() }
        [PSCustomObject]@{
            Episode = $cols[1] -replace '\*', ''
            Title   = $cols[2] -replace '\*', ''
            Script  = $cols[3]
            Ingest  = $cols[4]
            Assets  = $cols[5]
            Edit    = $cols[6]
            Audio   = $cols[7]
            Master  = $cols[8]
            Status  = $cols[9]
        }
    } | Format-Table -AutoSize
