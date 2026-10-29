param(
    [ValidateSet("json", "csv", "all")]
    [string]$Format = "all"
)

$sourcePath = Join-Path $PSScriptRoot "_Production_Docs\PRODUCTION_DASHBOARD.md"
$backupDir  = Join-Path $PSScriptRoot "_Production_Docs\Backups"

if (-not (Test-Path $sourcePath)) {
    Write-Warning "Dashboard file not found at: $sourcePath"
    exit
}

# Create Backups folder if it doesn't exist
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Parse dashboard table rows into structured PowerShell objects
$records = Get-Content $sourcePath | 
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
    }

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Export CSV
if ($Format -in @("csv", "all")) {
    $csvFile = Join-Path $backupDir "Dashboard_Snapshot_$timestamp.csv"
    $records | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
    Write-Host "Exported CSV snapshot: $csvFile" -ForegroundColor Green
}

# Export JSON
if ($Format -in @("json", "all")) {
    $jsonFile = Join-Path $backupDir "Dashboard_Snapshot_$timestamp.json"
    $records | ConvertTo-Json -Depth 2 | Set-Content -Path $jsonFile -Encoding UTF8
    Write-Host "Exported JSON snapshot: $jsonFile" -ForegroundColor Green
}
