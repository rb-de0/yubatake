Vagrant.configure(2) do |config|
  config.vm.define "note-vm" do |node|
    node.vm.box = "bento/ubuntu-14.04"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision "shell", path: "setup_swift.sh"
end
