# == Class: heat::api
#
# Installs & configure the heat API service
#
# === Parameters
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to 'true'.
#
# [*bind_host*]
#   (Optional) Address to bind the server. Useful when
#   selecting a particular network interface.
#   Defaults to '0.0.0.0'.
#
# [*bind_port*]
#   (Optional) The port on which the server will listen.
#   Defaults to '8004'.
#
# [*workers*]
#   (Optional) The port on which the server will listen.
#   Defaults to '0'.
#
# [*use_ssl*]
#   (Optional) Whether to use ssl or not.
#   Defaults to 'false'.
#
# [*cert_file*]
#   (Optional) Location of the SSL certificate file to use for SSL mode.
#   Required when $use_ssl is set to 'true'.
#   Defaults to 'false'.
#
# [*key_file*]
#   (Optional) Location of the SSL key file to use for enabling SSL mode.
#   Required when $use_ssl is set to 'true'.
#   Defaults to 'false'.
#
# === Deprecated Parameters
#
# No Deprecated Parameters.
#
class heat::api (
  $manage_service    = true,
  $enabled           = true,
  $bind_host         = '0.0.0.0',
  $bind_port         = '8004',
  $workers           = '0',
  $use_ssl           = false,
  $cert_file         = false,
  $key_file          = false,
) {

  include heat
  include heat::params
  include heat::policy
  Heat_config<||> ~> Service["$::heat::params::api_service_name"]
  Class['heat::policy'] -> Service["$::heat::params::api_service_name"]

  Package["$::heat::params::api_package_name"] -> Heat_config<||>
  Package["$::heat::params::api_package_name"] -> Class['heat::policy']
  Package["$::heat::params::api_package_name"] -> Service["$::heat::params::api_service_name"]

  if $use_ssl {
    if !$cert_file {
      fail('The cert_file parameter is required when use_ssl is set to true')
    }
    if !$key_file {
      fail('The key_file parameter is required when use_ssl is set to true')
    }
  }

  package { 'heat-api':
    ensure => installed,
    name   => $::heat::params::api_package_name,
  }
  
  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { "$::heat::params::api_service_name" :
    ensure     => $service_ensure,
    name       => $::heat::params::api_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => [Package["$::heat::params::common_package_name"],
                  Package["$::heat::params::api_package_name"]],
    subscribe  => Exec['heat-dbsync'],
   
  }

  heat_config {
    'heat_api/bind_host'  : value => $bind_host;
    'heat_api/bind_port'  : value => $bind_port;
    'heat_api/workers'    : value => $workers;
  }

  # SSL Options
  if $use_ssl {
    heat_config {
      'heat_api/cert_file' : value => $cert_file;
      'heat_api/key_file' :  value => $key_file;
    }
  } else {
    heat_config {
      'heat_api/cert_file' : ensure => absent;
      'heat_api/key_file' :  ensure => absent;
    }
  }

}
