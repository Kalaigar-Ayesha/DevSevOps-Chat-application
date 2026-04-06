class users (
  String $devops_user       = lookup('users::devops_user', { default_value => 'devops' }),
  String $devops_shell      = lookup('users::devops_shell', { default_value => '/bin/bash' }),
  Array[String] $ssh_keys   = lookup('users::devops_ssh_public_keys'),
) {
  group { $devops_user:
    ensure => present,
  }

  user { $devops_user:
    ensure     => present,
    shell      => $devops_shell,
    managehome => true,
    gid        => $devops_user,
    groups     => ['sudo', 'docker'],
    require    => Group[$devops_user],
  }

  file { "/home/${devops_user}/.ssh":
    ensure  => directory,
    owner   => $devops_user,
    group   => $devops_user,
    mode    => '0700',
    require => User[$devops_user],
  }

  file { "/home/${devops_user}/.ssh/authorized_keys":
    ensure  => file,
    owner   => $devops_user,
    group   => $devops_user,
    mode    => '0600',
    content => "${join($ssh_keys, "\n")}\n",
    require => File["/home/${devops_user}/.ssh"],
  }
}
