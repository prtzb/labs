# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.provision "shell", path: "install.sh"

  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
     vb.gui = false
     vb.memory = "1024"
   end

  # Master Node
  config.vm.define "master" do |master|
    master.vm.hostname = "0.k8s"
    master.vm.network "private_network", ip: "10.0.3.10"
  end

  # Worker Node
  config.vm.define "worker1" do |worker1|
    worker1.vm.hostname = "1.k8s"
    worker1.vm.network "private_network", ip: "10.0.3.11"
  end

  # Worker Node
  config.vm.define "worker2" do |worker2|
    worker2.vm.hostname = "2.k8s"
    worker2.vm.network "private_network", ip: "10.0.3.12"
  end

end
