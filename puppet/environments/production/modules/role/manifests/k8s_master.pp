class role::k8s_master {
  contain profile::system
  contain profile::users
  contain profile::security
  contain profile::docker
  contain profile::kubernetes::master
  contain profile::monitoring
}
