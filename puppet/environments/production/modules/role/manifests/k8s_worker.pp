class role::k8s_worker {
  contain profile::system
  contain profile::users
  contain profile::security
  contain profile::docker
  contain profile::kubernetes::worker
  contain profile::monitoring
}
