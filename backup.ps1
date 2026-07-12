$ErrorActionPreference = "Stop"
& vagrant ssh redis01 -c "cd /vagrant/ansible && ansible-playbook -i inventory.yml backup.yml"
if ($LASTEXITCODE -ne 0) { throw "Backup failed" }
Write-Host "Backup sets: .lab\\backups"
