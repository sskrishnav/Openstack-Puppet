# The profile for installing a single loopback storage node
class openstack::profile::swift::storage (
  $zone = undef,
) {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)
  $storage_node_drive = $::openstack::config::swift_storage_drive
  $storage_partition_type = $::openstack::config::swift_storage_partition_type
  $storage_servers = $::openstack::config::swift_servers

  #class { 'swift::storage::rsync':
  #    mgmt_ip => $management_network,
  #}

  firewall { '6000 - Swift Object Store':
    proto  => 'tcp',
    state  => ['NEW'],
    action => 'accept',
    port   => '6000',
  }

  firewall { '6001 - Swift Container Store':
    proto  => 'tcp',
    state  => ['NEW'],
    action => 'accept',
    port   => '6001',
  }

  firewall { '6002 - Swift Account Store':
    proto  => 'tcp',
    state  => ['NEW'],
    action => 'accept',
    port   => '6002',
  }

  if !defined(Class['::swift']) {
    class { '::swift':
      swift_hash_suffix => $::openstack::config::swift_hash_suffix,
    }
  }
  
  if $storage_node_drive {
    $storage_mount_name = "sdb"
    swift::storage::xfs { "$storage_mount_name":
        device     =>  $storage_node_drive,
    }
  }
  else {
    $storage_mount_name = "1"
    swift::storage::loopback { "$storage_mount_name":
      base_dir     => '/srv/swift-loopback',
      mnt_base_dir => '/srv/node',
      byte_size    => 1024,
      seek         => 10000,
      fstype       => 'ext4',
      require      => Class['swift'],
    }
  }

  class { '::swift::storage::all':
    storage_local_net_ip => $management_address
    #object_pipeline      => ['healthcheck', 'recon']
  }

  $storage_servers.each | $s_server | {
    @@ring_object_device { "${s_server}:6000/${storage_mount_name}":
      zone   => $zone,
      weight => 1,
    }~>

    @@ring_container_device { "${s_server}:6001/${storage_mount_name}":
      zone   => $zone,
      weight => 1,
    }~>

    @@ring_account_device { "${s_server}:6002/${storage_mount_name}":
      zone   => $zone,
      weight => 1,
    }
  }

  swift::ringsync { ['account','container','object']:
    ring_server => $::openstack::config::controller_address_management,
  }
  Swift::Ringsync<<||>>

  #swift::storage::filter::recon { 'account': }
  #swift::storage::filter::recon { 'container': }
  #swift::storage::filter::recon { 'object': }
  
}
