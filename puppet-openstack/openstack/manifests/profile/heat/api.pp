# The profile for installing the heat API
class openstack::profile::heat::api {
  openstack::resources::controller { 'heat': }
  openstack::resources::database { 'heat': }
  openstack::resources::firewall { 'Heat API': port     => '8004', }
  openstack::resources::firewall { 'Heat CFN API': port => '8000', }

  $controller_management_address = $::openstack::config::controller_address_management
  $vip_ip = $::openstack::config::haproxy_listen_ip

  if $::openstack::config::high_availability == "true" {
    $public_address = $vip_ip
    $admin_address = $vip_ip
    $internal_address = $vip_ip

    Haproxy::Balancermember<||> -> Package['heat-api']
    Service['haproxy'] -> Package['heat-api']
    Haproxy::Balancermember<||> -> Exec<| title == 'heat-dbsync' |>
    Service['haproxy'] -> Exec<| title == 'heat-dbsync' |>
  }
  else {
    $public_address   = $::openstack::config::controller_address_api
    $admin_address    = $::openstack::config::controller_address_management
    $internal_address = $::openstack::config::controller_address_management
  }

  class { '::heat::keystone::auth':
    password         => $::openstack::config::heat_password,
    public_address   => $public_address,
    admin_address    => $admin_address,
    internal_address => $internal_address,
    region           => $::openstack::config::region,
    require          => [Class['::keystone::roles::admin']],
  }

  class { '::heat::keystone::auth_cfn':
    password         => $::openstack::config::heat_password,
    public_address   => $public_address,
    admin_address    => $admin_address,
    internal_address => $internal_address,
    region           => $::openstack::config::region,
  }
  
  class { '::heat::keystone::domain':
    auth_url           => "http://$vip_ip:5000/v3",
    keystone_admin     => 'admin',
    keystone_password  => $::openstack::config::keystone_password,
    keystone_tenant    => 'admin',
    #region           => $::openstack::config::region,
  }

  if $::openstack::config::high_availability == "true" {
    class { '::heat':
      database_connection => $::openstack::resources::connectors::heat,
      rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
      rabbit_userid       => $::openstack::config::rabbitmq_user,
      rabbit_password     => $::openstack::config::rabbitmq_password,
      debug               => $::openstack::config::debug,
      verbose             => $::openstack::config::verbose,
      #keystone_host       => $::openstack::config::controller_address_management,
      keystone_host       => $vip_ip,
      keystone_password   => $::openstack::config::heat_password,
      keystone_ec2_uri    => "http://$vip_ip:5000/v2.0",
      mysql_module        => '2.2',
    }
  }
  else {
    class { '::heat':
      database_connection => $::openstack::resources::connectors::heat,
      rabbit_host         => $::openstack::config::controller_address_management,
      rabbit_userid       => $::openstack::config::rabbitmq_user,
      rabbit_password     => $::openstack::config::rabbitmq_password,
      debug               => $::openstack::config::debug,
      verbose             => $::openstack::config::verbose,
      keystone_host       => $::openstack::config::controller_address_management,
      keystone_password   => $::openstack::config::heat_password,
      mysql_module        => '2.2',
    }
  }

  class { '::heat::api':
    bind_host => $::openstack::config::controller_address_api,
  }

  class { '::heat::api_cfn':
    bind_host => $::openstack::config::controller_address_api,
  }

  class { '::heat::engine':
    auth_encryption_key => $::openstack::config::heat_encryption_key,
    heat_metadata_server_url => "http://$vip_ip:8000",
    heat_waitcondition_server_url => "http://$vip_ip:8000/v1/waitcondition",
  }
}
