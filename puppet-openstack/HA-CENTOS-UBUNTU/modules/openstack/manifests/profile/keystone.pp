# The profile to install the Keystone service
class openstack::profile::keystone {
  
  class { '::keystone::package': }
  include openstack::common::keystone

  if $::osfamily == 'RedHat' {
     $value = "-centos"
  }
  elsif $::osfamily == 'Debian' {
     $value = ""
  }
  class { "::keystone::apache-wsgi${$value}":
     require => Class['::keystone::package'],
  }
  

  class { '::keystone::db::mysql' :
      password      => $::openstack::config::mysql_pass_keystone,
      dbname        => 'keystone',
      user          => $::openstack::config::mysql_user_keystone,
      host          => $::openstack::config::controller_address_management,
      allowed_hosts => $::openstack::config::mysql_allowed_hosts,
      #require => Class['::keystone::apache-wsgi'],
      require => Class["::keystone::apache-wsgi${$value}"],
  }

  class { '::keystone::cron::token_flush':
      #require => Class['::keystone::db::sync'],
      require => Class['::keystone::db::mysql'],
  }

  $vip_ip = $::openstack::config::haproxy_listen_ip
  class { 'keystone::endpoint':
     host           => $::openstack::config::controller_address_management,
     public_address => $vip_ip,
     admin_address => $vip_ip,
     internal_address => $vip_ip,
     region => $::openstack::config::region,
     require => Class['::keystone::db::mysql'],
  }
  if $::osfamily == 'Debian' {
      Haproxy::Balancermember<||> -> Package['keystone']
      Service['haproxy'] -> Package['keystone']
      Haproxy::Balancermember<||> -> Exec<| title == 'keystone-manage db_sync' |>
      Service['haproxy'] -> Exec<| title == 'keystone-manage db_sync' |>
  } 
  elsif $::osfamily == 'RedHat' {
      Haproxy::Balancermember<||> -> Package['openstack-keystone']
      Service['haproxy'] -> Package['openstack-keystone']
      Haproxy::Balancermember<||> -> Exec<| title == 'keystone-manage db_sync' |>
      Service['haproxy'] -> Exec<| title == 'keystone-manage db_sync' |>
  }
}
