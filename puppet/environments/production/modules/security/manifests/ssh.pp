class security::ssh (
  String $sshd_path     = lookup('security::sshd_config_path', { default_value => '/etc/ssh/sshd_config' }),
  String $package_name  = lookup('security::ssh_package_name', { default_value => 'openssh-server' }),
  String $service_name  = lookup('security::ssh_service_name', { default_value => 'ssh' }),
  String $validate_cmd  = lookup('security::sshd_validate_cmd', { default_value => '/usr/sbin/sshd -t -f %' }),
) {
  package { $package_name:
    ensure => installed,
  }

  file { $sshd_path:
    ensure       => file,
    owner        => 'root',
    group        => 'root',
    mode         => '0600',
    content      => lookup('security::sshd_config_content'),
    validate_cmd => $validate_cmd,
    notify       => Service[$service_name],
    require      => Package[$package_name],
  }

  service { $service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package[$package_name],
  }
}
