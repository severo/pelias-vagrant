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

  project_name = ENV["PELIAS_PROJECT"]
  docker_dir = ENV["PELIAS_DOCKER_DIR"]
  machine_size = ENV["PELIAS_MACHINE_SIZE"]

  # Return an error if the project name, the data directory, or the machine size are not set, or if the data directory does not exist
  if project_name.nil? || docker_dir.nil? || machine_size.nil?
    puts "Please set the PELIAS_PROJECT, PELIAS_DOCKER_DIR, and PELIAS_MACHINE_SIZE environment variables before running vagrant up."
    exit
  end

  host_data_dir = "#{docker_dir}/projects/#{project_name}/data"
  unless File.exist?(host_data_dir)
    puts "The data directory #{host_data_dir} does not exist. Please create it and prepare the data as described in the README.md file before running vagrant up."
    exit
  end

  config.vm.define "pelias-#{project_name}"
  config.vm.hostname = "pelias-#{project_name}"

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
    v.name = "pelias-#{project_name}"
    v.memory = 8192
    v.cpus = 4
  end

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "cloud-image/ubuntu-24.04"
  config.vm.box_version = "20260323.0.0"
  config.disksize.size = machine_size

  # expose Pelias API
  config.vm.network "forwarded_port", guest: 4000, host: 5000

  # install docker
  config.vm.provision :docker
  # init script
  config.vm.provision :file, source: 'pelias_start.sh', destination: "/home/vagrant/bin/pelias_start.sh"
  config.vm.provision :file, source: 'pelias_stop.sh', destination: "/home/vagrant/bin/pelias_stop.sh"
  config.vm.provision :file, source: 'pelias.service', destination: "/home/vagrant/bin/pelias.service"
  # bootstrap
  config.vm.provision :shell, path: "bootstrap.sh", env: {"PELIAS_PROJECT" => project_name}
  # all the files have already been prepared in step 1 (see README.md), so we just need to copy them to the virtual machine
  config.vm.provision :file, source: "#{host_data_dir}", destination: "/home/vagrant/data"
end
