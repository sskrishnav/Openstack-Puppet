# = Puppet Labs OpenStack Parameters
# == Class: openstack
#
# === Authors
#
# Christian Hoge <chris.hoge@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013-2014 Puppet Labs.
#
# Class for configuring the global installation parameters for the puppetlabs-openstack module.
# By default, the module will try to find the parameters in hiera. If the hiera lookup fails,
# it will fall back to the parameters passed to this class. The use of this class is optional,
# and will be automatically included through the configuration. If the ::openstack
# class is used, it needs appear first in node parse order to ensure proper variable
# initialization.
#
# [*region*]
#   The region name to set up the OpenStack services.
#
# == Networks
# [*network_api*]
#   The CIDR of the api network. This is the network that all public
#   api calls are made on, as well as the network to access Horizon.
#
# [*network_external*]
#   The CIDR of the external network. May be the same as network_api.
#   This is the network that floating IP addresses are allocated in
#   to allow external access to virtual machine instances.
#
# [*network_management*]
#   The CIDR of the management network.
#
# [*network_data*]
#   The CIDR of the data network. May be the same as network_management.
#
# [*network_external_ippool_start*]
#   The starting address of the external network IP pool. Must be contained
#   within the network_external CIDR range.
#
# [*network_external_ippool_end*]
#   The end address of the external network IP pool. Must be contained within
#   the network_external CIDR range, and greater than network_external_ippool_start.
#
# [*network_external_gateway*]
#   The gateway address for the external network.
#
# [*network_external_dns*]
#   The DNS server for the external network.
#
# == Private Neutron Network
# [*network_neutron_private*]
#   The CIDR of the automatically created private network.
#
# == Fixed IPs (controllers)
# [*controller_address_api*]
#   The API IP address of the controller node. Must be in the network_api CIDR.
#
# [*controller_address_management*]
#   The management IP address of the controller node. Must be in the network_management CIDR.
#
# [*storage_address_api*]
#   The API IP address of the storage node. Must be in the network_api CIDR.
#
# [*storage_address_management*]
#   The management IP address of the storage node. Must be in the network_management CIDR.
#
# == Database
# [*mysql_root_password*]
#   The root password for the MySQL database.
#
# [*mysql_service_password*]
#   The MySQL shared password for all of the OpenStack services.
#
# [*mysql_allowed_hosts*]
#   Array of hosts that are allowed to access the MySQL database. Should include all of the network_management CIDR.
#   Example configuration: ['localhost', '127.0.0.1', '172.16.33.%']
#
# [*mysql_user_keystone*]
#   The database username for keystone service.
#
# [*mysql_pass_keystone*]
#   The database password for keystone service.
#
# [*mysql_user_cinder*]
#   The database username for cinder service.
#
# [*mysql_pass_cinder*]
#   The database password for cinder service.
#
# [*mysql_user_glance*]
#   The database username for glance service.
#
# [*mysql_pass_glance*]
#   The database password for glance service.
#
# [*mysql_user_nova*]
#   The database username for nova service.
#
# [*mysql_pass_nova*]
#   The database password for nova service.
#
# [*mysql_user_neutron*]
#   The database username for neutron service.
#
# [*mysql_pass_neutron*]
#   The database password for neutron service.
#
# [*mysql_user_heat*]
#   The database username for heat service.
#
# [*mysql_pass_heat*]
#   The database password for heat service.
#
# == RabbitMQ
# [*rabbitmq_hosts*]
#   The host list for the RabbitMQ service.
#
# [*rabbitmq_user*]
#   The username for the RabbitMQ queues.
#
# [*rabbitmq_password*]
#   The password for accessing the RabbitMQ queues.
#
# == Keystone
# [*keystone_admin_token*]
#   The global administrative token for the Keystone service.
#
# [*keystone_admin_email*]
#   The e-mail address of the Keystone administrator.
#
# [*keystone_admin_password*]
#   The password for keystone user in Keystone.
#
# [*keystone_tenants*]
#   The intial keystone tenants to create. Should be a Hash in the form of: 
#   {'tenant_name1' => { 'descritpion' => 'Tenant Description 1'}, 
#    'tenant_name2' => {'description' => 'Tenant Description 2'}}
#
# [*keystone_users*]
#   The intial keystone users to create. Should be a Hash in the form of:
#   {'user1' => {'password' => 'somepass1', 'tenant' => 'some_preexisting_tenant',
#                'email' => 'foo@example.com', 'admin'  =>  'true'},
#   'user2' => {'password' => 'somepass2', 'tenant' => 'some_preexisting_tenant',
#                'email' => 'foo2@example.com', 'admin'  =>  'false'}} 
#
# == Glance
# [*glance_password*]
#   The password for the glance user in Keystone.
#
# [*glance_api_servers*]
#   Array of api servers, with port setting
#   Example configuration: ['172.16.33.4:9292'] 
#
# ==Cinder
# [*cinder_password*]
#   The password for the cinder user in Keystone.
#
# [*cinder_volume_size*]
#   The size of the Cinder loopback storage device. Example: '8G'.
#
# == Swift
# [*swift_password*]
#    The password for the swift user in Keystone.
#
# [*swift_hash_suffix*]
#   The hash suffix for Swift ring communication.
#
# == Nova
# [*nova_libvirt_type*]
#   The type of hypervisor to use for Nova. Typically 'kvm' for
#   hardware accelerated virtualization or 'qemu' for software virtualization.
#
# [*nova_password*]
#   The password for the nova user in Keystone.
#
# == Neutron
# [*neutron_password*]
#   The password for the neutron user in Keystone.
#
# [*neutron_shared_secret*]
#   The shared secret to allow for communication between Neutron and Nova.
#
# [*neutron_core_plugin*]
#   The core_plugin for the neutron service
#
# [*neutron_service_plugins*]
#   The service_plugins for neutron service
#
# [*neutron_tunneling*] (Deprecated)
#   Boolean. Whether to enable Neutron tunneling.
#   Default to true.
#
# [*neutron_tunnel_types*] (Deprecated)
#   Array. Tunnel types to use
#   Defaults to ['gre'],
#
# [*neutron_tenant_network_type*] (Deprecated)
#   Array. Tenant network type.
#   Defaults to ['gre'],
#
# [*neutron_type_drivers*] (Deprecated)
#   Array. Neutron type drivers to use.
#   Defaults to ['gre'],
#
# [*neutron_mechanism_drivers*] (Deprecated)
#   Defaults to ['openvswitch'].
#
# [*neutron_tunnel_id_ranges*] (Deprecated)
#   Neutron tunnel id ranges.
#   Defaults to ['1:1000']
#
# == Ceilometer
# [*ceilometer_address_management*]
#   The management IP address of the ceilometer node. Must be in the network_management CIDR.
#
# [*ceilometer_mongo_username*]
#   The username for the MongoDB Ceilometer user.
#
# [*ceilometer_mongo_password*]
#   The password for the MongoDB Ceilometer user.
#
# [*ceilometer_password*]
#   The password for the ceilometer user in Keystone.
#
# [*ceilometer_meteringsecret*]
#   The shared secret to allow communication betweek Ceilometer and other
#   OpenStack services.
#
# == Heat
# [*heat_password*]
#   The password for the heat user in Keystone.
#
# [*heat_encryption_key*]
#   The encyption key for the shared heat services.
#
# == Horizon
# [*horizon_secret_key*]
#   The secret key for the Horizon service.
#
# == Log levels
# [*verbose*]
#   Boolean. Determines if verbose is enabled for all OpenStack services.
#
# [*debug*]
#   Boolean. Determines if debug is enabled for all OpenStack services.
#
# == Tempest
# [*tempest_configure_images*]
#   Boolean. Whether Tempest should configure images.
#
# [*tempest_image_name*]
#   The name of the primary image to use for tests.
#
# [*tempest_image_name_alt*]
#   The name of the secondary image to use for tests. If the same as the
#   tempest_image_primary, some tests will be disabled.
#
# [*tempest_username*]
#   The login username to run tempest tests.
#
# [*tempest_username_alt*]
#   The alternate login username for tempest tests.
#
# [*tempest_username_admin*]
#   The uername for the Tempest admin user.
#
# [*tempest_configure_network*]
#   Boolean. If Tempest should configure test networks.
#
# [*tempest_public_network_name*]
#   The name of the public neutron network for Tempest to connect to.
#
# [*tempest_cinder_available*]
#   Boolean. If Cinder services are available.
#
# [*tempest_glance_available*]
#   Boolean. If Glance services are available.
#
# [*tempest_horizon_available*]
#   Boolean. If Horizon is available.
#
# [*tempest_nova_available*]
#   Boolean. If Nova services are available.
#
# [*tempest_neutron_available*]
#   Boolean. If Neutron services are availale.
#
# [*tempest_heat_available*]
#   Boolean. If Heat services are available.
#
# [*tempest_swift_available*]
#   Boolean. If Swift services are available.
#
class openstack (
  $use_hiera = true,
  $region = undef,
  $high_availability = undef,
  $local_repo = undef,
  $network_api = undef,
  $network_external = undef,
  $network_management = undef,
  $network_data = undef,
  $network_external_ippool_start = undef,
  $network_external_ippool_end = undef,
  $network_external_gateway = undef,
  $network_external_dns = undef,
  $network_neutron_private = undef,
  $controller_address_api = undef,
  $controller_address_management = undef,
  $storage_address_api = undef,
  $storage_address_management = undef,
  $mysql_root_password = undef,
  $mysql_service_password = undef,
  $mysql_allowed_hosts = undef,
  $mysql_user_keystone = undef,
  $mysql_pass_keystone = undef,
  $mysql_user_cinder = undef,
  $mysql_pass_cinder = undef,
  $mysql_user_glance = undef,
  $mysql_pass_glance = undef,
  $mysql_user_nova = undef,
  $mysql_pass_nova = undef,
  $mysql_user_neutron = undef,
  $mysql_pass_neutron = undef,
  $mysql_user_heat = undef,
  $mysql_pass_heat = undef,
  $rabbitmq_hosts = undef,
  $rabbitmq_user = undef,
  $rabbitmq_password = undef,

  $rabbitmq_cluster_nodes = undef,

  $keystone_admin_token = undef,
  $keystone_admin_email = undef,
  $keystone_admin_password = undef,
  $keystone_tenants = undef,
  $keystone_users = undef,
  $glance_password = undef,
  $glance_api_servers = undef,
  $cinder_password = undef,
  $cinder_volume_size = undef,
  $swift_password = undef,
  $swift_hash_suffix = undef,
  $swift_hash_prefix = undef,
  $swift_servers = undef,
  $swift_servers_hostnames = undef,
  $swift_storage_drive = undef,
  $swift_storage_partition_type = undef,
  $nova_libvirt_type = undef,
  $nova_password = undef,
  $neutron_password = undef,
  $neutron_shared_secret = undef,
  $neutron_core_plugin = undef,
  $neutron_service_plugins = undef,
  $neutron_tunneling = true,
  $neutron_tunnel_types = ['gre'],
  $neutron_tenant_network_type = ['gre'],
  $neutron_type_drivers = ['gre'],
  $neutron_mechanism_drivers = ['openvswitch'],
  $neutron_tunnel_id_ranges = ['1:1000'],
  $max_l3_agents_per_router = undef,
  $min_l3_agents_per_router = undef,
  $ceilometer_address_management = undef,
  $ceilometer_mongo_username = undef,
  $ceilometer_mongo_password = undef,
  $ceilometer_password = undef,
  $ceilometer_meteringsecret = undef,
  $heat_password = undef,
  $heat_encryption_key = undef,
  $horizon_secret_key = undef,
  $tempest_configure_images    = undef,
  $tempest_image_name          = undef,
  $tempest_image_name_alt      = undef,
  $tempest_username            = undef,
  $tempest_username_alt        = undef,
  $tempest_username_admin      = undef,
  $tempest_configure_network   = undef,
  $tempest_public_network_name = undef,
  $tempest_cinder_available    = undef,
  $tempest_glance_available    = undef,
  $tempest_horizon_available   = undef,
  $tempest_nova_available      = undef,
  $tempest_neutron_available   = undef,
  $tempest_heat_available      = undef,
  $tempest_swift_available     = undef,
  $verbose = undef,
  $debug = undef,
) {
  if $use_hiera {
    class { '::openstack::config':
      region                        => hiera(castlight::region),
      high_availability             => hiera(castlight::high_availability),
      local_repo                    => hiera(castlight::local_repo),
      network_api                   => hiera(castlight::network::api),
      network_external              => hiera(castlight::network::external),
      network_management            => hiera(castlight::network::management),
      network_data                  => hiera(castlight::network::data),
      network_external_ippool_start => hiera(castlight::network::external::ippool::start),
      network_external_ippool_end   => hiera(castlight::network::external::ippool::end),
      network_external_gateway      => hiera(castlight::network::external::gateway),
      network_external_dns          => hiera(castlight::network::external::dns),
      network_neutron_private       => hiera(castlight::network::neutron::private),
      controller_address_api        => hiera(castlight::controller::address::api),
      controller_address_management => hiera(castlight::controller::address::management),
      storage_address_api           => hiera(castlight::storage::address::api),
      storage_address_management    => hiera(castlight::storage::address::management),
      mysql_root_password           => hiera(castlight::mysql::root_password),
      mysql_service_password        => hiera(castlight::mysql::service_password),
      mysql_allowed_hosts           => hiera(castlight::mysql::allowed_hosts),
      mysql_user_keystone           => pick(hiera(castlight::mysql::keystone::user, undef), 'keystone'),
      mysql_pass_keystone           => pick(hiera(castlight::mysql::keystone::pass, undef), hiera(castlight::mysql::service_password)),
      mysql_user_cinder             => pick(hiera(castlight::mysql::cinder::user, undef), 'cinder'),
      mysql_pass_cinder             => pick(hiera(castlight::mysql::cinder::pass, undef), hiera(castlight::mysql::service_password)),
      mysql_user_glance             => pick(hiera(castlight::mysql::glance::user, undef), 'glance'),
      mysql_pass_glance             => pick(hiera(castlight::mysql::glance::pass, undef), hiera(castlight::mysql::service_password)),
      mysql_user_nova               => pick(hiera(castlight::mysql::nova::user, undef), 'nova'),
      mysql_pass_nova               => pick(hiera(castlight::mysql::nova::pass, undef), hiera(castlight::mysql::service_password)),
      mysql_user_neutron            => pick(hiera(castlight::mysql::neutron::user, undef), 'neutron'),
      mysql_pass_neutron            => pick(hiera(castlight::mysql::neutron::pass, undef), hiera(castlight::mysql::service_password)),
      mysql_user_heat               => pick(hiera(castlight::mysql::heat::user, undef), 'heat'),
      mysql_pass_heat               => pick(hiera(castlight::mysql::heat::pass, undef), hiera(castlight::mysql::service_password)),
      rabbitmq_hosts                => hiera(castlight::rabbitmq::hosts),
      rabbitmq_user                 => hiera(castlight::rabbitmq::user),
      rabbitmq_password             => hiera(castlight::rabbitmq::password),
      rabbitmq_cluster_nodes        => hiera(castlight::rabbitmq::cluster_nodes),
      keystone_admin_token          => hiera(castlight::keystone::admin_token),
      keystone_admin_email          => hiera(castlight::keystone::admin_email),
      keystone_admin_password       => hiera(castlight::keystone::admin_password),
      keystone_tenants              => hiera(castlight::keystone::tenants),
      keystone_users                => hiera(castlight::keystone::users),
      glance_password               => hiera(castlight::glance::password),
      glance_api_servers            => hiera(castlight::glance::api_servers),
      cinder_password               => hiera(castlight::cinder::password),
      cinder_volume_size            => hiera(castlight::cinder::volume_size),
      swift_password                => hiera(castlight::swift::password),
      swift_hash_suffix             => hiera(castlight::swift::hash_suffix),
      swift_hash_prefix             => hiera(castlight::swift::hash_prefix),
      swift_servers                 => hiera(castlight::swift::servers),
      swift_servers_hostnames       => hiera(castlight::swift::servers::hostnames),
      swift_storage_drive           => hiera(castlight::swift::storage_drive),
      swift_storage_partition_type  => hiera(castlight::swift::storage_partition_type),
      nova_libvirt_type             => hiera(castlight::nova::libvirt_type),
      nova_password                 => hiera(castlight::nova::password),
      neutron_password              => hiera(castlight::neutron::password),
      neutron_shared_secret         => hiera(castlight::neutron::shared_secret),
      neutron_core_plugin           => hiera(castlight::neutron::core_plugin),
      neutron_service_plugins       => hiera(castlight::neutron::service_plugins),
      neutron_tunneling             => hiera(castlight::neutron::neutron_tunneling, $neutron_tunneling),
      neutron_tunnel_types          => hiera(castlight::neutron::neutron_tunnel_type, $neutron_tunnel_types),
      neutron_tenant_network_type   => hiera(castlight::neutron::neutron_tenant_network_type, $neutron_tenant_network_type),
      neutron_type_drivers          => hiera(castlight::neutron::neutron_type_drivers, $neutron_type_drivers),
      neutron_mechanism_drivers     => hiera(castlight::neutron::neutron_mechanism_drivers, $neutron_mechanism_drivers),
      neutron_tunnel_id_ranges      => hiera(castlight::neutron::neutron_tunnel_id_ranges, $neutron_tunnel_id_ranges),
      max_l3_agents_per_router      => hiera(castlight::neutron::max_l3_agents_per_router),
      min_l3_agents_per_router      => hiera(castlight::neutron::min_l3_agents_per_router),
      ceilometer_address_management => hiera(castlight::ceilometer::address::management),
      ceilometer_mongo_username     => hiera(castlight::ceilometer::mongo::username),
      ceilometer_mongo_password     => hiera(castlight::ceilometer::mongo::password),
      ceilometer_password           => hiera(castlight::ceilometer::password),
      ceilometer_meteringsecret     => hiera(castlight::ceilometer::meteringsecret),
      heat_password                 => hiera(castlight::heat::password),
      heat_encryption_key           => hiera(castlight::heat::encryption_key),
      horizon_secret_key            => hiera(castlight::horizon::secret_key),
      verbose                       => hiera(castlight::verbose),
      debug                         => hiera(castlight::debug),
      tempest_configure_images      => hiera(castlight::tempest::configure_images),
      tempest_image_name            => hiera(castlight::tempest::image_name),
      tempest_image_name_alt        => hiera(castlight::tempest::image_name_alt),
      tempest_username              => hiera(castlight::tempest::username),
      tempest_username_alt          => hiera(castlight::tempest::username_alt),
      tempest_username_admin        => hiera(castlight::tempest::username_admin),
      tempest_configure_network     => hiera(castlight::tempest::configure_network),
      tempest_public_network_name   => hiera(castlight::tempest::public_network_name),
      tempest_cinder_available      => hiera(castlight::tempest::cinder_available),
      tempest_glance_available      => hiera(castlight::tempest::glance_available),
      tempest_horizon_available     => hiera(castlight::tempest::horizon_available),
      tempest_nova_available        => hiera(castlight::tempest::nova_available),
      tempest_neutron_available     => hiera(castlight::tempest::neutron_available),
      tempest_heat_available        => hiera(castlight::tempest::heat_available),
      tempest_swift_available       => hiera(castlight::tempest::swift_available),

      keepalived_interface	    => hiera(keepalived::interface),
      keepalived_virtual_ip         => hiera(keepalived::virtual_ip),
      #keepalived::priority : "",
      keepalived_auth_pass          => hiera(keepalived::auth_pass),

      haproxy_listen_ip             => hiera(haproxy::listen_ip),
      haproxy_listen_ports          => hiera(haproxy::listen_ports),
      haproxy_local_ip              => hiera(haproxy::local_ip),
      haproxy_members               => hiera(haproxy::members),

      galera_servers                => hiera(galera::servers),
      galera_master                 => hiera(galera::master),
      galera_vendor_type            => hiera(galera::vendor_type),
      galera_local_ip               => hiera(galera::local_ip),
      galera_root_password          => hiera(galera::root_password),
      galera_status_password        => hiera(galera::status_password),
      galera_repo_keyserver         => hiera(galera::repo_keyserver),
      galera_repo_key               => hiera(galera::repo_key),
      galera_repo_location         => hiera(galera::repo_location),

    }
  } else {
    class { '::openstack::config':
      region                        => $region,
      high_availability             => $high_availability,
      local_repo                    => $local_repo,
      network_api                   => $network_api,
      network_external              => $network_external,
      network_management            => $network_management,
      network_data                  => $network_data,
      network_external_ippool_start => $network_external_ippool_start,
      network_external_ippool_end   => $network_external_ippool_end,
      network_external_gateway      => $network_external_gateway,
      network_external_dns          => $network_external_dns,
      network_neutron_private       => $network_neutron_private,
      controller_address_api        => $controller_address_api,
      controller_address_management => $controller_address_management,
      storage_address_api           => $storage_address_api,
      storage_address_management    => $storage_address_management,
      mysql_root_password           => $mysql_root_password,
      mysql_service_password        => $mysql_service_password,
      mysql_allowed_hosts           => $mysql_allowed_hosts,
      mysql_user_keystone           => pick($mysql_user_keystone, 'keystone'),
      mysql_pass_keystone           => pick($mysql_pass_keystone, $mysql_service_password),
      mysql_user_cinder             => pick($mysql_user_cinder, 'cinder'),
      mysql_pass_cinder             => pick($mysql_pass_cinder, $mysql_service_password),
      mysql_user_glance             => pick($mysql_user_glance, 'glance'),
      mysql_pass_glance             => pick($mysql_pass_glance, $mysql_service_password),
      mysql_user_nova               => pick($mysql_user_nova, 'nova'),
      mysql_pass_nova               => pick($mysql_pass_nova, $mysql_service_password),
      mysql_user_neutron            => pick($mysql_user_neutron, 'neutron'),
      mysql_pass_neutron            => pick($mysql_pass_neutron, $mysql_service_password),
      mysql_user_heat               => pick($mysql_user_heat, 'heat'),
      mysql_pass_heat               => pick($mysql_pass_heat, $mysql_service_password),
      rabbitmq_hosts                => $rabbitmq_hosts,
      rabbitmq_user                 => $rabbitmq_user,
      rabbitmq_password             => $rabbitmq_password,
      rabbitmq_cluster_nodes        => $rabbitmq_cluster_nodes,
      keystone_admin_token          => $keystone_admin_token,
      keystone_admin_email          => $keystone_admin_email,
      keystone_admin_password       => $keystone_admin_password,
      keystone_tenants              => $keystone_tenants,
      keystone_users                => $keystone_users,
      glance_password               => $glance_password,
      glance_api_servers            => $glance_api_servers,
      cinder_password               => $cinder_password,
      cinder_volume_size            => $cinder_volume_size,
      swift_password                => $swift_password,
      swift_hash_suffix             => $swift_hash_suffix,
      swift_hash_prefix             => $swift_hash_prefix,
      swift_servers                 => $swift_servers,
      swift_servers_hostnames       => $swift_servers_hostnames,
      swift_storage_drive           => $swift_storage_drive,
      swift_storage_partition_type  => $swift_storage_partition_type,
      nova_libvirt_type             => $nova_libvirt_type,
      nova_password                 => $nova_password,
      neutron_password              => $neutron_password,
      neutron_shared_secret         => $neutron_shared_secret,
      neutron_core_plugin           => $neutron_core_plugin,
      neutron_service_plugins       => $neutron_service_plugins,
      neutron_tunneling             => $neutron_tunneling,
      neutron_tunnel_types          => $neutron_tunnel_types,
      neutron_tenant_network_type   => $neutron_tenant_network_type,
      neutron_type_drivers          => $neutron_type_drivers,
      neutron_mechanism_drivers     => $neutron_mechanism_drivers,
      neutron_tunnel_id_ranges      => $neutron_tunnel_id_ranges,
      min_l3_agents_per_router      => $min_l3_agents_per_router,
      max_l3_agents_per_router      => $max_l3_agents_per_router,
      ceilometer_address_management => $ceilometer_address_management,
      ceilometer_mongo_username     => $ceilometer_mongo_username,
      ceilometer_mongo_password     => $ceilometer_mongo_password,
      ceilometer_password           => $ceilometer_password,
      ceilometer_meteringsecret     => $ceilometer_meteringsecret,
      heat_password                 => $heat_password,
      heat_encryption_key           => $heat_encryption_key,
      horizon_secret_key            => $horizon_secret_key,
      verbose                       => $verbose,
      debug                         => $debug,
      tempest_configure_images      => $tempest_configure_images,
      tempest_image_name            => $tempest_image_name,
      tempest_image_name_alt        => $tempest_image_name_alt,
      tempest_username              => $tempest_username,
      tempest_username_alt          => $tempest_username_alt,
      tempest_username_admin        => $tempest_username_admin,
      tempest_configure_network     => $tempest_configure_network,
      tempest_public_network_name   => $tempest_public_network_name,
      tempest_cinder_available      => $tempest_cinder_available,
      tempest_glance_available      => $tempest_glance_available,
      tempest_horizon_available     => $tempest_horizon_available,
      tempest_nova_available        => $tempest_nova_available,
      tempest_neutron_available     => $tempest_neutron_available,
      tempest_heat_available        => $tempest_heat_available,
      tempest_swift_available       => $tempest_swift_available,

      keepalived_interface          => $keepalived_interface,
      keepalived_virtual_ip         => $keepalived_virtual_ip,
      #keepalived_priority          => $keepalived_priority,
      keepalived_auth_pass          => $keepalived::auth_pass,

      haproxy_listen_ip             => $haproxy_listen_ip,
      haproxy_listen_ports          => $haproxy_listen_ports,
      haproxy_local_ip              => $haproxy_local_ip,
      haproxy_members               => $haproxy_members,

      galera_servers                => $galera_servers,
      galera_master                 => $galera_master,
      galera_vendor_type            => $galera_vendor_type,
      galera_local_ip               => $galera_local_ip,
      galera_root_password          => $galera_root_password,
      galera_status_password        => $galera_status_password,
      galera_repo_keyserver         => $galera_repo_keyserver,
      galera_repo_key               => $galera_repo_key,
      galera_repo_location          => $galera_repo_location,

    }
  }
}
