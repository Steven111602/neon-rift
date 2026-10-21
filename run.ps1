param([ValidateSet('web','desktop')][string]$Mode = 'web')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
python tools/build.py
if ($LASTEXITCODE -ne 0) { throw 'Build failed' }
if ($Mode -eq 'desktop') {
    & love .
} else {
    Write-Host 'Ouvrir http://localhost:8000/web/'
    python -m http.server 8000 --bind 127.0.0.1
}
