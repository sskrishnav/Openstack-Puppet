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


class openstack::role::controller inherits ::openstack::role { 
  
  include ::openstack::role::high_availability
  include ::openstack::profile::rabbitmq
  include ::openstack::profile::memcache
  include ::openstack::profile::keystone
  include ::openstack::profile::swift::proxy
  class {'::openstack::profile::swift::storage': zone => '1'}
  include ::openstack::profile::ceilometer::api
  include ::openstack::profile::glance::auth
  include ::openstack::profile::nova::api
  include ::openstack::profile::neutron::server
  include ::openstack::profile::neutron::router
  include ::openstack::profile::cinder::api
  include ::openstack::profile::cinder::volume
  include ::openstack::profile::heat::api
  include ::openstack::profile::auth_file

  anchor { 'os::role::begin': }
  anchor { 'os::role::end': }
  
  Anchor [ 'os::role::begin' ] ->
  Class [ '::openstack::role::high_availability' ] ->
  Class [ '::openstack::profile::rabbitmq' ] -> 
  Class [ '::openstack::profile::memcache' ] ->
  Class [ '::openstack::profile::keystone' ] ->
  Class [ '::openstack::profile::swift::proxy' ] ->
  Class [ '::openstack::profile::swift::storage' ] ->
  Class [ '::openstack::profile::ceilometer::api' ] ->
  Class [ '::openstack::profile::glance::auth' ] ->
  Class [ '::openstack::profile::nova::api' ] -> 
  Class [ '::openstack::profile::neutron::server' ] ->
  Class [ '::openstack::profile::neutron::router' ] ->
  Class [ '::openstack::profile::cinder::api' ] ->
  Class [ '::openstack::profile::cinder::volume' ] ->
  Class [ '::openstack::profile::heat::api' ] ->
  Class [ '::openstack::profile::auth_file' ] ->
  Anchor [ 'os::role::end' ] 

  #class { '::openstack::profile::rabbitmq': } ->
  #class { '::openstack::profile::memcache': } ->
  #class { '::openstack::profile::keystone': } ->
  #class { '::openstack::profile::glance::auth': } ->
  #class { '::openstack::profile::nova::api': } ->
  #class { '::openstack::profile::neutron::server': } ->
  #class { '::openstack::profile::neutron::router': } ->
  #class { '::openstack::profile::auth_file': }
}
