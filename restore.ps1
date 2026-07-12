param([Parameter(Mandatory=$true)][string]$BackupSet)
$ErrorActionPreference = "Stop"
$normalized = $BackupSet.Replace('\\','/')
& vagrant ssh redis01 -c "cd /vagrant/ansible && ansible-playbook -i inventory.yml restore.yml -e backup_set='$normalized'"
if ($LASTEXITCODE -ne 0) { throw "Restore failed" }
