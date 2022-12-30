#class nova api
class openstack::profile::nova::api {

    include openstack::common::nova
    class { '::nova::db::mysql':
       password   => $::openstack::config::mysql_pass_nova,
       host       => $::openstack::config::controller_address_management,
       allowed_hosts => $::openstack::config::mysql_allowed_hosts,
    }

    if $::openstack::config::high_availability == "true" {
         $vip_ip = $::openstack::config::haproxy_listen_ip
         class { '::nova::keystone::auth':
            password => $::openstack::config::nova_password,
            public_address => $vip_ip,
            admin_address => $vip_ip,
            internal_address => $vip_ip,
            region => $::openstack::config::region,
            require => [Class['::keystone::roles::admin'], Class['::nova::db::mysql']],
      }
      Haproxy::Balancermember<||> -> Package['nova-api']
      Service['haproxy'] -> Package['nova-api']
      Haproxy::Balancermember<||> -> Exec<| title == 'nova-db-sync' |>
      Service['haproxy'] -> Exec<| title == 'nova-db-sync' |>
    }
    else {
         class { '::nova::keystone::auth':
            password => $::openstack::config::nova_password,
            public_address => hiera(castlight::storage::address::api),
            admin_address => hiera(castlight::storage::address::api),
            internal_address => hiera(castlight::storage::address::api),
            region => $::openstack::config::region,
            require => [Class['::keystone::roles::admin'], Class['::nova::db::mysql']],
      }
    }

} 
