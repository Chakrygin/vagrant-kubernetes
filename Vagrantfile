BOX_NAME = "ubuntu/focal64"
BOX_VERSION = "20210216.0.0"

VM_MEMORY = 2048
VM_CPU = 2

WORKER_NODES = 1

Vagrant.configure("2") do |config|

    config.vm.provision "shell", path: "provision/install-mc.sh"
    config.vm.provision "shell", path: "provision/install-containerd.sh"
    config.vm.provision "shell", path: "provision/install-kubernetes.sh"
    config.vm.provision "shell", path: "provision/setup-node.sh"

    config.vm.define "kube-master" do |master|
        master.vm.box = BOX_NAME
        master.vm.box_version = BOX_VERSION

        master.vm.hostname = "kube-master"
        master.vm.network "private_network", ip: "192.168.10.10"

        master.vm.provision "shell", path: "provision/setup-node-master.sh"
        master.vm.provision "shell", path: "provision/setup-flannel.sh"

        master.vm.provider "virtualbox" do |vm|
            vm.name = "Kube Master"
            vm.memory = VM_MEMORY
            vm.cpus = VM_CPU
        end
    end

    (1..WORKER_NODES).each do |n|
        config.vm.define "kube-worker-#{n}" do |worker|
            worker.vm.box = BOX_NAME
            worker.vm.box_version = BOX_VERSION

            worker.vm.hostname = "kube-worker-#{n}"
            worker.vm.network "private_network", ip: "192.168.10.1#{n}"

            worker.vm.provision "shell", path: "provision/setup-node-worker.sh"

            worker.vm.provider "virtualbox" do |vm|
                vm.name = "Kube Worker #{n}"
                vm.memory = VM_MEMORY
                vm.cpus = VM_CPU
            end
        end
    end

end
