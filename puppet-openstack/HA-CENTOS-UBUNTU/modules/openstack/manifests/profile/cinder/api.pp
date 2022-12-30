# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  openstack::resources::controller { 'cinder': }
  openstack::resources::database { 'cinder': }
  openstack::resources::firewall { 'Cinder API': port => '8776', }

  if $::openstack::config::high_availability == "true" {
      $vip_ip = $::openstack::config::haproxy_listen_ip
      class { '::cinder::keystone::auth':
        password         => $::openstack::config::cinder_password,
        public_address   => $vip_ip,
        admin_address    => $vip_ip,
        internal_address => $vip_ip,
        region           => $::openstack::config::region,
      }
      if $::osfamily == 'Debian' {
        Haproxy::Balancermember<||> -> Package['cinder-common']
        Service['haproxy'] -> Package['cinder-common']
        Haproxy::Balancermember<||> -> Package['cinder-api']
        Service['haproxy'] -> Package['cinder-api']
        Haproxy::Balancermember<||> -> Exec<| title == 'cinder-manage db_sync' |>
        Service['haproxy'] -> Exec<| title == 'cinder-manage db_sync' |>
      }
      if $::osfamily == 'RedHat' {
        Haproxy::Balancermember<||> -> Package['openstack-cinder']
        Service['haproxy'] -> Package['openstack-cinder']
        #Haproxy::Balancermember<||> -> Package['cinder-api']
        #Service['haproxy'] -> Package['cinder-api']
        Haproxy::Balancermember<||> -> Exec<| title == 'cinder-manage db sync' |>
        Service['haproxy'] -> Exec<| title == 'cinder-manage db sync' |>
      }
  }
  else {
      class { '::cinder::keystone::auth':
        password         => $::openstack::config::cinder_password,
        public_address   => $::openstack::config::controller_address_api,
        admin_address    => $::openstack::config::controller_address_management,
        internal_address => $::openstack::config::controller_address_management,
        region           => $::openstack::config::region,
        require          => [Class['::keystone::roles::admin']]
      }
  }

  include ::openstack::common::cinder

  if $::openstack::config::high_availability == "true" {
    $bind_host = $::openstack::config::controller_address_management
  }

  class { '::cinder::api':
    keystone_password  => $::openstack::config::cinder_password,
    keystone_auth_host => $::openstack::config::controller_address_management,
    enabled            => true,
    bind_host          => pick($bind_host, "0.0.0.0"),
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    enabled          => true,
  }
}
