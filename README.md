# devopsctl
Automates a devops deployment on Oracle Cloud Infrastructure. This is something used internally, but could be of potential value to those externally as well.

Disclaimer:
  I wrote most of this software in a paranoid and manic altered state of consciousness as is legally required for my medical conditions as a combat veteran struggling in the survival against PTSD, so I'll go ahead and write some instructions once I can afford my medications again so that I remember whatever it was I was trying to do in the first place.

Basic Instructions:
  Replace all variable definitions with your own OCID's and make any other neccessary customizations to the build environment.

  Rewrite any custom automated tasks to suit your own scenario, obviously replace any example hosts and SSH keys with your own, etc.

Purpose:
  This was created to save money by automating preemptible capacity instances and to enhance security by deploying the stack from a custom image, which reverts everything to a clean slated environment each time for development. Once online, the instance runs custom configuration scripts, downloads everything it needs from OCI containers and installs additional software from GitHub.

  Since energy prices have gone through the roof, Oracle has apparently throttled preemptible instances, however, but it's still useful if you want to work with a clean slated build environment... it just won't save you any money anymore, neccessarily.
