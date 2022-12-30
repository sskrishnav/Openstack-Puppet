# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  class { 'openstack::common::nova':
    is_compute => 'true',
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => $::openstack::config::nova_libvirt_type,
    vncserver_listen  => $management_address,
    #require => Class['openstack::common::nova'],
  }

  class { 'nova::migration::libvirt':
     #require => Class['::nova::compute::libvirt'],
  }
  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/openstack/qemu.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['libvirt'],
    #require => Class['::nova::migration::libvirt'],
  }

  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}
