# The profile to set up the Ceilometer API
# For co-located api and worker nodes this appear
# after openstack::profile::ceilometer::agent
class openstack::profile::ceilometer::api {
  openstack::resources::controller { 'ceilometer': }

  openstack::resources::firewall { 'Ceilometer API':
    port => '8777',
  }

  $vip_ip = $::openstack::config::haproxy_listen_ip
  $ceilometer_mgmt_ip = $::openstack::config::ceilometer_address_management

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "usr/local/bin/" ] }
 
  if $::openstack::config::high_availability == "true" {
    $public_address = $vip_ip
    $admin_address = $vip_ip
    $internal_address = $vip_ip

    Haproxy::Balancermember<||> -> Package['ceilometer-api']
    Service['haproxy'] -> Package['ceilometer-api']
    Haproxy::Balancermember<||> -> Exec<| title == 'ceilometer-dbsync' |>
    Service['haproxy'] -> Exec<| title == 'ceilometer-dbsync' |>
  }
  else {
    $public_address   = $::openstack::config::controller_address_api
    $admin_address    = $::openstack::config::controller_address_management
    $internal_address = $::openstack::config::controller_address_management
  }

  include ::openstack::common::ceilometer

  class { '::ceilometer::keystone::auth':
    password         => $::openstack::config::ceilometer_password,
    public_address   => $public_address,
    admin_address    => $admin_address,
    internal_address => $internal_address,
    region           => $::openstack::config::region,
    require          => [Class['::keystone::roles::admin']]
  }

  #class { '::ceilometer': 
  #  metering_secret  => 'true',
  #}
  class { '::ceilometer::agent::central':
      require    => Class['::openstack::common::ceilometer'],
  }

  class { '::ceilometer::expirer':
    time_to_live => '2592000'
  }

  # For the time being no upstart script are provided
  # in Ubuntu 12.04 Cloud Archive. Bug report filed
  # https://bugs.launchpad.net/cloud-archive/+bug/1281722
  # https://bugs.launchpad.net/ubuntu/+source/ceilometer/+bug/1250002/comments/5
  #if $::osfamily != 'Debian' {
  if $::osfamily == 'Debian' {
    class { '::ceilometer::alarm::notifier':
    }

    class { '::ceilometer::alarm::evaluator':
    }
  }

  class { '::ceilometer::collector': }

  class {'::mongodb::globals':
    manage_package_repo => true,
    bind_ip => $ceilometer_mgmt_ip
  }->
  class {'::mongodb': }->
  class {'::mongodb::client': }

  #mongodb_database { 'ceilometer':
  #  ensure  => present,
  #  tries   => 20,
  #  require => Class['mongodb::server'],
  #}

  $mongo_username = $::openstack::config::ceilometer_mongo_username
  $mongo_password = $::openstack::config::ceilometer_mongo_password

  if $mongo_username and $mongo_password {
    #mongodb_user { $mongo_username:
    #  ensure        => present,
    #  password_hash => mongodb_password($mongo_username, $mongo_password),
    #  database      => 'ceilometer',
    #  roles         => ['readWrite', 'dbAdmin'],
    #  tries         => 10,
    #  require       => [Class['mongodb::server'], Class['mongodb::client']],
    #  before        => Exec['ceilometer-dbsync'],
    #}
    exec {"create_mongoDB_and_user":
      command => "mongo --host ${ceilometer_mgmt_ip} --eval 'db = db.getSiblingDB(\"ceilometer\"); db.createUser({user: \"${mongo_username}\",pwd: \"${mongo_password}\", roles: [ \"readWrite\", \"dbAdmin\" ]})'",
      unless  => "mongo --host ${ceilometer_mgmt_ip} --eval 'db = db.getSiblingDB(\"ceilometer\"); db.getUser(\"${mongo_username}\")' | grep object",
      require => [Class['::mongodb::server'], Class['::mongodb::client']]
    }
  }

  #Class['::mongodb::server'] -> Class['::mongodb::client']
  Class['::mongodb::server'] -> Class['::mongodb::client'] -> Exec['create_mongoDB_and_user'] -> Exec['ceilometer-dbsync']
  #$mongo_members = $::openstack::config::ceilometer_mongodb_replset_members

}
