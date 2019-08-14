# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.vm.provision :hostmanager

  config.vm.define 'puppetmaster', primary: true do |puppetmaster|
    puppetmaster.vm.box = 'cmc/cis-centos76'
    puppetmaster.vm.hostname = 'puppetmaster.mdt-cmc.local'
    puppetmaster.vm.network 'private_network', bridge: 'vboxnet5', ip: '10.10.10.32'

    puppetmaster.vm.provider 'virtualbox' do |vb|
      vb.customize ["modifyvm", :id, "--paravirtprovider", "none"]
      vb.memory = 4096
      vb.customize ['modifyvm', :id, '--vram', '20']
      file_to_disk = './tmp/puppetmaster.vdi'
      unless File.exist?(file_to_disk)
        vb.customize ['createhd', '--filename', file_to_disk, '--size', (32 * 1024)]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      vb.gui = true
      vb.name = 'puppetmaster'
    end
    #run provisioning
    puppetmaster.vm.synced_folder 'puppet/hieradata', '/etc/puppetlabs/code/environments/production/hieradata/'
    puppetmaster.vm.synced_folder 'puppet/manifests', '/etc/puppetlabs/code/environments/production/manifests/'
    puppetmaster.vm.synced_folder 'puppet/modules', '/etc/puppetlabs/code/environments/production/modules/'
    puppetmaster.vm.provision :shell,
      path: 'bootstrap.sh',
      upload_path: '/home/vagrant/bootstrap_puppetmaster.sh'
  end
  config.vm.define 'elk', autostart: true do |elk|
    elk.vm.box = "cmc/cis-centos76"
    elk.vm.hostname = 'elk.mdt-cmc.local'
    elk.vm.network "private_network", bridge: "vboxnet5", ip: "10.10.10.146"
    elk.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--paravirtprovider", "none"]
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--vram", "20"]
      file_to_disk = './tmp/elk_dbdisk.vdi'
      unless File.exist?(file_to_disk)
        vb.customize ['createhd', '--filename', file_to_disk, '--size', (32 * 1024)]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      vb.gui = true
      vb.name = "elk"
    end
    #provision
    elk.vm.provision :shell,
      path: "bootstrap.sh",
      upload_path: "/home/vagrant/bootstrap.sh"
  end
end
