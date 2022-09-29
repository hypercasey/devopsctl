#!/usr/bin/env bash
# Prepares the environment and updates the DevOps Run Command
# scripts in Cloud Storage.
# Prepare the environment for the DevOps server ocarun user.:
# curl -LSs https://objectstorage.us-ashburn-1.oraclecloud.com/p/7NZrvQr9qp4NClauXM_BuKgW_EZxiu1AcjFPSl8uHHiqM_zHCN51U6JkeBv3qEpu/n/hyperspirefndn/b/hyperstor/o/devops-prepare.sh | sh
# DevOps Run Command:
# curl -LSs https://objectstorage.us-ashburn-1.oraclecloud.com/p/7NZrvQr9qp4NClauXM_BuKgW_EZxiu1AcjFPSl8uHHiqM_zHCN51U6JkeBv3qEpu/n/hyperspirefndn/b/hyperstor/o/devops-init.sh | sh

if curl -T 'devops-init.sh' https://objectstorage.us-ashburn-1.oraclecloud.com/p/7NZrvQr9qp4NClauXM_BuKgW_EZxiu1AcjFPSl8uHHiqM_zHCN51U6JkeBv3qEpu/n/hyperspirefndn/b/hyperstor/o/devops-init.sh; then
  echo "DevOps Run Command script successfully updated"
else
  echo "DevOps Run Command script was not updated"
  return 1
fi

if curl -T 'devops-prepare.sh' https://objectstorage.us-ashburn-1.oraclecloud.com/p/7NZrvQr9qp4NClauXM_BuKgW_EZxiu1AcjFPSl8uHHiqM_zHCN51U6JkeBv3qEpu/n/hyperspirefndn/b/hyperstor/o/devops-prepare.sh; then
  echo "DevOps prepare script successfully updated"
else
  echo "DevOps prepare script was not updated"
  return 1
fi
