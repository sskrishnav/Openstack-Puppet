# == Class: cinder::volume
#
# === Parameters
#
# [*package_ensure*]
#   (Optional) The state of the package.
#   Defaults to 'present'.
#
# [*enabled*]
#   (Optional) The state of the service
#   Defaults to 'true'.
#
# [*manage_service*]
#   (Optional) Whether to start/stop the service.
#   Defaults to 'true'.
#
class cinder::volume (
  $package_ensure = 'present',
  $enabled        = true,
  $manage_service = true
) {

  include ::cinder::params
  if $::osfamily == 'Debian' {
    Cinder_config<||> ~> Service['cinder-volume']
    Cinder_api_paste_ini<||> ~> Service['cinder-volume']
    Exec<| title == 'cinder-manage db_sync' |> ~> Service['cinder-volume']
  }
  #elsif $::osfamily == 'RedHat' {
    #Cinder_config<||> ~> Service['openstack-cinder-volume']
    #Cinder_api_paste_ini<||> ~> Service['openstak-cinder-volume']
    #Exec<| title == 'cinder-manage db_sync' |> ~> Service['openstack-cinder-volume']
  #}

  if $::cinder::params::volume_package {
    #Package['cinder-volume'] -> Cinder_config<||>
    #Package['cinder-volume'] -> Cinder_api_paste_ini<||>
    if $::osfamily == 'Debian' {
      Package['cinder']        -> Package['cinder-volume']
      Package['cinder-volume'] -> Service['cinder-volume']
    }
    #elsif $::osfamily == 'RedHat' {
    #  Package['openstack-cinder']        -> Package['cinder-volume']
    #  Package['cinder-volume'] -> Service['openstack-cinder-volume']
    #}
    package { 'cinder-volume':
      ensure => $package_ensure,
      name   => $::cinder::params::volume_package,
      tag    => 'openstack',
    }
  }

  if $manage_service {
    if $enabled {
      $ensure = 'running'
    } else {
      $ensure = 'stopped'
    }
  }

  if $::osfamily == 'Debian' {
    service { 'cinder-volume':
      ensure    => $ensure,
      name      => $::cinder::params::volume_service,
      enable    => $enabled,
      hasstatus => true,
      require   => Package['cinder'],
    }
  }
  elsif $::osfamily == 'RedHat' {
    service { 'cinder-volume':
      ensure    => $ensure,
      name      => $::cinder::params::volume_service,
      enable    => $enabled,
      hasstatus => true,
      require   => Package['openstack-cinder'],
    }
  }
}
