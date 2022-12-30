# The profile to set up a neutron ovs network router
class openstack::profile::neutron::router {
  Exec {
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    require => Class['openstack::profile::neutron::common'],
  }

  #::sysctl::value { 'net.ipv4.ip_forward':
  #  value     => '1',
  #}
  ::sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value     => '0',
  }
  ::sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value     => '0',
  }

  $controller_management_address = $::openstack::config::controller_address_management
  if $::openstack::config::high_availability == "true" {
    $vip_ip = $::openstack::config::haproxy_listen_ip
    $auth_url = "http://${vip_ip}:35357/v2.0"
    $metadata_ip = $vip_ip
  }
  else {
    $auth_url = "http://${controller_management_address}:35357/v2.0"
    $metadata_ip = $controller_management_address
  }
  include ::openstack::common::neutron
  include ::openstack::common::ovs

  ### Router service installation
  class { '::neutron::agents::l3':
    debug                    => $::openstack::config::debug,
    external_network_bridge  => 'br-ex',
    router_delete_namespaces => true,
    allow_automatic_l3agent_failover => true,
    enabled                  => true,
  }

  class { '::neutron::agents::dhcp':
    debug   => $::openstack::config::debug,
    dhcp_delete_namespaces => true,
    enabled => true,
  }

  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => $auth_url,
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
    metadata_ip   => $metadata_ip,
    enabled       => true,
  }

  #class { '::neutron::agents::lbaas':
  #  debug   => $::openstack::config::debug,
  #  enabled => true,
  #}

  #class { '::neutron::agents::vpnaas':
  #  enabled => true,
  #}

  #class { '::neutron::agents::metering':
  #  enabled => true,
  #}

  #class { '::neutron::services::fwaas':
  #  enabled => true,
  #}

  $external_bridge = 'br-ex'
  $external_network = $::openstack::config::network_external
  $external_device = device_for_network($external_network)
  vs_bridge { $external_bridge:
    ensure => present,
  }
  if $external_device != $external_bridge {
    vs_port { $external_device:
      ensure => present,
      bridge => $external_bridge,
    }
  } else {
    # External bridge already has the external device's IP, thus the external
    # device has already been linked
  }
}
