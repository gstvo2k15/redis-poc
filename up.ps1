$ErrorActionPreference = "Stop"
foreach ($node in @("redis01","redis02","redis03")) {
  Write-Host "Starting $node..."
  & vagrant up $node
  if ($LASTEXITCODE -ne 0) { throw "vagrant up $node failed" }
}
Write-Host "All VMs are running. Run .\\deploy.ps1 next."
