# The profile to install the Keystone service
class openstack::profile::keystone {
  
  class { '::keystone::package': }
  include openstack::common::keystone
  class { '::keystone::apache-wsgi':
     require => Class['::keystone::package'],
  }

  #$keystone_pass = $::openstack::config::keystone_admin_password

  #class { '::keystone::db::sync' :
  #    password      => $::openstack::config::mysql_pass_keystone,
  #    dbname        => 'keystone',
  #    user          => $::openstack::config::mysql_user_keystone,
  #    host          => $::openstack::config::controller_address_management,
  #    require => Class['::keystone::apache-wsgi'],
  #}

  class { '::keystone::db::mysql' :
      password      => $::openstack::config::mysql_pass_keystone,
      dbname        => 'keystone',
      user          => $::openstack::config::mysql_user_keystone,
      host          => $::openstack::config::controller_address_management,
      allowed_hosts => $::openstack::config::mysql_allowed_hosts,
      require => Class['::keystone::apache-wsgi'],
  }

  class { '::keystone::cron::token_flush':
      #require => Class['::keystone::db::sync'],
      require => Class['::keystone::db::mysql'],
  }

  #class { '::keystone::roles::admin':
  #  email    => 'test@example.tld',
  #  password => "${keystone_pass}",
  #  require  => Class['keystone::endpoint'],
  #}

  if $::openstack::config::high_availability == "true" {
      $vip_ip = $::openstack::config::haproxy_listen_ip
      class { 'keystone::endpoint':
         host           => $::openstack::config::controller_address_management,
         public_address => $vip_ip,
         admin_address => $vip_ip,
         internal_address => $vip_ip,
         region => $::openstack::config::region,
         #require => Class['::keystone::db::sync'],
         require => Class['::keystone::db::mysql'],
      }   
      Haproxy::Balancermember<||> -> Package['keystone']
      Service['haproxy'] -> Package['keystone']
      Haproxy::Balancermember<||> -> Exec<| title == 'keystone-manage db_sync' |>
      Service['haproxy'] -> Exec<| title == 'keystone-manage db_sync' |>
  }
  else {
      class { 'keystone::endpoint':
         host          => $::openstack::config::controller_address_management,
         public_address => $::openstack::config::controller_address_api,
         admin_address => $::openstack::config::controller_address_management,
         internal_address => $::openstack::config::controller_address_management,
         region => $::openstack::config::region,
         #require => Class['::keystone::db::sync'],
         require => Class['::keystone::db::mysql'],
      }
  }

}
