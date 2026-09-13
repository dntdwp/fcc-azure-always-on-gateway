param(
  [Parameter(Mandatory = $true)]
  [string]$FccHost
)

$base = "http://${FccHost}:8082"
Write-Host "== $base/health =="
curl.exe -s "$base/health"
Write-Host "`n== $base/v1/models (first 500 chars) =="
$models = curl.exe -s "$base/v1/models"
if ($models) { $models.Substring(0, [Math]::Min(500, $models.Length)) } else { Write-Warning "No response from /v1/models" }
Write-Host ""
