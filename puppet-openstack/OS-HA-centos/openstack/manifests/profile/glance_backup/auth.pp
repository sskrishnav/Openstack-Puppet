# openstack::profile::glance::auth file
class openstack::profile::glance::auth {

   openstack::resources::database { 'glance': }
   #include ::glance
   #class { '::glance::db::mysql': 
   #   password      => $::openstack::config::mysql_pass_glance,
   #   dbname        => 'glance',
   #   user          => $::openstack::config::mysql_user_glance,
   #   host          => $::openstack::config::controller_address_management,
   #   allowed_hosts => $::openstack::config::mysql_allowed_hosts,
   #}
   
   class { '::glance': }  
  
   if $::openstack::config::high_availability == "true" {
         $vip_ip = $::openstack::config::haproxy_listen_ip
         class { '::glance::keystone::auth':
            password => $::openstack::config::glance_password,
            public_address => $vip_ip,
            admin_address => $vip_ip,
            internal_address => $vip_ip,
            region => $::openstack::config::region,
            require => [Class['::keystone::roles::admin']]
      }
    }
    else {
         class { '::glance::keystone::auth':
            password => $::openstack::config::glance_password,
            public_address => $::openstack::config::storage_address_api,
            admin_address => $::openstack::config::storage_address_api,
            internal_address => $::openstack::config::storage_address_api,
            region => $::openstack::config::region,
            require => [Class['::keystone::roles::admin']]
      }
    }

    class { '::openstack::profile::glance::registry':
        #require => Class['::glance::db::mysql'],
    }
    class { '::openstack::profile::glance::api':
        #require => Class['::glance::db::mysql'],
    }
   
}
