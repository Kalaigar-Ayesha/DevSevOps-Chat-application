#!/usr/bin/env bash
set -euo pipefail

# Usage in Terraform templatefile:
# role = "k8s_master" | "k8s_worker" | "monitoring"
ROLE="${role:-k8s_worker}"
PUPPET_SERVER="${puppet_server:-puppet.internal}"
ENVIRONMENT="${puppet_environment:-production}"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl ca-certificates gnupg lsb-release

# Install Puppet agent from official repository
PUPPET_DEB="/tmp/puppet-release.deb"
curl -fsSL -o "${PUPPET_DEB}" "https://apt.puppet.com/puppet8-release-$(lsb_release -cs).deb"
dpkg -i "${PUPPET_DEB}"
apt-get update -y
apt-get install -y puppet-agent

# Custom role fact used by Hiera hierarchy.
mkdir -p /etc/puppetlabs/facter/facts.d
cat > /etc/puppetlabs/facter/facts.d/role.txt <<EOF
role=${ROLE}
EOF

# Agent configuration
cat > /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
certname = $(hostname -f)
server = ${PUPPET_SERVER}
environment = ${ENVIRONMENT}
runinterval = 30m
splay = true
splaylimit = 300
pluginsync = true

[agent]
report = true
EOF

systemctl enable puppet
systemctl start puppet

# Initial convergence; non-zero exit can happen with cert autosign disabled.
/opt/puppetlabs/bin/puppet agent -t || true
