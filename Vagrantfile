# Project Generated with
# rails new generic-test -B

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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 3000, host: 3800, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM or configure . The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.

  project_name = "ice_cube"
  fail "project_name can't be blank" if project_name.nil? || project_name == "" #can’t use blank

  config.vm.synced_folder ".", "/home/vagrant/#{project_name}"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.

  config.vm.provision "bootstrapping", type: "shell", privileged: false,
    keep_color: true, inline: <<-SHELL
      PURPLE='\033[1;35m'; GREEN='\033[1;32m'; NC='\033[0;0m'
      echo "${PURPLE}BEGINNING BOOTSTRAPPING PROCESS...Grab a drink. This could take a while.${NC}"
      echo ' '
      echo "${PURPLE}UPDATING .BASHRC FILE${NC}"
      echo "cd /home/vagrant/#{project_name}" >> /home/vagrant/.bashrc
      cd ~/#{project_name}
      echo "${GREEN}COMPLETED UPDATING .BASHRC FILE${NC}"
      echo ' '
      echo "${PURPLE}INSTALLING RVM & RUBY${NC}"
      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
      curl -sSL https://get.rvm.io | bash -s stable --ruby=2.4
      source /home/vagrant/.rvm/scripts/rvm
      echo "${GREEN}COMPLETED INSTALLING RVM & RUBY${NC}"
      echo ' '
      echo "${PURPLE}INSTALLING GEMS${NC}"
      gem install bundler --no-rdoc --no-ri
      bundle install
      echo "${GREEN}COMPLETED INSTALLING GEMS${NC}"
    SHELL

  config.vm.provision "bootstrapping complete", type: "shell", privileged: false,
    keep_color: true, run: "always", inline: <<-SHELL
      GREEN="\033[1;32m"; BLUE='\033[1;34m'; NC="\033[0;0m"
      echo "${GREEN}BOOTSTRAPPING COMPLETE!${NC}"
    SHELL
end
