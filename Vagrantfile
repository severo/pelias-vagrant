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
    v.name = "pelias"
    v.memory = 8192
    v.cpus = 4
  end

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/debian10"
  config.disksize.size = "37GB" # Initial 32GB
  config.vm.base_mac = "080027783B7A"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # install docker and docker-compose
  config.vm.provision :docker
  config.vm.provision :docker_compose
  # init script
  config.vm.provision :file, source: 'pelias_start.sh', destination: "/home/vagrant/bin/pelias_start.sh"
  config.vm.provision :file, source: 'pelias_stop.sh', destination: "/home/vagrant/bin/pelias_stop.sh"
  config.vm.provision :file, source: 'pelias.service', destination: "/home/vagrant/bin/pelias.service"
  # bootstrap
  config.vm.provision :shell, path: "bootstrap.sh"
  # all the files have already been prepared, following https://github.com/pelias/docker/
  # only the useful files are copied
  config.vm.provision :file, source: '/data/pelias_prod/placeholder', destination: "/home/vagrant/data/placeholder"
  config.vm.provision :file, source: '/data/pelias_prod/interpolation', destination: "/home/vagrant/data/interpolation"
  config.vm.provision :file, source: '/data/pelias_prod/elasticsearch', destination: "/home/vagrant/data/elasticsearch"

end
