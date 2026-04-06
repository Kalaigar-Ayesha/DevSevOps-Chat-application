# Production node classification for chat platform infrastructure.
node /^chat-k8s-master\d+(\..+)?$/ {
  include role::k8s_master
}

node /^chat-k8s-worker\d+(\..+)?$/ {
  include role::k8s_worker
}

node /^chat-monitor\d+(\..+)?$/ {
  include role::monitoring
}

# Safe default for any unmanaged nodes in the same environment.
node default {
  include profile::system
  include profile::security
  include profile::users
  # Include Docker in default so local standalone validation can prove service self-healing.
  include profile::docker
}
