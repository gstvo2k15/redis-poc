BOX = ENV.fetch("VAGRANT_BOX", "debian/bookworm64")
NODES = {"redis01"=>"192.168.56.11","redis02"=>"192.168.56.12","redis03"=>"192.168.56.13"}
Vagrant.configure("2") do |config|
  config.vm.box = BOX
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  NODES.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |vb|
        vb.name = "redis-lab-#{name}"
        vb.cpus = 2
        vb.memory = 2048
      end
      node.vm.provision "shell", inline: <<-SHELL
        set -e
        grep -q "redis01" /etc/hosts || cat >> /etc/hosts <<'EOF'
192.168.56.11 redis01 redis01.lab.local
192.168.56.12 redis02 redis02.lab.local
192.168.56.13 redis03 redis03.lab.local
EOF
      SHELL
    end
  end
  config.vm.define "redis01" do |node|
    node.vm.provision "shell", name: "ansible-controller", run: "never", path: "scripts/run-ansible.sh"
  end
end
