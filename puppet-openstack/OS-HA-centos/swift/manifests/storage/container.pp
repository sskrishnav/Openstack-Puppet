#
# === Parameters
#
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
#  [*allowed_sync_hosts*]
#    (optional) A list of hosts allowed in the X-Container-Sync-To
#    field for containers. Defaults to one entry list '127.0.0.1'.
#
class swift::storage::container(
  $manage_service     = true,
  $enabled            = true,
  $package_ensure     = 'present',
  $allowed_sync_hosts = ['127.0.0.1'],
) {

  Swift_config<| |> ~> Service['openstack-swift-container-updater']
  Swift_config<| |> ~> Service['openstack-swift-container-auditor']

  swift::storage::generic { 'container':
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

  service { 'openstack-swift-container-updater':
    ensure   => $service_ensure,
    name     => $::swift::params::container_updater_service_name,
    enable   => $enabled,
    provider => $::swift::params::service_provider,
    require  => Package['openstack-swift-container'],
  }

  service { 'openstack-swift-container-auditor':
    ensure   => $service_ensure,
    name     => $::swift::params::container_auditor_service_name,
    enable   => $enabled,
    provider => $::swift::params::service_provider,
    require  => Package['openstack-swift-container'],
  }

  
}
