# Common class for nova installation
# Private, and should not be used on its own
# usage: include from controller, declare from worker
# This is to handle dependency
# depends on openstack::profile::base having been added to a node
class openstack::common::nova ($is_compute    = false) {
  $is_controller = $::openstack::profile::base::is_controller

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $storage_management_address = $::openstack::config::storage_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  if $::openstack::config::high_availability == "true" {
    $network_nova_ip = $::openstack::config::haproxy_listen_ip
    $api_bind_address = $::openstack::config::controller_address_management
    $metadata_listen = $::openstack::config::controller_address_management
  }
  else {
    $network_nova_ip = $::openstack::config::controller_address_management
    $api_bind_address = "0.0.0.0"
    $metadata_listen = "0.0.0.0"
  }

  class { '::nova':
    database_connection => $::openstack::resources::connectors::nova,
    glance_api_servers  => join($::openstack::config::glance_api_servers, ','),
    memcached_servers   => ["${controller_management_address}:11211"],
    rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
    mysql_module        => '2.2',
  }

  nova_config { 'DEFAULT/default_floating_pool': value => 'public' }

  class { '::nova::api':
    admin_password                       => $::openstack::config::nova_password,
    auth_host                            => $controller_management_address,
    enabled                              => $is_controller,
    neutron_metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    api_bind_address                     => $api_bind_address,
    metadata_listen                      => $metadata_listen,
  }

  class { '::nova::vncproxy':
    host    => $::openstack::config::controller_address_api,
    enabled => $is_controller,
  }

  if $is_controller {
    class { [
      'nova::scheduler',
      'nova::objectstore',
      'nova::cert',
      'nova::consoleauth',
      'nova::conductor'
    ]:
      enabled => $is_controller,
    }
  }

  # TODO: it's important to set up the vnc properly
  class { '::nova::compute':
    enabled                       => $is_compute,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $::openstack::config::controller_address_api,
  }

  class { '::nova::compute::neutron': }

  #class { '::nova::network::neutron':
  #  neutron_admin_password => $::openstack::config::neutron_password,
  #  neutron_region_name    => $::openstack::config::region,
  #  neutron_admin_auth_url => "http://${network_nova_ip}:35357/v2.0",
  #  neutron_url            => "http://${network_nova_ip}:9696",
  #  vif_plugging_is_fatal  => false,
  #  vif_plugging_timeout   => '0',
  #}
}
