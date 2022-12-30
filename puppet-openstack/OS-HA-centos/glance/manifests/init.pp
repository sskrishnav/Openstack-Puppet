#
# base glacne config.
#
# == parameters
#   * package_ensure - ensure state for package.
#
class glance(
  $package_ensure = 'present'
) {

  include glance::params

  file { '/etc/glance/':
    ensure  => directory,
    owner   => 'glance',
    group   => 'root',
    mode    => '0770',
  }

  if $::osfamily == 'Debian' {
    package { 'glance':
      ensure => "present",
      name   => 'glance',
      tag    => 'openstack',
    }

    if ( $glance::params::api_package_name == $glance::params::registry_package_name ) {
      package { $glance::params::api_package_name :
        ensure => $package_ensure,
        name   => $::glance::params::package_name,
        tag    => ['openstack'],
      }
    }
  }

  if $::osfamily == 'RedHat' {
    package { 'openstack-glance':
      ensure => "present",
      name   => $::glance::params::package_name,
      tag    => 'openstack',
    }
  }
}
