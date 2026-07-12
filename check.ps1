$ErrorActionPreference = "Stop"
& vagrant ssh redis01 -c "cd /vagrant/ansible && ansible-playbook -i inventory.yml check.yml"
if ($LASTEXITCODE -ne 0) { throw "Cluster validation failed" }
