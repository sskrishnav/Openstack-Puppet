#class openstack::role::controller inherits ::openstack::role {
#  class { '::openstack::profile::firewall': }
#  class { '::openstack::profile::rabbitmq': } ->
#  class { '::openstack::profile::memcache': } ->
#  class { '::openstack::profile::mysql': } ->
#  class { '::openstack::profile::mongodb': } ->
#  class { '::openstack::profile::keystone': } ->
#  class { '::openstack::profile::swift::proxy': } ->
#  class { '::openstack::profile::ceilometer::api': } ->
#  class { '::openstack::profile::glance::auth': } ->
#  class { '::openstack::profile::cinder::api': } ->
#  class { '::openstack::profile::nova::api': } ->
#  class { '::openstack::profile::neutron::server': } ->
#  class { '::openstack::profile::neutron::router': } ->
#  class { '::openstack::profile::heat::api': } ->
#  class { '::openstack::profile::horizon': }
#  class { '::openstack::profile::auth_file': }
#}


class openstack::role::high_availability inherits ::openstack::role {
  if $::hostname =~ /^[\w-]+1$/ {
      $priority = 101
  }
  else {
      $priority = 100
  }
  class { "::openstack::profile::keepalived" : priority => "$priority", } 
  include ::openstack::profile::haproxy
  include ::openstack::profile::firewall
  include ::openstack::profile::galera

  anchor {"ha::start":}
  anchor {"ha::end":}
  
  Anchor [ "ha::start" ] ->
  Class [ "::openstack::profile::keepalived" ] ->
  Class [ "::openstack::profile::haproxy" ] ->
  Class [ "::openstack::profile::galera" ] ->
  Anchor [ "ha::end" ]
}
