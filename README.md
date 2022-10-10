# devopsctl
Automates a devops deployment on Oracle Cloud Infrastructure. This is really only useful for those requiring a clean-slated remote build environment and are already developing with Oracle Cloud Infrastructure, who only need access to the remote build environment while they are working on it to cut costs of running an instance full time.

Basic Instructions:
  Replace all variable definitions with your own OCID's and make any other neccessary customizations to the build environment.

  Rewrite any custom automated tasks to suit your own scenario, obviously replace any example hosts and SSH keys with your own, etc.
  
  Create stack(s) and upadate all neccessary scripts to those stack OCID's.
  
  At a minimum, be sure to enable the following in your Terraform configuration:
      is_management_disabled = "false"
      plugins_config {
        desired_state = "ENABLED"
        name = "OS Management Service Agent"
      }
      plugins_config {
        desired_state = "ENABLED"
        name = "Management Agent"
      }
      
  If using multiple subnets, remember to use the correct subnet during stack creation, or instance creation will fail with an obscure warning burried deep within the Terraform log.
  
  Create your own custom image and copy that image's OCID to your stack if you want to use a custom image source. Alternatively, you can use an Oracle supplied image or a persistent boot volume, just follow the instructions in devops-config.ts to enable these operations and make any neccessary changes to your Terraform configuration, namely the source type, either "IMAGE" if using an image, or "VOLUME" if using a boot volume.
  
  Copy devopsctl.service to your systemd folder (usually /etc/systemd/system).
  
  Run systemctl [ enable/start/stop/daemon-reload ] devopsctl.service as needed.
  
  Edit and run init-devops-server, after placing init-devops-server under ~/bin. If you want to have a handy way of automating the environment to suit your needs.
  
  The automated initialization scripts devops-init.sh, devops-init-url.sh and devops-prepare.sh will need to be updated to your own object storage endpoint URL's which allows the instance to access these scripts and also the OCI run command if you ever want to use that approach, as these scripts were designed to be compatible with either method. 

Purpose:
  This was created to save money by automating preemptible capacity instances and to enhance security by deploying the stack from a custom image, which reverts everything to a clean slated environment each time for development. Once online, the instance runs custom configuration scripts, downloads everything it needs from OCI containers and installs additional software from GitHub.

  Since the Bilderberger communists have won WWIII through the use of barbaric internet censorship, propoganda ad compaigns through throwing around their weight as advertisers, and of course, biologival weapons of mass destruction followed by full scale global psychological warfare; energy prices went through the roof. Oracle has seemingly throttled preemptible instances, however; it's still useful if you want to work with a clean slated build environment. Unfortunately, it won't save you any money, neccessarily, at the moment.
