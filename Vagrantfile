Vagrant.configure("2") do |config|
  ## Chose your base box
  config.vm.box = "precise32"

  ## For masterless, mount your salt file root
  config.vm.synced_folder "salt/", "/srv/salt/"
  config.vm.synced_folder "pillar/", "/srv/pillar/"
  config.vm.network "forwarded_port", guest: 80, host: 8080

  ## Use all the defaults:
  config.vm.provision :salt do |salt|

    # This has a tendency to just hang without any explanation.
    salt.run_highstate = false
    salt.verbose = true

  end
end