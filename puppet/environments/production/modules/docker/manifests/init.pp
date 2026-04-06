class docker (
  Boolean $manage_package = lookup('docker::manage_package', { default_value => true }),
  String $package_name    = lookup('docker::package_name', { default_value => 'docker.io' }),
  String $service_name    = lookup('docker::service_name', { default_value => 'docker' }),
  String $daemon_json     = lookup('docker::daemon_json'),
) {
  if $manage_package {
    package { $package_name:
      ensure => installed,
    }
  }

  file { '/etc/docker':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/docker/daemon.json':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $daemon_json,
    notify  => Service[$service_name],
    require => File['/etc/docker'],
  }

  if $manage_package {
    service { $service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Package[$package_name],
    }
  } else {
    service { $service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
