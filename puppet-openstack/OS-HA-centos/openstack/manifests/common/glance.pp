# Common class for Glance installation
# Private, and should not be used on its own
# The purpose is to have basic Glance auth configuration options
# set so that services like Tempest can access credentials
# on the controller
class openstack::common::glance {
  if $::openstack::config::high_availability == "true" {
    $bind_host = $::openstack::config::controller_address_management
    $auth_host = $::openstack::config::controller_address_management
  }
  else {
    $bind_host = "0.0.0.0"
    $auth_host = "0.0.0.0"
  }
  class { '::glance::api':
    keystone_password   => $::openstack::config::glance_password,
    auth_host           => $auth_host,
    bind_host           => $bind_host,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    glance_username     => $::openstack::config::mysql_user_glance,
    database_connection => $::openstack::resources::connectors::glance,
    registry_host       => $::openstack::config::controller_address_management,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_storage,
    mysql_module        => '2.2',
    os_region_name      => $::openstack::config::region,
    host                 => $::openstack::config::haproxy_listen_ip,
  }
}
