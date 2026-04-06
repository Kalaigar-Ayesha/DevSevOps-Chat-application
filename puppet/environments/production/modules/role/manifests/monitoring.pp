class role::monitoring {
  contain profile::system
  contain profile::users
  contain profile::security
  contain profile::monitoring
}
