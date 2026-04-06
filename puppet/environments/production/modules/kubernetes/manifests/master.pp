class kubernetes::master (
  String $pod_cidr = lookup('kubernetes::master::pod_cidr', { default_value => '10.244.0.0/16' }),
) {
  include kubernetes

  exec { 'kubeadm_init':
    command => "kubeadm init --pod-network-cidr=${pod_cidr} --upload-certs",
    creates => '/etc/kubernetes/admin.conf',
    path    => ['/usr/bin', '/bin'],
    require => Class['kubernetes'],
  }

  file { '/root/.kube':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  exec { 'copy_admin_kubeconfig':
    command => 'cp /etc/kubernetes/admin.conf /root/.kube/config && chown root:root /root/.kube/config',
    creates => '/root/.kube/config',
    path    => ['/usr/bin', '/bin'],
    require => [File['/root/.kube'], Exec['kubeadm_init']],
  }
}
