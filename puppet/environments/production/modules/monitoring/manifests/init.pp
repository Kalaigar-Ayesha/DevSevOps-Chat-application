class monitoring (
  String $node_exporter_version = lookup('monitoring::node_exporter_version', { default_value => '1.8.1' }),
  String $node_exporter_user    = lookup('monitoring::node_exporter_user', { default_value => 'nodeexp' }),
) {
  group { $node_exporter_user:
    ensure => present,
    system => true,
  }

  user { $node_exporter_user:
    ensure     => present,
    system     => true,
    shell      => '/usr/sbin/nologin',
    managehome => false,
    gid        => $node_exporter_user,
    require    => Group[$node_exporter_user],
  }

  exec { 'download_node_exporter':
    command => "curl -L -o /tmp/node_exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-amd64.tar.gz",
    creates => "/usr/local/bin/node_exporter-${node_exporter_version}",
    path    => ['/usr/bin', '/bin'],
  }

  exec { 'install_node_exporter_binary':
    command => "tar -xzf /tmp/node_exporter.tar.gz -C /tmp && cp /tmp/node_exporter-${node_exporter_version}.linux-amd64/node_exporter /usr/local/bin/node_exporter-${node_exporter_version} && ln -sf /usr/local/bin/node_exporter-${node_exporter_version} /usr/local/bin/node_exporter",
    creates => '/usr/local/bin/node_exporter',
    path    => ['/usr/bin', '/bin'],
    require => Exec['download_node_exporter'],
  }

  file { '/etc/systemd/system/node_exporter.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @(UNIT)
      [Unit]
      Description=Prometheus Node Exporter
      Wants=network-online.target
      After=network-online.target

      [Service]
      User=${node_exporter_user}
      Group=${node_exporter_user}
      Type=simple
      ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100
      Restart=always
      RestartSec=5

      [Install]
      WantedBy=multi-user.target
      | UNIT
    notify  => Exec['systemd_daemon_reload'],
    require => Exec['install_node_exporter_binary'],
  }

  exec { 'systemd_daemon_reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => ['/usr/bin', '/bin'],
  }

  service { 'node_exporter':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    hasrestart => true,
    require   => [File['/etc/systemd/system/node_exporter.service'], Exec['systemd_daemon_reload']],
  }
}
