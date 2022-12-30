# The profile to install an OpenStack specific mysql server
class openstack::profile::auth_file {
  if $::openstack::config::high_availability == "true" {
    $auth_ip = $::openstack::config::haproxy_listen_ip
  }
  else {
    $auth_ip = $::openstack::config::controller_address_api
  }

  class { '::openstack::resources::auth_file':
    admin_tenant    => 'admin',
    admin_password  => $::openstack::config::keystone_admin_password,
    region_name     => $::openstack::config::region,
    controller_node => $auth_ip,
  }
}
