# The profile for installing the Swift Proxy
class openstack::profile::swift::proxy {

  openstack::resources::controller { 'swift': }
  openstack::resources::firewall { 'Swift Proxy': port => '8080', }

  if $::openstack::config::high_availability == "true" {
    $vip_ip = $::openstack::config::haproxy_listen_ip
    $public_address   = $vip_ip
    $admin_address    = $vip_ip
    $internal_address = $vip_ip
    $auth_host        = $vip_ip
  }
  else {
    $public_address   = $::openstack::config::controller_address_api
    $admin_address    = $::openstack::config::controller_address_management
    $internal_address = $::openstack::config::controller_address_management
    $auth_host        = $::openstack::config::controller_address_management
  }

  class { 'swift::keystone::auth':
    password         => $::openstack::config::swift_password,
    public_address   => $public_address,
    admin_address    => $admin_address,
    internal_address => $internal_address,
    region           => $::openstack::config::region,
  }

  class { '::swift':
    swift_hash_suffix => $::openstack::config::swift_hash_suffix,
    swift_hash_prefix => $::openstack::config::swift_hash_prefix,
  }

  # sets up the proxy service
  class { '::swift::proxy':
    proxy_local_net_ip => $::openstack::config::controller_address_api,
    pipeline           => [
                          'catch_errors',
                          'healthcheck',
                          'cache',
                          'ratelimit',
                          'swift3',
                          'authtoken',
                          'keystone',
                          'proxy-server'
                          ],
    account_autocreate => true,
    workers            => 1,
    require            => Class['::swift::ringbuilder'],
  }

  # Don't try to start the service if the ring device resources haven't been collected yet
  if !defined(ring_object_device) and !defined(ring_container_device) and !defined(ring_account_device) {
    Service <| title == 'swift-proxy' |> {
      ensure => stopped,
    }
  }

  ### BEGIN Middleware Configuration (declared in pipeline for proxy)
  class { [
          '::swift::proxy::catch_errors',
          '::swift::proxy::healthcheck',
          ]:
  }

  class { '::swift::proxy::cache':
    memcache_servers => [ "$::openstack::config::controller_address_management:11211", ]
  }

  class { [
          '::swift::proxy::ratelimit',
          '::swift::proxy::swift3',
          ]:
  }

  class { '::swift::proxy::authtoken':
    admin_user     => $::openstack::config::mysql_user_swift,
    admin_password => $::openstack::config::swift_password,
    auth_host      => $auth_host,
  }

  class { '::swift::proxy::keystone': }

  ### END Middleware Configuration
  
  # collect all of the resources that are needed to balance the ring
  Ring_object_device <<| |>>
  Ring_container_device <<| |>>
  Ring_account_device <<| |>>

  class { 'swift::ringbuilder':
    part_power     => 10,
    replicas       => size($::openstack::config::swift_servers),
    min_part_hours => 1,
    require        => Class['::swift'],
  }

  class { 'swift::ringserver':
    local_net_ip => $::openstack::config::controller_address_management,
  }

}
