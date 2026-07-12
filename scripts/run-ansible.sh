#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ansible openssl rsync
mkdir -p /vagrant/.lab/pki /vagrant/.lab/backups
chmod 700 /vagrant/.lab/pki
cd /vagrant/ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml site.yml
