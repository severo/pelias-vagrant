# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.define "pelias-brazil"
  config.vm.hostname = "pelias-brazil"

  required_plugins = %w( vagrant-disksize )
  _retry = false
  required_plugins.each do |plugin|
      unless Vagrant.has_plugin? plugin
          system "vagrant plugin install #{plugin}"
          _retry=true
      end
  end

  if (_retry)
      exec "vagrant " + ARGV.join(' ')
  end

  config.vm.provider "virtualbox" do |v|
    v.name = "pelias-brazil"
    v.memory = 8192
    v.cpus = 4
  end

  # enable conection via ssh with password authentication
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "cloud-image/ubuntu-24.04"
  config.vm.box_version = "20260323.0.0"
  config.disksize.size = "40GB" # Initial 32GB
  config.vm.base_mac = "080027783B7A"

  # expose Pelias API
  config.vm.network "forwarded_port", guest: 4000, host: 4000

  # install docker
  config.vm.provision :docker
  # init script
  config.vm.provision :file, source: 'pelias_start.sh', destination: "/home/vagrant/bin/pelias_start.sh"
  config.vm.provision :file, source: 'pelias_stop.sh', destination: "/home/vagrant/bin/pelias_stop.sh"
  config.vm.provision :file, source: 'pelias.service', destination: "/home/vagrant/bin/pelias.service"
  # bootstrap
  config.vm.provision :shell, path: "bootstrap.sh"
end
