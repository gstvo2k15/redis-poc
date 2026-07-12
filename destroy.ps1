$ErrorActionPreference = "Stop"
& vagrant destroy -f
if ($LASTEXITCODE -ne 0) { throw "Destroy failed" }
