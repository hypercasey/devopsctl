#!/usr/bin/env bash
# Prepares the DevOps server environment.

createUser=true
# Requires createUser=true for mounting the
# NFS share as a regular non-privileged user.
createSshFingerUser=true
createPoweroffUser=true
createRebootUser=true
createNfsMount=true

if [[ true == "${createUser}" ]]; then
  userName="hyperuser"
fi

if [[ true == "${createSshFingerUser}" ]]; then
  fingerUserName="finger"
fi

if [[ true == "${createPoweroffUser}" ]]; then
  poweroffUserName="poweroff"
fi

if [[ true == "${createRebootUser}" ]]; then
  rebootUserName="reboot"
fi

if [[ true == "${createNfsMount}" ]]; then
  # Requires createUser=true for mounting the
  # NFS share as a regular non-privileged user.
  nfsMountPoint="/home/${userName}/hyperstor"
  nfsMountTarget="hyp.str.us.hyperspire.net:/hyperstor"
fi

function devopsInit {
  if [[ true == "${createUser}" ]]; then
    if sudo useradd -u 1111 -m ${userName}; then
      echo "${userName} created successfully"
      sudo cat /etc/skel/.bashrc | sudo tee "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias systemctl='sudo systemctl'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias service='sudo service'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias dnf='sudo dnf'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias cp='sudo cp -f --preserve=owner'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias mount='sudo mount'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias umount='sudo umount'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias podman='sudo podman'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias firewall-cmd='sudo firewall-cmd'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
      sudo echo "alias vi='nvim'" | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null

      if sudo mkdir -p "/home/${userName}/.ssh"; then
        echo "${userName}'s .ssh directory created successfully"
        sudo chmod 700 "/home/${userName}/.ssh"
        sudo touch "/home/${userName}/.ssh/authorized_keys"
        sudo chmod 600 "/home/${userName}/.ssh/authorized_keys"

        if sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHpNCMGLRlBb87F/Lq9B6hGDBQeBrAw0xOh31ZkdrK0ZiPHM4egELbjclNhlluDfBG02x880mJ7qQyyy82PNgqj5Bn2hIs46OomF1/Q6UwXTMNoYLIe5Ft3XqsyVjXVeZ2jh/SiF+KpiCLCtX8ZdguV3DFRtx1LMuVgh84EDC+jL1+flj4a0Is06UfT3STuJDqPcP6GDShw/O6rbSsHtuMkRQG18I7QCdBfTY0lCsIX8phy4K6jD3heIX6vtLQfm40nNDxTFS9FLK2Av9oC4Te8pd6tCeqTCp976I2ob4Kr27Cdj4++FUsranTlCvZJdiI8RUwKEcAPTfvalm8+sJV ssh-key-2022-03-26' | sudo tee -a "/home/${userName}/.ssh/authorized_keys" &> /dev/null; then
          echo "${userName}'s authorized_keys file was successfully updated" 
          sudo chown -R ${userName}. "/home/${userName}/."
        else
          echo "${userName}'s authorized_keys file was not updated"
          exit 1
        fi
      else
        echo "${userName}'s .ssh directory was not created"
        exit 1
      fi

      if [[ true == "${createNfsMount}" ]]; then
        if sudo mkdir -p "${nfsMountPoint}"; then
          echo "${nfsMountPoint} NFS mount directory was successfully created"
          if sudo echo "${nfsMountTarget}    ${nfsMountPoint}    nfs    user=${userName},defaults,auto,_netdev,nofail    0 0" | sudo tee -a /etc/fstab &> /dev/null; then
            echo "${userName}'s ${nfsMountPoint} mount point was successfully added"
            sudo mount ${nfsMountTarget}
            sudo chown -R ${userName}. "${nfsMountPoint}/." &> /dev/null
            sudo cp -f "${nfsMountPoint}/bin/containers-start" "/usr/local/bin/containers-start"
            sudo cp -f "${nfsMountPoint}/bin/containers-stop" "/usr/local/bin/containers-stop"
            sudo chmod +x "/usr/local/bin/containers-start"
            sudo chmod +x "/usr/local/bin/containers-stop"
            sudo cp -f "${nfsMountPoint}/containers.service" "/etc/systemd/system"
            sudo mkdir "/home/${userName}/.local"
            if sudo cp -R "${nfsMountPoint}/bin" "/home/${userName}/.local/"; then
              echo "${userName}'s local bin directory was successfully copied"
              sudo chown -R ${userName}. "/home/${userName}/.local/."
            else
              echo "${userName}'s local bin directory was not copied"
              exit 1
            fi
            if sudo cp -f "${nfsMountPoint}/valheim-release/Defaults" "/home/${userName}/Defaults"; then
              echo "${userName}'s Defaults file was successfully copied"
              sudo chown ${userName}. "/home/${userName}/Defaults"
              sudo chmod 600 "/home/${userName}/Defaults"
            else
              echo "${userName}'s Defaults file was not copied"
              exit 1
            fi
          else
            echo "${nfsMountPoint} mount point was not added"
            exit 1
          fi
        else
          echo "${nfsMountPoint} NFS mount directory was not created"
          exit 1
        fi

        if echo "${userName} ALL=(ALL) NOPASSWD: ALL" >> "${HOME}/1111-${userName}"; then
          echo "${userName}'s sudoers file was successfully generated"
          if [[ 1 == $(sudo visudo -cf "${HOME}/1111-${userName}" | grep -c 'parsed OK') ]]; then
            sudo cp "${HOME}/1111-${userName}" /etc/sudoers.d/ 
            sudo chmod 0440 "/etc/sudoers.d/1111-${userName}"
            echo "${userName}'s sudo permissions were successfully updated"  
          else
            echo "${userName}'s sudo permissions were not updated"
            exit 1
          fi
        else
          echo "${userName}'s sudoers file was not generated"
          exit 1
        fi
      fi
    else
      echo "${userName} not created"
      exit 1
    fi
  fi

  if [[ true == "${createSshFingerUser}" ]]; then
    if sudo useradd -u 2222 -s /usr/sbin/nologin -m ${fingerUserName}; then
      echo "${fingerUserName} created successfully"
      if sudo mkdir -p "/home/${fingerUserName}/.ssh"; then
        echo "${fingerUserName}'s .ssh directory was successfully created"
        sudo chmod 700 "/home/${fingerUserName}/.ssh"
        sudo touch "/home/${fingerUserName}/.ssh/authorized_keys"
        sudo chmod 600 "/home/${fingerUserName}/.ssh/authorized_keys"

        if sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHpNCMGLRlBb87F/Lq9B6hGDBQeBrAw0xOh31ZkdrK0ZiPHM4egELbjclNhlluDfBG02x880mJ7qQyyy82PNgqj5Bn2hIs46OomF1/Q6UwXTMNoYLIe5Ft3XqsyVjXVeZ2jh/SiF+KpiCLCtX8ZdguV3DFRtx1LMuVgh84EDC+jL1+flj4a0Is06UfT3STuJDqPcP6GDShw/O6rbSsHtuMkRQG18I7QCdBfTY0lCsIX8phy4K6jD3heIX6vtLQfm40nNDxTFS9FLK2Av9oC4Te8pd6tCeqTCp976I2ob4Kr27Cdj4++FUsranTlCvZJdiI8RUwKEcAPTfvalm8+sJV ssh-key-2022-03-26' | sudo tee -a "/home/${fingerUserName}/.ssh/authorized_keys" &> /dev/null; then
          echo "${fingerUserName}'s authorized_keys file was successfully updated" 
          sudo chown -R ${fingerUserName}. "/home/${fingerUserName}/."
        else
          echo "${fingerUserName}'s authorized_keys file was not updated"
          exit 1
        fi
      else
        echo "${fingerUserName}'s .ssh directory was not created"
        exit 1
      fi
    else
      echo "${fingerUserName} not created"
      exit 1
    fi
  fi

  if sudo touch /usr/sbin/systemctl-login; then
    sudo chmod +x /usr/sbin/systemctl-login
    sudo echo "#!/usr/bin/env bash" | sudo tee /usr/sbin/systemctl-login &> /dev/null
    sudo echo "[[ 3333 == $UID ]] && sudo systemctl poweroff" | sudo tee -a /usr/sbin/systemctl-login &> /dev/null
    sudo echo "[[ 4444 == $UID ]] && sudo systemctl reboot" | sudo tee -a /usr/sbin/systemctl-login &> /dev/null
    echo "systemctl-login script was created successfully"
  else
    echo "systemctl-login script was not created"
  fi

  if [[ true == "${createPoweroffUser}" ]]; then
    if sudo useradd -u 3333 -s /usr/sbin/systemctl-login -m ${poweroffUserName}; then
      echo "${poweroffUserName} created successfully"
      if sudo mkdir -p "/home/${poweroffUserName}/.ssh"; then
        echo "${poweroffUserName}'s .ssh directory was successfully created"
        sudo chmod 700 "/home/${poweroffUserName}/.ssh"
        sudo touch "/home/${poweroffUserName}/.ssh/authorized_keys"
        sudo chmod 600 "/home/${poweroffUserName}/.ssh/authorized_keys"

        if sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHpNCMGLRlBb87F/Lq9B6hGDBQeBrAw0xOh31ZkdrK0ZiPHM4egELbjclNhlluDfBG02x880mJ7qQyyy82PNgqj5Bn2hIs46OomF1/Q6UwXTMNoYLIe5Ft3XqsyVjXVeZ2jh/SiF+KpiCLCtX8ZdguV3DFRtx1LMuVgh84EDC+jL1+flj4a0Is06UfT3STuJDqPcP6GDShw/O6rbSsHtuMkRQG18I7QCdBfTY0lCsIX8phy4K6jD3heIX6vtLQfm40nNDxTFS9FLK2Av9oC4Te8pd6tCeqTCp976I2ob4Kr27Cdj4++FUsranTlCvZJdiI8RUwKEcAPTfvalm8+sJV ssh-key-2022-03-26' | sudo tee -a "/home/${poweroffUserName}/.ssh/authorized_keys" &> /dev/null; then
          echo "${poweroffUserName}'s authorized_keys file was successfully updated" 
          sudo chown -R ${poweroffUserName}. "/home/${poweroffUserName}/."
        else
          echo "${poweroffUserName}'s authorized_keys file was not updated"
          exit 1
        fi
      else
        echo "${poweroffUserName}'s .ssh directory was not created"
        exit 1
      fi
      if echo "${poweroffUserName} ALL=(ALL) NOPASSWD: /bin/systemctl poweroff" >> "${HOME}/3333-${poweroffUserName}"; then
        echo "${poweroffUserName}'s sudoers file was successfully generated"
        if [[ 1 == $(sudo visudo -cf "${HOME}/3333-${poweroffUserName}" | grep -c 'parsed OK') ]]; then
          sudo cp "${HOME}/3333-${poweroffUserName}" /etc/sudoers.d/ 
          sudo chmod 0440 "/etc/sudoers.d/3333-${poweroffUserName}"
          echo "${poweroffUserName}'s sudo permissions were successfully updated"  
        else
          echo "${poweroffUserName}'s sudo permissions were not updated"
          exit 1
        fi
      else
        echo "${poweroffUserName}'s sudoers file was not generated"
        exit 1
      fi
    else
      echo "${poweroffUserName} not created"
      exit 1
    fi
  fi

  if [[ true == "${createRebootUser}" ]]; then
    if sudo useradd -u 4444 -s /usr/sbin/systemctl-login -m ${rebootUserName}; then
      echo "${rebootUserName} created successfully"
      if sudo mkdir -p "/home/${rebootUserName}/.ssh"; then
        echo "${rebootUserName}'s .ssh directory was successfully created"
        sudo chmod 700 "/home/${rebootUserName}/.ssh"
        sudo touch "/home/${rebootUserName}/.ssh/authorized_keys"
        sudo chmod 600 "/home/${rebootUserName}/.ssh/authorized_keys"

        if sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHpNCMGLRlBb87F/Lq9B6hGDBQeBrAw0xOh31ZkdrK0ZiPHM4egELbjclNhlluDfBG02x880mJ7qQyyy82PNgqj5Bn2hIs46OomF1/Q6UwXTMNoYLIe5Ft3XqsyVjXVeZ2jh/SiF+KpiCLCtX8ZdguV3DFRtx1LMuVgh84EDC+jL1+flj4a0Is06UfT3STuJDqPcP6GDShw/O6rbSsHtuMkRQG18I7QCdBfTY0lCsIX8phy4K6jD3heIX6vtLQfm40nNDxTFS9FLK2Av9oC4Te8pd6tCeqTCp976I2ob4Kr27Cdj4++FUsranTlCvZJdiI8RUwKEcAPTfvalm8+sJV ssh-key-2022-03-26' | sudo tee -a "/home/${rebootUserName}/.ssh/authorized_keys" &> /dev/null; then
          echo "${rebootUserName}'s authorized_keys file was successfully updated" 
          sudo chown -R ${rebootUserName}. "/home/${rebootUserName}/."
        else
          echo "${rebootUserName}'s authorized_keys file was not updated"
          exit 1
        fi
      else
        echo "${rebootUserName}'s .ssh directory was not created"
        exit 1
      fi
      if echo "${rebootUserName} ALL=(ALL) NOPASSWD: /bin/systemctl reboot" >> "${HOME}/4444-${rebootUserName}"; then
        echo "${rebootUserName}'s sudoers file was successfully generated"
        if [[ 1 == $(sudo visudo -cf "${HOME}/4444-${rebootUserName}" | grep -c 'parsed OK') ]]; then
          sudo cp "${HOME}/4444-${rebootUserName}" /etc/sudoers.d/ 
          sudo chmod 0440 "/etc/sudoers.d/4444-${rebootUserName}"
          echo "${rebootUserName}'s sudo permissions were successfully updated"  
        else
          echo "${rebootUserName}'s sudo permissions were not updated"
          exit 1
        fi
      else
        echo "${rebootUserName}'s sudoers file was not generated"
        exit 1
      fi
    else
      echo "${rebootUserName} not created"
      exit 1
    fi
  fi

  sudo dnf -q check-update
  sudo dnf -qy update
  sudo systemctl enable ocid.service
  sudo systemctl enable oracle-cloud-agent.service
  sudo systemctl enable oracle-cloud-agent-updater.service

  if sudo dnf -y install podman podman-manpages \
  podman-plugins podman-remote podman-tests \
  podman-catatonit podman-gvproxy runc \
  fuse-overlayfs containers-common skopeo conmon \
  containernetworking-plugins systemd-container git \
  container-selinux container-exception-logger nmap \
  automake libtool lua lua-guestfs lua-json lua-libs \
  lua-lpeg lua-socket gcc libstdc++ libstdc++-devel \
  gcc-c++ make cmake; then
    echo "Software dependencies installed successfully"
  else
    echo "Software dependencies were not installed"
    exit 1
  fi

  if curl https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz -o ~/node-v16.15.1-linux-x64.tar.xz; then
    tar -xJf ~/node-* -C ~/
    rm -f ~/node-*.xz
    sudo mv ~/node-* /home/${userName}/nodejs
    sudo chown -R ${userName}. /home/${userName}/nodejs/.
    sudo echo 'export PATH="$PATH:$HOME/nodejs/bin"' | sudo tee -a "/home/${userName}/.bashrc" &> /dev/null
    echo "Node.js installed successfully"
  else
    echo "Node.js was not installed"
    exit 1
  fi

  if sudo dnf -qy remove vim-enhanced; then
  echo "Vim-enhanced removed successfully"
  else
    echo "Vim-enhanced not removed"
    exit 1
  fi
  
  if sudo systemctl enable podman.service; then
    echo "Podman service enabled successfully"
  else
    echo "Podman service not enabled"
    exit 1
  fi
  if sudo systemctl enable podman.socket; then
    echo "Podman socket enabled successfully"
  else
    echo "Podman socket not enabled"
    exit 1
  fi
  if sudo systemctl enable podman-auto-update.service; then
    echo "Podman auto-update service enabled successfully"
  else
    echo "Podman auto-update service not enabled"
    exit 1
  fi
  if sudo systemctl enable podman-auto-update.timer; then
    echo "Podman auto-update timer enabled successfully"
  else
    echo "Podman auto-update timer not enabled"
    exit 1
  fi
  if sudo systemctl enable podman-restart.service; then
    echo "Podman restart service enabled successfully"
  else
    echo "Podman restart service not enabled"
    exit 1
  fi

  sudo systemctl stop firewalld &> /dev/null
  sudo systemctl disable firewalld &> /dev/null
  if sudo dnf -qy remove firewalld &> /dev/null; then
    echo "Firewalld was removed successfully"
  else
    echo "Firewalld was not removed"
    exit 1
  fi
  return $?
}

if devopsInit; then
  echo "DevOps environment initialized successfully, system will now reboot."
  sudo systemctl reboot
else
  echo "Devops init failed"
  exit 1
fi

exit $?
