# Common class for ceilometer installation
# Private, and should not be used on its own
class openstack::common::ceilometer {
  $is_controller = $::openstack::profile::base::is_controller

  $vip_ip = $::openstack::config::haproxy_listen_ip
 
  $ceilometer_management_address = $::openstack::config::ceilometer_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  $mongo_username = $::openstack::config::ceilometer_mongo_username
  $mongo_password = $::openstack::config::ceilometer_mongo_password

  if $::openstack::config::high_availability == "true" {
    $keystone_host = $vip_ip
    $auth_url = "http://${vip_ip}:5000/v2.0"
    $host = $ceilometer_management_address
  #  $ceilometer_management_address = $vip_ip
  #  $controller_management_address = $vip_ip
  }
  else {
    $keystone_host = $::openstack::config::controller_address_management
    $auth_url = "http://localhost:5000/v2.0"
    $host = "0.0.0.0"
  #  $ceilometer_management_address = $::openstack::config::ceilometer_address_management
  #  $controller_management_address = $::openstack::config::controller_address_management
  }

  if ! $mongo_username or ! $mongo_password {
    $mongo_connection = "mongodb://${ceilometer_management_address}:27017/ceilometer"
  } else {
    $mongo_connection = "mongodb://${mongo_username}:${mongo_password}@${ceilometer_management_address}:27017/ceilometer"
    #$mongo_connection = "mongodb://${mongo_username}:${mongo_password}@${vip_ip}:27017/ceilometer"
  }

  class { '::ceilometer':
    metering_secret => $::openstack::config::ceilometer_meteringsecret,
    debug           => $::openstack::config::debug,
    verbose         => $::openstack::config::verbose,
    rabbit_hosts    => $::openstack::config::rabbitmq_hosts,
    rabbit_userid   => $::openstack::config::rabbitmq_user,
    rabbit_password => $::openstack::config::rabbitmq_password,
  }

  class { '::ceilometer::api':
    enabled           => $is_controller,
    host              => $host,
    keystone_host     => $keystone_host,
    keystone_password => $::openstack::config::ceilometer_password,
  }

  class { '::ceilometer::db':
    database_connection => $mongo_connection,
    mysql_module        => '2.2',
  }

  class { '::ceilometer::agent::auth':
    auth_url      => $auth_url,
    auth_password => $::openstack::config::ceilometer_password,
    auth_region   => $::openstack::config::region,
  }
}

