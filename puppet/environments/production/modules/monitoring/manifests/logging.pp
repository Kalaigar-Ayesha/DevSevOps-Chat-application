class monitoring::logging (
  String $promtail_package = lookup('monitoring::promtail_package', { default_value => 'promtail' }),
  String $promtail_config  = lookup('monitoring::promtail_config'),
) {
  package { $promtail_package:
    ensure => installed,
  }

  file { '/etc/promtail':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/promtail/config.yml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $promtail_config,
    notify  => Service['promtail'],
    require => File['/etc/promtail'],
  }

  service { 'promtail':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    hasrestart => true,
    require   => Package[$promtail_package],
  }
}
