# Deprecated. The profile to set up the Glance registry
class openstack::profile::glance::registry {

    class { '::glance::registry':
      keystone_password    => $::openstack::config::glance_password,
      bind_host            => $::openstack::config::controller_address_management,
      glance_username      => $::openstack::config::mysql_user_glance,
      host                 => $::openstack::config::haproxy_listen_ip,
      database_connection  => $::openstack::resources::connectors::glance,
    } 
    class { '::glance::notify::rabbitmq':
      rabbit_password      => $::openstack::config::rabbitmq_password,
      rabbit_userid        => $::openstack::config::rabbitmq_user,
      rabbit_hosts         => $::openstack::config::rabbitmq_hosts,
      require              => Class['::glance::registry'],
   }
    
}
