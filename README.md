# Redis Cluster with Vagrant and Ansible

This project creates three Debian VMs and six Redis instances. Vagrant creates the VMs; Vagrant then invokes Ansible inside `redis01` through the named provisioner `ansible-controller`.

## Topology

| VM | 7000 | 7001 |
|---|---|---|
| redis01 | Primary 1 | Replica of redis02:7000 |
| redis02 | Primary 2 | Replica of redis03:7000 |
| redis03 | Primary 3 | Replica of redis01:7000 |

Final state: 3 primaries, 3 replicas, 6 known nodes, 16384 slots covered.

## Deploy from Windows PowerShell

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\up.ps1
.\deploy.ps1
.\check.ps1
```

`deploy.ps1` executes:

```powershell
vagrant provision redis01 --provision-with ansible-controller
```

That provisioner installs Ansible in `redis01` and runs:

```bash
cd /vagrant/ansible
ansible-playbook -i inventory.yml site.yml
```

## Security

The project enables TLS-only ports, mTLS, TLS replication, TLS cluster bus and ACL users.

Credentials are in `ansible/group_vars/all.yml`:

- `admin`: full administration.
- `app`: read/write only on `app:*`.
- `backup`: backup-related commands only.

Generated PKI is stored under `.lab/pki/`; `.lab/` is ignored by Git.

## Validate mTLS

```powershell
vagrant ssh redis01
```

```bash
sudo -u redis redis-cli --tls   --cacert /etc/redis/tls/ca.crt   --cert /etc/redis/tls/admin.crt   --key /etc/redis/tls/admin.key   --user admin -a ChangeMe-Admin-Redis   -c -h 192.168.56.11 -p 7000 PING
```

Expected: `PONG`.

## ACL

```bash
sudo -u redis redis-cli --tls   --cacert /etc/redis/tls/ca.crt   --cert /etc/redis/tls/admin.crt   --key /etc/redis/tls/admin.key   --user admin -a ChangeMe-Admin-Redis   -h 192.168.56.11 -p 7000 ACL LIST
```

Application test:

```bash
sudo -u redis redis-cli --tls --cacert /etc/redis/tls/ca.crt   --cert /etc/redis/tls/admin.crt --key /etc/redis/tls/admin.key   --user app -a ChangeMe-App-Redis -c -h 192.168.56.11 -p 7000   SET app:test hello
```

`FLUSHALL` with `app` must return `NOPERM`.

## Backup

```powershell
.\backup.ps1
```

Ansible validates all three replicas, runs `BGSAVE`, waits for success and creates a timestamped set under:

```text
.lab/backups/<timestamp>/
```

It contains three RDB files, `MANIFEST.txt` and `SHA256SUMS`.

## Restore

Lab-only destructive restore:

```powershell
.\restore.ps1 -BackupSet ".lab/backups/<timestamp>"
```

The playbook verifies checksums, stops all six instances, removes old AOF data, maps every RDB to the correct primary, starts primaries, then starts replicas.

## Cluster check

```powershell
.\check.ps1
```

Expected values:

```text
cluster_state:ok
cluster_known_nodes:6
cluster_size:3
```

## Destroy

```powershell
.\destroy.ps1
```
