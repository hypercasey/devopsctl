#!/usr/bin/env bash
# Prepares the DevOps server ocarun user.

function prepareDevOps {
  if sudo echo 'ocarun  ALL=(ALL) NOPASSWD: ALL' | sudo tee "/etc/sudoers.d/101-oracle-cloud-agent-run-command" &> /dev/null; then
    echo "ocarun's sudo permissions were successfully updated"
  else
    echo "ocarun's sudo permissions were not updated"
    exit 1
  fi
  if sudo chmod 0440 /etc/sudoers.d/101-oracle-cloud-agent-run-command; then
    echo "ocarun's sudo permissions were successfully updated"
  else
    echo "ocarun's sudo permissions were not updated"
    exit 1
  fi
  if sudo visudo -cf /etc/sudoers.d/101-oracle-cloud-agent-run-command | grep --color 'parsed OK'; then
    echo "ocarun's sudo permissions were successfull"
  else
    echo "ocarun's sudo permissions failed"
    exit 1
  fi
  if sudo echo '[[ -f "/etc/bashrc" ]] && source "/etc/bashrc"' | sudo tee "/etc/skel/.bashrc" &> /dev/null; then
    echo "Default .bashrc file was successfully updated"
  else
    echo "Default .bashrc file was not updated"
    exit 1
  fi
  if sudo echo 'export PATH="/home/${USER}/bin:/home/${USER}/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/bin:/usr/bin"' | sudo tee -a "/etc/skel/.bashrc" &> /dev/null; then
    echo "Default PATH variable was successfully updated"
  else
    echo "Default PATH variable was not updated"
    exit 1
  fi
  if sudo echo export PS1="'[ \h:\W ] ⥈ '" | sudo tee -a "/etc/skel/.bashrc" &> /dev/null; then
    echo "Default PS1 variable was successfully updated"
  else
    echo "Default PS1 variable was not updated"
    exit 1
  fi
  if sudo echo "$(sudo cat /etc/skel/.bashrc)" | sudo tee "/var/lib/ocarun/.bashrc" &> /dev/null; then
    echo "ocarun's .bashrc file was successfully updated"
  else
    echo "ocarun's .bashrc file was not updated"
    exit 1
  fi
  return $?
}

prepareDevOps
exit $?