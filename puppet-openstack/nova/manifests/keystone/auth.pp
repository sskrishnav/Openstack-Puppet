# == Class: nova::keystone::auth
#
# Creates nova endpoints and service account in keystone
#
# === Parameters:
#
# [*password*]
#   Password to create for the service user
#
# [*auth_name*]
#   (optional) The name of the nova service user
#   Defaults to 'nova'
#
# [*auth_name_v3*]
#   (optional) The name of the nova v3 service user
#   Defaults to 'novav3'
#
# [*service_name*]
#   (optional) Name of the service.
#   Defaults to the value of auth_name.
#
# [*service_name_v3*]
#   (optional) Name of the v3 service.
#   Defaults to the value of auth_name_v3.
#
# [*public_address*]
#   (optional) The public nova-api endpoint
#   Defaults to '127.0.0.1'
#
# [*admin_address*]
#   (optional) The admin nova-api endpoint
#   Defaults to '127.0.0.1'
#
# [*internal_address*]
#   (optional) The internal nova-api endpoint
#   Defaults to '127.0.0.1'
#
# [*compute_port*]
#   (optional) The port to use for the compute endpoint
#   Defaults to '8774'
#
# [*ec2_port*]
#   (optional) The port to use for the ec2 endpoint
#   Defaults to '8773'
#
# [*compute_version*]
#   (optional) The version of the compute api to put in the endpoint
#   Defaults to 'v2'
#
# [*region*]
#   (optional) The region in which to place the endpoints
#   Defaults to 'RegionOne'
#
# [*tenant*]
#   (optional) The tenant to use for the nova service user
#   Defaults to 'services'
#
# [*email*]
#   (optional) The email address for the nova service user
#   Defaults to 'nova@localhost'
#
# [*configure_ec2_endpoint*]
#   (optional) Whether to create an ec2 endpoint
#   Defaults to true
#
# [*configure_endpoint*]
#   (optional) Whether to create the endpoint.
#   Defaults to true
#
# [*configure_endpoint_v3*]
#   (optional) Whether to create the v3 endpoint.
#   Defaults to true
#
# [*configure_user*]
#   (optional) Whether to create the service user.
#   Defaults to true
#
# [*configure_user_role*]
#   (optional) Whether to configure the admin role for the service user.
#   Defaults to true
#
# [*cinder*]
#   (optional) Deprecated and has no effect
#   Defaults to undef
#
# [*public_protocol*]
#   (optional) Protocol to use for the public endpoint. Can be http or https.
#   Defaults to 'http'
#
# [*admin_protocol*]
#   Protocol for admin endpoints. Defaults to 'http'.
#
# [*internal_protocol*]
#   Protocol for internal endpoints. Defaults to 'http'.
#
class nova::keystone::auth(
  $password,
  $auth_name              = 'nova',
  $auth_name_v3           = 'novav3',
  $service_name           = undef,
  $service_name_v3        = undef,
  $public_address         = '127.0.0.1',
  $admin_address          = '127.0.0.1',
  $internal_address       = '127.0.0.1',
  $compute_port           = '8774',
  $ec2_port               = '8773',
  $compute_version        = 'v2',
  $region                 = 'RegionOne',
  $tenant                 = 'services',
  $email                  = 'nova@localhost',
  $configure_ec2_endpoint = true,
  $cinder                 = undef,
  $public_protocol        = 'http',
  $configure_endpoint     = true,
  $configure_endpoint_v3  = true,
  $configure_user         = true,
  $configure_user_role    = true,
  $admin_protocol         = 'http',
  $internal_protocol      = 'http'
) {

  #exec { 'db_sync1':
  #  path        => '/usr/bin',
  #  command     => "nova-manage db sync",
  #  #require     => Exec['create-dbname1-db'],
  #}

  if $cinder != undef {
    warning('The cinder parameter is deprecated and has no effect.')
  }

  if $service_name == undef {
    $real_service_name = $auth_name
  } else {
    $real_service_name = $service_name
  }

  if $service_name_v3 == undef {
    $real_service_name_v3 = $auth_name_v3
  } else {
    $real_service_name_v3 = $service_name_v3
  }

  #Keystone_endpoint["${region}/${real_service_name}"] ~> Service <| name == 'nova-api' |>

  if $configure_user {
    keystone_user { $auth_name:
      ensure   => present,
      password => $password,
      email    => $email,
      tenant   => $tenant,
    }
  }

  if $configure_user_role {
    keystone_user_role { "${auth_name}@${tenant}":
      ensure => present,
      roles  => 'admin',
    }
  }

  keystone_service { $real_service_name:
    ensure      => present,
    type        => 'compute',
    description => 'Openstack Compute Service',
  }

  if $configure_endpoint {
    keystone_endpoint { "${region}/${real_service_name}":
      ensure       => present,
      public_url   => "${public_protocol}://${public_address}:${compute_port}/${compute_version}/%(tenant_id)s",
      admin_url    => "${admin_protocol}://${admin_address}:${compute_port}/${compute_version}/%(tenant_id)s",
      internal_url => "${internal_protocol}://${internal_address}:${compute_port}/${compute_version}/%(tenant_id)s",
    }
  }

  if $configure_endpoint_v3 {
    keystone_service { $real_service_name_v3:
      ensure      => present,
      type        => 'computev3',
      description => 'Openstack Compute Service v3',
    }
    keystone_endpoint { "${region}/${real_service_name_v3}":
      ensure       => present,
      public_url   => "${public_protocol}://${public_address}:${compute_port}/v3",
      admin_url    => "${admin_protocol}://${admin_address}:${compute_port}/v3",
      internal_url => "${internal_protocol}://${internal_address}:${compute_port}/v3",
    }
  }

  if $configure_ec2_endpoint {
    keystone_service { "${real_service_name}_ec2":
      ensure      => present,
      type        => 'ec2',
      description => 'EC2 Service',
    }
    keystone_endpoint { "${region}/${real_service_name}_ec2":
      ensure       => present,
      public_url   => "${public_protocol}://${public_address}:${ec2_port}/services/Cloud",
      admin_url    => "${admin_protocol}://${admin_address}:${ec2_port}/services/Admin",
      internal_url => "${internal_protocol}://${internal_address}:${ec2_port}/services/Cloud",
    }
  }
}
