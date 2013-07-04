$application = 'pragprog_magazines'
$home = "/home/${application}"
$ruby_version = "2.0.0-p195"

group { $application:
  ensure => present,
}

user { $application:
  ensure   => present,
  gid      => $application,
  home     => $home,
  require  => Group[$application],
  shell    => "/bin/bash",
}

file {
  $home:
    ensure  => directory,
    require => User[$application],
    owner   => $application,
    group   => $application;

  "${home}/.ssh":
    ensure  => directory,
    require => File[$home],
    owner   => $application,
    group   => $application,
    mode    => 640;

  "${home}/apps":
    ensure => directory,
    owner  => $application,
    group  => $application;
}

ssh_authorized_key { 'yannick.schutz@gmail.com':
  ensure  => present,
  key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDyhMz1RdFMiKuDcRzLtuHKMFcEiEKMVCj19YTgo3+d6dzEgc0hlSNmVTob09qw4SgbuPNHNGaFbBNE+LNu6Gb5HNS7fpnDfcVMUTUaXjB0vyh2cZmRVQvo46csxiMI7UZd//C3P54IForFG00+CXS3JNrKYtX2NM3xAVXjmNNVtgukg8lm7JUO85MTZ5PkJGb51IdK7WRK0SMqOef1Q7H8Rl0gGA1d/tVtxAh2FHDy8VcmXejBfVnGk7h1O+PBs6FP5xsNfAJyXCKB6WiO6ek4flfiDrCjQhhZqk2UvBGnNIjJ0WHRePjeYz1ra9alYhXO57iX9ixqFrSjV2VbQQtP',
  type    => rsa,
  user    => $application,
  require => File["${home}/.ssh"],
}

rbenv::install { $application:
  group => $application,
  home  => $home
}

rbenv::compile { $ruby_version:
  user   => $application,
  home   => $home,
  global => true,
}

package { 'nodejs':
  ensure => present,
}

class { 'nginx': }

nginx::resource::vhost { 'localhost':
  ensure   => present,
  proxy  => "http://${application}",
}

nginx::resource::upstream { $application:
  ensure  => present,
  members => [
    "unix:${home}/apps/${application}/tmp/unicorn.sock",
  ],
}
