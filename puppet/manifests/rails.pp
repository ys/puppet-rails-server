$application = 'test'
$home = "/home/${application}"
$ruby_version = "1.9.3-p392"

group { $application:
  ensure => present,
}

user { $application:
  ensure   => present,
  gid      => $application,
  home     => $home,
  password => '$1$k5.UExnX$DIiUq/tcx8Uhj73FOzki8/',
  require  => Group[$application],
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

# yumrepo {
#   "nginx":
#     baseurl  => 'http://nginx.org/packages/centos/6/x86_64/',
#     gpgcheck => 0,
#     enabled  => 1;
#
#   "extra":
#     baseurl    => 'http://mirror.centos.org/centos/6/extras/x86_64/',
#     gpgcheck   => 1,
#     gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-5',
# }

node default {
  class { 'nginx':
    # require => Yumrepo['nginx'],
  }

  nginx::resource::upstream { 'proxypass':
    ensure  => present,
    members => [
      "unix:/${home}/apps/${application}/current/tmp/puma.sock",
    ],
  }
}
