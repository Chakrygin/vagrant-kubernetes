BOX_NAME = "ubuntu/focal64"
BOX_VERSION = "20210624.0.0"

VM_CPU = 2
VM_MEMORY = 2048

WORKER_NODES = 1

Vagrant.configure("2") do |config|

    config.vm.provision "shell", path: "provision.sh"

    config.vm.define "kube-master" do |master|
        master.vm.box = BOX_NAME
        master.vm.box_version = BOX_VERSION

        master.vm.hostname = "kube-master"
        master.vm.network "public_network", ip: "192.168.1.100"

        master.vm.provider "virtualbox" do |vm|
            vm.name = "Kube Master"
            vm.cpus = VM_CPU
            vm.memory = VM_MEMORY
        end
    end

    (1..WORKER_NODES).each do |n|
        config.vm.define "kube-worker-#{n}" do |worker|
            worker.vm.box = BOX_NAME
            worker.vm.box_version = BOX_VERSION

            worker.vm.hostname = "kube-worker-#{n}"
            worker.vm.network "public_network", ip: "192.168.1.10#{n}"

            worker.vm.provider "virtualbox" do |vm|
                vm.name = "Kube Worker #{n}"
                vm.cpus = VM_CPU
                vm.memory = VM_MEMORY
            end
        end
    end

end
