Vagrant.configure(2) do |config|
  config.vm.define "yubatake-vm" do |node|
    node.vm.box = "bento/ubuntu-16.04"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end
end
