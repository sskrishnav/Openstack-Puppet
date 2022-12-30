# Common class for neutron installation
# Private, and should not be used on its own
# Sets up configuration common to all neutron nodes.
# Flags install individual services as needed
# This follows the suggest deployment from the neutron Administrator Guide.
class openstack::common::neutron {
  $controller_management_address = $::openstack::config::controller_address_management

  $data_network = $::openstack::config::network_data
  $data_address = ip_for_network($data_network)

  # neutron auth depends upon a keystone configuration
  if $::openstack::profile::base::is_controller {
    include ::openstack::common::keystone
  }

  if $::openstack::config::high_availability == "true" {
    $bind_host        = $::openstack::config::controller_address_management
    $vip_ip           = $::openstack::config::haproxy_listen_ip
    $public_address   = $vip_ip
    $admin_address    = $vip_ip
    $internal_address = $vip_ip
    $rabbitmq_hosts   = $::openstack::config::rabbitmq_hosts
  }
  else {
    $bind_host = "0.0.0.0"
    $public_address   = $::openstack::config::controller_address_api
    $admin_address    = $::openstack::config::controller_address_management
    $internal_address = $::openstack::config::controller_address_management
    $rabbitmq_hosts   = false
  }

  class { '::neutron':
    rabbit_host           => $controller_management_address,
    bind_host             => $bind_host,
    core_plugin           => $::openstack::config::neutron_core_plugin,
    allow_overlapping_ips => true,
    rabbit_user           => $::openstack::config::rabbitmq_user,
    rabbit_password       => $::openstack::config::rabbitmq_password,
    rabbit_hosts          => $rabbitmq_hosts,
    debug                 => $::openstack::config::debug,
    verbose               => $::openstack::config::verbose,
    service_plugins       => $::openstack::config::neutron_service_plugins,
  }

  if $::openstack::profile::base::is_controller {
    class { '::neutron::keystone::auth':
      password         => $::openstack::config::neutron_password,
      public_address   => $public_address,
      admin_address    => $admin_address,
      internal_address => $internal_address,
      region           => $::openstack::config::region,
      require          => [Class['::keystone::roles::admin']]
    }
  }

  class { '::neutron::server':
    auth_url            => "http://${$internal_address}:35357",
    auth_uri            => "http://${$internal_address}:5000",
    auth_password       => $::openstack::config::neutron_password,
    database_connection => $::openstack::resources::connectors::neutron,
    enabled             => $::openstack::profile::base::is_controller,
    sync_db             => $::openstack::profile::base::is_controller,
    mysql_module        => '2.2',
    allow_automatic_l3agent_failover => True,
    l3_ha                            => True,
    max_l3_agents_per_router         => $::openstack::config::max_l3_agents_per_router,
    min_l3_agents_per_router         => $::openstack::config::min_l3_agents_per_router,
  }

  class { '::neutron::server::notifications':
    nova_url            => "http://${internal_address}:8774/v2",
    nova_admin_auth_url => "http://${internal_address}:35357",
    nova_admin_password => $::openstack::config::nova_password,
    nova_region_name    => $::openstack::config::region,
  }

  class { '::nova::network::neutron' :
    neutron_admin_password => $::openstack::config::neutron_password,
    neutron_url            => "http://${internal_address}:9696",
    neutron_admin_auth_url => "http://${internal_address}:35357/v2.0",
  }


  if $::osfamily == 'redhat' {
    package { 'iproute':
        ensure => latest,
        before => Class['::neutron']
    }
  }
}
