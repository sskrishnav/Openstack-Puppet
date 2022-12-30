# Common class for cinder installation
# Private, and should not be used on its own
class openstack::common::cinder {
  if $::openstack::config::high_availability == "true" {
    $storage_server = $::openstack::config::haproxy_listen_ip
    class { '::cinder':
      database_connection => $::openstack::resources::connectors::cinder,
      rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
      rabbit_userid       => $::openstack::config::rabbitmq_user,
      rabbit_password     => $::openstack::config::rabbitmq_password,
      debug               => $::openstack::config::debug,
      verbose             => $::openstack::config::verbose,
      mysql_module        => '2.2',
    }
  }
  else {
    $storage_server = $::openstack::config::storage_address_api
    class { '::cinder':
      database_connection => $::openstack::resources::connectors::cinder,
      rabbit_host         => $::openstack::config::controller_address_management,
      rabbit_userid       => $::openstack::config::rabbitmq_user,
      rabbit_password     => $::openstack::config::rabbitmq_password,
      debug               => $::openstack::config::debug,
      verbose             => $::openstack::config::verbose,
      mysql_module        => '2.2',
    }
  }

  $glance_api_server = "${storage_server}:9292"

  class { '::cinder::glance':
    glance_api_servers => [ $glance_api_server ],
  }
}
