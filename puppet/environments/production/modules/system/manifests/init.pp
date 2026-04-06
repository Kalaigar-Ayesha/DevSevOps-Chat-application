class system (
  String $timezone = lookup('system::timezone', { default_value => 'UTC' }),
  String $sysctl_content = lookup('system::sysctl_content'),
  String $limits_content = lookup('system::limits_content'),
) {
  package { ['chrony', 'procps']:
    ensure => installed,
  }

  file { '/etc/timezone':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${timezone}\n",
    notify  => Exec['dpkg_reconfigure_tzdata'],
  }

  exec { 'dpkg_reconfigure_tzdata':
    command     => 'dpkg-reconfigure -f noninteractive tzdata',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }

  file { '/etc/sysctl.d/99-chat-platform.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $sysctl_content,
    notify  => Exec['sysctl_reload'],
  }

  exec { 'sysctl_reload':
    command     => 'sysctl --system',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
    require     => Package['procps'],
  }

  file { '/etc/security/limits.d/99-chat-platform.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $limits_content,
  }

  service { 'chrony':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    hasrestart => true,
    require   => Package['chrony'],
  }
}
