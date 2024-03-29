# Class swift::storage::account
#
# == Parameters
#  [*enabled*]
#    (optional) Should the service be enabled.
#    Defaults to true
#
#  [*manage_service*]
#    (optional) Whether the service should be managed by Puppet.
#    Defaults to true.
#
#  [*package_ensure*]
#    (optional) Value of package resource parameter 'ensure'.
#    Defaults to 'present'.
#
class swift::storage::account(
  $manage_service = true,
  $enabled        = true,
  $package_ensure = 'present'
) {

  Swift_config<| |> ~> Service["$::swift::params::account_reaper_service_name"]
  Swift_config<| |> ~> Service["$::swift::params::account_auditor_service_name"]

  swift::storage::generic { 'account':
    manage_service => $manage_service,
    enabled        => $enabled,
    package_ensure => $package_ensure,
  }

  include ::swift::params

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { "$::swift::params::account_reaper_service_name":
    ensure   => $service_ensure,
    name     => $::swift::params::account_reaper_service_name,
    enable   => $enabled,
    provider => $::swift::params::service_provider,
    #require  => Package["$::swift::params::account_package_name"],
  }

  service { "$::swift::params::account_auditor_service_name":
    ensure   => $service_ensure,
    name     => $::swift::params::account_auditor_service_name,
    enable   => $enabled,
    provider => $::swift::params::service_provider,
    require  => Package["$::swift::params::account_package_name"],
  }
}
