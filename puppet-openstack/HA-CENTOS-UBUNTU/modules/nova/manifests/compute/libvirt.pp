# == Class: nova::compute::libvirt
#
# Install and manage nova-compute guests managed
# by libvirt
#
# === Parameters:
#
# [*libvirt_virt_type*]
#   (optional) Libvirt domain type. Options are: kvm, lxc, qemu, uml, xen
#   Replaces libvirt_type
#   Defaults to 'kvm'
#
# [*vncserver_listen*]
#   (optional) IP address on which instance vncservers should listen
#   Defaults to '127.0.0.1'
#
# [*migration_support*]
#   (optional) Whether to support virtual machine migration
#   Defaults to false
#
# [*libvirt_cpu_mode*]
#   (optional) The libvirt CPU mode to configure.  Possible values
#   include custom, host-model, none, host-passthrough.
#   Defaults to 'host-model' if libvirt_virt_type is set to either
#   kvm or qemu, otherwise defaults to 'none'.
#
# [*libvirt_disk_cachemodes*]
#   (optional) A list of cachemodes for different disk types, e.g.
#   ["file=directsync", "block=none"]
#   If an empty list is specified, the disk_cachemodes directive
#   will be removed from nova.conf completely.
#   Defaults to an empty list
#
# [*libvirt_inject_password*]
#   (optional) Inject the admin password at boot time, without an agent.
#   Defaults to false
#
# [*libvirt_inject_key*]
#   (optional) Inject the ssh public key at boot time.
#   Defaults to false
#
# [*libvirt_inject_partition*]
#   (optional) The partition to inject to : -2 => disable, -1 => inspect
#   (libguestfs only), 0 => not partitioned, >0 => partition
#   number (integer value)
#   Defaults to -2
#
# [*remove_unused_base_images*]
#   (optional) Should unused base images be removed?
#   If undef is specified, remove the line in nova.conf
#   otherwise, use a boolean to remove or not the base images.
#   Defaults to undef
#
# [*remove_unused_kernels*]
#   (optional) Should unused kernel images be removed?
#   This is only safe to enable if all compute nodes
#   have been updated to support this option.
#   If undef is specified, remove the line in nova.conf
#   otherwise, use a boolean to remove or not the kernels.
#   Defaults to undef
#
# [*remove_unused_resized_minimum_age_seconds*]
#   (optional) Unused resized base images younger
#   than this will not be removed
#   If undef is specified, remove the line in nova.conf
#   otherwise, use a integer or a string to define after
#   how many seconds it will be removed.
#   Defaults to undef
#
# [*remove_unused_original_minimum_age_seconds*]
#   (optional) Unused unresized base images younger
#   than this will not be removed
#   If undef is specified, remove the line in nova.conf
#   otherwise, use a integer or a string to define after
#   how many seconds it will be removed.
#   Defaults to undef
#
# [*libvirt_service_name*]
#   (optional) libvirt service name.
#   Defaults to $::nova::params::libvirt_service_name
#
class nova::compute::libvirt (
  $libvirt_virt_type                          = 'kvm',
  $vncserver_listen                           = '127.0.0.1',
  $migration_support                          = false,
  $libvirt_cpu_mode                           = false,
  $libvirt_disk_cachemodes                    = [],
  $libvirt_inject_password                    = false,
  $libvirt_inject_key                         = false,
  $libvirt_inject_partition                   = -2,
  $remove_unused_base_images                  = undef,
  $remove_unused_kernels                      = undef,
  $remove_unused_resized_minimum_age_seconds  = undef,
  $remove_unused_original_minimum_age_seconds = undef,
  $libvirt_service_name                       = $::nova::params::libvirt_service_name,
  # DEPRECATED PARAMETER
  $libvirt_type                               = false
) inherits nova::params {

  include nova::params

  Service['libvirt'] -> Service["$::nova::params::compute_package_name"]

  if $libvirt_type {
    warning ('The libvirt_type parameter is deprecated, use libvirt_virt_type instead.')
    $libvirt_virt_type_real = $libvirt_type
  } else {
    $libvirt_virt_type_real = $libvirt_virt_type
  }

  # libvirt_cpu_mode has different defaults depending on hypervisor.
  if !$libvirt_cpu_mode {
    case $libvirt_virt_type_real {
      'kvm','qemu': {
        $libvirt_cpu_mode_real = 'host-model'
      }
      default: {
        $libvirt_cpu_mode_real = 'none'
      }
    }
  } else {
    $libvirt_cpu_mode_real = $libvirt_cpu_mode
  }

  if($::osfamily == 'Debian') {
    package { "nova-compute-${libvirt_virt_type_real}":
      ensure  => present,
      before  => Package['nova-compute'],
      require => Package['nova-common'],
      tag     => ['openstack', 'nova'],
    }
  }

  if($::osfamily == 'RedHat' and $::operatingsystem != 'Fedora') {
    package { 'qemu':
      ensure  => present,
    }
    service { 'messagebus':
      ensure   => running,
      enable   => true,
      provider => $::nova::params::special_service_provider,
    }
    Package['libvirt'] -> Service['messagebus'] -> Service['libvirt']
    Package['libvirt'] -> Package['qemu'] -> Service['libvirt']
  }

  if $migration_support {
    if $vncserver_listen != '0.0.0.0' and $vncserver_listen != '::0' {
      fail('For migration support to work, you MUST set vncserver_listen to \'0.0.0.0\' or \'::0\'')
    } else {
      class { 'nova::migration::libvirt': }
    }
  }

  package { 'libvirt':
    ensure => present,
    name   => $::nova::params::libvirt_package_name,
  }

  service { 'libvirt' :
    ensure   => running,
    enable   => true,
    name     => $libvirt_service_name,
    provider => $::nova::params::special_service_provider,
    require  => Package['libvirt'],
  }

  nova_config { 'DEFAULT/libvirt_use_virtio_for_bridges': value => 'True' }
  if size($libvirt_disk_cachemodes) > 0 {
    nova_config {
      'libvirt/disk_cachemodes': value => join($libvirt_disk_cachemodes, ',');
    }
  } else {
    nova_config {
      'libvirt/disk_cachemodes': ensure => absent;
    }
  }

  if $remove_unused_kernels != undef {
    nova_config {
      'libvirt/remove_unused_kernels': value => $remove_unused_kernels;
    }
  } else {
    nova_config {
      'libvirt/remove_unused_kernels': ensure => absent;
    }
  }

  if $remove_unused_resized_minimum_age_seconds != undef {
    nova_config {
      'libvirt/remove_unused_resized_minimum_age_seconds': value => $remove_unused_resized_minimum_age_seconds;
    }
  } else {
    nova_config {
      'libvirt/remove_unused_resized_minimum_age_seconds': ensure => absent;
    }
  }

  if $remove_unused_base_images != undef {
    nova_config {
      'DEFAULT/remove_unused_base_images': value => $remove_unused_base_images;
    }
  } else {
    nova_config {
      'DEFAULT/remove_unused_base_images': ensure => absent;
    }
  }

  if $remove_unused_original_minimum_age_seconds != undef {
    nova_config {
      'DEFAULT/remove_unused_original_minimum_age_seconds': value => $remove_unused_original_minimum_age_seconds;
    }
  } else {
    nova_config {
      'DEFAULT/remove_unused_original_minimum_age_seconds': ensure => absent;
    }
  }
}
