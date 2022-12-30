class glance::main {
   class { '::glance::db::mysql': }
   class { '::glance': }  
   class { '::glance::api':
      #require => Class['::glance::db::mysql'],
   }
   class { '::glance::registry': 
      #require => Class['::glance::api'],
   } 
   class { '::glance::notify::rabbitmq': 
      #require => Class['::glance::registry'],
   } 
   if $::openstack::config::high_availability == "false" {
         $vip_ip = $::openstack::config::haproxy_listen_ip
         class { '::glance::keystone::auth':
            password => $::openstack::config::glance_password,
            public_address => $vip_ip,
            admin_address => $vip_ip,
            internal_address => $vip_ip,
            region => $::openstack::config::region,
            #require => Class['::glance::db::mysql'],
      }
    }
    else {
         class { '::glance::keystone::auth':
            password => $::openstack::config::glance_password,
            public_address => hiera(castlight::storage::address::api),
            admin_address => hiera(castlight::storage::address::api),
            internal_address => hiera(castlight::storage::address::api),
            #region => $::openstack::config::region,
            #require => Class['::glance::db::mysql'],
      }
    }
   
}
