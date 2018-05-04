Vagrant.configure(2) do |config|
  config.vm.define "note-vm" do |node|
    node.vm.box = "bento/ubuntu-16.04"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

  config.vm.network "forwarded_port", guest: 3306, host: 3308
  config.vm.provision "shell", path: "setup_swift.sh"
end
