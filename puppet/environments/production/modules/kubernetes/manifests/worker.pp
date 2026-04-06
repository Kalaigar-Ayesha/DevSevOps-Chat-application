class kubernetes::worker (
  String $join_command = lookup('kubernetes::join_command'),
) {
  include kubernetes

  exec { 'kubeadm_join':
    command => "${join_command} --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables",
    creates => '/etc/kubernetes/kubelet.conf',
    path    => ['/usr/bin', '/bin'],
    require => Class['kubernetes'],
  }
}
