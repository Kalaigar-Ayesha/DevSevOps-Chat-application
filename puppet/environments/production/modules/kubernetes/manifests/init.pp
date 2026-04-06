class kubernetes (
  String $version             = lookup('kubernetes::version', { default_value => '1.29.4-1.1' }),
  String $container_runtime   = lookup('kubernetes::container_runtime', { default_value => 'remote' }),
  Optional[String] $join_cmd  = lookup('kubernetes::join_command', { default_value => undef }),
) {
  package { ['apt-transport-https', 'ca-certificates', 'curl', 'gnupg']:
    ensure => installed,
  }

  exec { 'kubernetes_apt_key':
    command => 'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg',
    creates => '/etc/apt/keyrings/kubernetes-apt-keyring.gpg',
    path    => ['/usr/bin', '/bin'],
    require => Package['curl'],
  }

  file { '/etc/apt/sources.list.d/kubernetes.list':
    ensure  => file,
    content => "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec['kubernetes_apt_key'],
  }

  exec { 'apt_update_kubernetes_repo':
    command     => 'apt-get update',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => File['/etc/apt/sources.list.d/kubernetes.list'],
  }

  package { ['kubelet', 'kubeadm', 'kubectl']:
    ensure  => $version,
    require => Exec['apt_update_kubernetes_repo'],
  }

  exec { 'hold_kubernetes_packages':
    command => 'apt-mark hold kubelet kubeadm kubectl',
    unless  => 'apt-mark showhold | grep -E "kubelet|kubeadm|kubectl"',
    path    => ['/usr/bin', '/bin'],
    require => Package['kubelet'],
  }

  file { '/etc/default/kubelet':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock\n",
    notify  => Service['kubelet'],
  }

  service { 'kubelet':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    hasrestart => true,
    require   => Package['kubelet'],
  }
}
