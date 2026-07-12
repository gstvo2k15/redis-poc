$ErrorActionPreference = "Stop"
& vagrant provision redis01 --provision-with ansible-controller
if ($LASTEXITCODE -ne 0) { throw "Ansible deployment failed" }
