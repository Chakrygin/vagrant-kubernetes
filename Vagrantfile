BOX_NAME = "ubuntu/focal64"
BOX_VERSION = "20210216.0.0"

VM_MEMORY = 2048
VM_CPU = 2

NODES = 1

Vagrant.configure("2") do |config|

    config.vm.provision "shell", path: "provision/install-mc.sh"
    config.vm.provision "shell", path: "provision/install-containerd.sh"
    config.vm.provision "shell", path: "provision/install-kubernetes.sh"
    config.vm.provision "shell", path: "provision/setup-any.sh"

    config.vm.define "kube-master" do |master|
        master.vm.box = BOX_NAME
        master.vm.box_version = BOX_VERSION

        master.vm.hostname = "kube-master"
        master.vm.network "private_network", ip: "192.168.10.10"

        master.vm.provision "shell", path: "provision/setup-master.sh"
        master.vm.provision "shell", path: "provision/setup-flannel.sh"

        master.vm.provider "virtualbox" do |vm|
            vm.name = "Kube Master"
            vm.memory = VM_MEMORY
            vm.cpus = VM_CPU
        end
    end

    (1..NODES).each do |n|
        config.vm.define "kube-node#{n}" do |node|
            node.vm.box = BOX_NAME
            node.vm.box_version = BOX_VERSION

            node.vm.hostname = "kube-node#{n}"
            node.vm.network "private_network", ip: "192.168.10.1#{n}"

            node.vm.provision "shell", path: "provision/setup-node.sh"

            node.vm.provider "virtualbox" do |vm|
                vm.name = "Kube Node #{n}"
                vm.memory = VM_MEMORY
                vm.cpus = VM_CPU
            end
        end
    end

end
