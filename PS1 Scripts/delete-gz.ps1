[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Path = ".",
    [switch]$Force   # skip the confirmation prompt
)

# Find all .gz files in the folder and every subfolder
$files = Get-ChildItem -Path $Path -Filter *.gz -File -Recurse -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Host "No .gz files found in '$Path'."
    return
}

$totalMB = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 2)
Write-Host "Found $($files.Count) .gz file(s) ($totalMB MB) under '$((Resolve-Path $Path).Path)'."

# Ask for confirmation unless -Force or -WhatIf was used
if (-not $Force -and -not $WhatIfPreference) {
    $answer = Read-Host "Delete all of them permanently? (y/N)"
    if ($answer -notmatch '^[yY]') {
        Write-Host "Cancelled. Nothing was deleted."
        return
    }
}

$deleted = 0
foreach ($file in $files) {
    if ($PSCmdlet.ShouldProcess($file.FullName, "Delete")) {
        try {
            Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
            Write-Host "Deleted: $($file.FullName)"
            $deleted++
        }
        catch {
            Write-Warning "Could not delete $($file.FullName): $($_.Exception.Message)"
        }
    }
}

Write-Host "Done. Deleted $deleted of $($files.Count) file(s)."
