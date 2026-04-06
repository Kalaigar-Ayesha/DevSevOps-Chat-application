class security::firewall (
  Array[String] $allowed_tcp_ports = lookup('security::allowed_tcp_ports', { default_value => ['22'] }),
) {
  package { 'ufw':
    ensure => installed,
  }

  exec { 'ufw_default_deny_incoming':
    command => 'ufw default deny incoming',
    unless  => 'ufw status verbose | grep -q "Default: deny (incoming)"',
    path    => ['/usr/sbin', '/usr/bin', '/bin'],
    require => Package['ufw'],
  }

  exec { 'ufw_default_allow_outgoing':
    command => 'ufw default allow outgoing',
    unless  => 'ufw status verbose | grep -q "Default: deny (incoming), allow (outgoing)"',
    path    => ['/usr/sbin', '/usr/bin', '/bin'],
    require => Package['ufw'],
  }

  $allowed_tcp_ports.each |String $port| {
    exec { "ufw_allow_tcp_${port}":
      command => "ufw allow ${port}/tcp",
      unless  => "ufw status numbered | grep -q '${port}/tcp'",
      path    => ['/usr/sbin', '/usr/bin', '/bin'],
      require => Exec['ufw_default_deny_incoming'],
    }
  }

  exec { 'ufw_enable':
    command => 'ufw --force enable',
    unless  => 'ufw status | grep -q "Status: active"',
    path    => ['/usr/sbin', '/usr/bin', '/bin'],
    require => Exec['ufw_default_allow_outgoing'],
  }
}
