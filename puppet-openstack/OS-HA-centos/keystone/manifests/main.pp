class keystone::main {

  class { '::keystone': }
  class { '::keystone::apache-wsgi':
     require => Class['::keystone'] ,
  }

  class { '::keystone::cron::token_flush':
      require => Class['::keystone::db::sync'],
  }
  class { '::keystone::db::sync' :
      #password => 'secret',
      require => Class['::keystone'],
  }

  class { '::keystone::roles::admin':
    email    => 'test@example.tld',
    password => 'admin_pass',
    require  => Class['::keystone::db::sync'],
  }
  if $::openstack::config::high_availability == "false" {
      $vip_ip = $::openstack::config::haproxy_listen_ip
      class { 'keystone::endpoint':
         public_address => $vip_ip,
         admin_address => $vip_ip,
         internal_address => $vip_ip,
         region => $::openstack::config::region,
         require => Class['::keystone::roles::admin'],
       }
  }
  else {
      class { 'keystone::endpoint':
         #public_address => $::openstack::config::controller_address_api,
         #admin_address => $::openstack::config::controller_address_management,
         #internal_address => $::openstack::config::controller_address_management,
         #region => $::openstack::config::region,
         public_address => hiera(castlight::storage::address::api),
         admin_address => hiera(castlight::storage::address::api),
         internal_address => hiera(castlight::storage::address::api),
         require => Class['::keystone::roles::admin'],
      }
  }
  notice("$public_address, $admin_address, $internal_address, $region")
}
