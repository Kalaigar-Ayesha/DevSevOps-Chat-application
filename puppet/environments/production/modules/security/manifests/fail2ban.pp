class security::fail2ban (
  String $jail_local_content = lookup('security::fail2ban::jail_local_content'),
) {
  package { 'fail2ban':
    ensure => installed,
  }

  file { '/etc/fail2ban/jail.local':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $jail_local_content,
    notify  => Service['fail2ban'],
    require => Package['fail2ban'],
  }

  service { 'fail2ban':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    hasrestart => true,
  }
}
