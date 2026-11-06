param(
    [string]$Path = ".",
    [switch]$Recurse
)

Get-ChildItem -Path $Path -Filter *.gz -File -Recurse:$Recurse | ForEach-Object {
    $outFile = $_.FullName -replace '\.gz$', ''
    $inStream  = [System.IO.File]::OpenRead($_.FullName)
    $outStream = [System.IO.File]::Create($outFile)
    $gzip = New-Object System.IO.Compression.GZipStream($inStream, [System.IO.Compression.CompressionMode]::Decompress)
    try {
        $gzip.CopyTo($outStream)
        Write-Host "Extracted: $outFile"
    }
    finally {
        $gzip.Close(); $outStream.Close(); $inStream.Close()
    }
}