# == Class: nova::api

#
# Setup and configure the Nova API endpoint
#
# === Parameters
#
# [*admin_password*]
#   (required) The password to set for the nova admin user in keystone
#
# [*enabled*]
#   (optional) Whether the nova api service will be run
#   Defaults to false
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*ensure_package*]
#   (optional) Whether the nova api package will be installed
#   Defaults to 'present'
#
# [*auth_strategy*]
#   (DEPRECATED) Does nothing and will be removed in Icehouse
#   Defaults to false
#
# [*auth_host*]
#   (optional) The IP of the server running keystone
#   Defaults to '127.0.0.1'
#
# [*auth_port*]
#   (optional) The port to use when authenticating against Keystone
#   Defaults to 35357
#
# [*auth_protocol*]
#   (optional) The protocol to use when authenticating against Keystone
#   Defaults to 'http'
#
# [*auth_uri*]
#   (optional) The uri of a Keystone service to authenticate against
#   Defaults to false
#
# [*auth_admin_prefix*]
#   (optional) Prefix to prepend at the beginning of the keystone path
#   Defaults to false
#
# [*auth_version*]
#   (optional) API version of the admin Identity API endpoint
#   for example, use 'v3.0' for the keystone version 3.0 api
#   Defaults to false
#
# [*admin_tenant_name*]
#   (optional) The name of the tenant to create in keystone for use by the nova services
#   Defaults to 'services'
#
# [*admin_user*]
#   (optional) The name of the user to create in keystone for use by the nova services
#   Defaults to 'nova'
#
# [*api_bind_address*]
#   (optional) IP address for nova-api server to listen
#   Defaults to '0.0.0.0'
#
# [*metadata_listen*]
#   (optional) IP address  for metadata server to listen
#   Defaults to '0.0.0.0'
#
# [*enabled_apis*]
#   (optional) A comma separated list of apis to enable
#   Defaults to 'ec2,osapi_compute,metadata'
#
# [*keystone_ec2_url*]
#   (optional) The keystone url where nova should send requests for ec2tokens
#   Defaults to false
#
# [*volume_api_class*]
#   (optional) The name of the class that nova will use to access volumes. Cinder is the only option.
#   Defaults to 'nova.volume.cinder.API'
#
# [*use_forwarded_for*]
#   (optional) Treat X-Forwarded-For as the canonical remote address. Only
#   enable this if you have a sanitizing proxy.
#   Defaults to false
#
# [*osapi_compute_workers*]
#   (optional) Number of workers for OpenStack API service
#   Defaults to $::processorcount
#
# [*ec2_workers*]
#   (optional) Number of workers for EC2 service
#   Defaults to $::processorcount
#
# [*metadata_workers*]
#   (optional) Number of workers for metadata service
#   Defaults to $::processorcount
#
# [*conductor_workers*]
#   (optional) DEPRECATED. Use workers parameter of nova::conductor
#   Class instead.
#   Defaults to undef
#
# [*sync_db*]
#   (optional) Run nova-manage db sync on api nodes after installing the package.
#   Defaults to true
#
# [*neutron_metadata_proxy_shared_secret*]
#   (optional) Shared secret to validate proxies Neutron metadata requests
#   Defaults to undef
#
# [*pci_alias*]
#   (optional) Pci passthrough for controller:
#   Defaults to undef
#   Example
#   "[ {'vendor_id':'1234', 'product_id':'5678', 'name':'default'}, {...} ]"
#
# [*ratelimits*]
#   (optional) A string that is a semicolon-separated list of 5-tuples.
#   See http://docs.openstack.org/trunk/config-reference/content/configuring-compute-API.html
#   Example: '(POST, "*", .*, 10, MINUTE);(POST, "*/servers", ^/servers, 50, DAY);(PUT, "*", .*, 10, MINUTE)'
#   Defaults to undef
#
# [*ratelimits_factory*]
#   (optional) The rate limiting factory to use
#   Defaults to 'nova.api.openstack.compute.limits:RateLimitingMiddleware.factory'
#
# [*osapi_v3*]
#   (optional) Enable or not Nova API v3
#   Defaults to false
#
# [*validate*]
#   (optional) Whether to validate the service is working after any service refreshes
#   Defaults to false
#
# [*validation_options*]
#   (optional) Service validation options
#   Should be a hash of options defined in openstacklib::service_validation
#   If empty, defaults values are taken from openstacklib function.
#   Default command list nova flavors.
#   Require validate set at True.
#   Example:
#   nova::api::validation_options:
#     nova-api:
#       command: check_nova.py
#       path: /usr/bin:/bin:/usr/sbin:/sbin
#       provider: shell
#       tries: 5
#       try_sleep: 10
#   Defaults to {}
#
class nova::api(
  $admin_password        = undef,
  $enabled               = false,
  $manage_service        = true,
  $ensure_package        = 'present',
  $auth_strategy         = undef,
  $auth_host             = '127.0.0.1',
  $auth_port             = 35357,
  $auth_protocol         = 'http',
  $auth_uri              = false,
  $auth_admin_prefix     = false,
  $auth_version          = false,
  $admin_tenant_name     = 'service',
  $admin_user            = 'nova',
  $api_bind_address      = '0.0.0.0',
  $metadata_listen       = '0.0.0.0',
  $enabled_apis          = 'ec2,osapi_compute',
  $keystone_ec2_url      = false,
  $volume_api_class      = 'nova.volume.cinder.API',
  $use_forwarded_for     = false,
  $osapi_compute_workers = $::processorcount,
  $ec2_workers           = $::processorcount,
  $metadata_workers      = $::processorcount,
  $sync_db               = true,
  $neutron_metadata_proxy_shared_secret = undef,
  $osapi_v3              = false,
  $pci_alias             = undef,
  $ratelimits            = undef,
  $ratelimits_factory    =
    'nova.api.openstack.compute.limits:RateLimitingMiddleware.factory',
  $validate              = false,
  $validation_options    = {},
  $rabbit_userid         = undef,
  $rabbit_password       = undef,
  $rabbit_hosts       = undef,
  
  # DEPRECATED PARAMETER
  $workers               = undef,
  $conductor_workers     = undef,
) {
  $vip_ip = $::openstack::config::haproxy_listen_ip
  #include nova::db
  include nova
  include nova::params
  include nova::policy
  require keystone::python
  include cinder::client

  #Package<| title == 'nova-api' |> -> Nova_paste_api_ini<| |>

  #Package<| title == 'nova-common' |> -> Class['nova::api']
  #Package<| title == 'nova-common' |> -> Class['nova::policy']

  #Nova_paste_api_ini<| |> ~> Exec['post-nova_config']

  #Nova_paste_api_ini<| |> ~> Service['nova-api']
  #Class['nova::policy'] ~> Service['nova-api']

  if $auth_strategy {
    warning('The auth_strategy parameter is deprecated and has no effect.')
  }

  if $workers {
    warning('The workers parameter is deprecated, use osapi_compute_workers instead.')
    $osapi_compute_workers_real = $workers
  } else {
    $osapi_compute_workers_real = $osapi_compute_workers
  }

  if $conductor_workers {
    warning('The conductor_workers parameter is deprecated and has no effect. Use workers parameter of nova::conductor class instead.')
  }

  nova::generic_service { 'api':
    enabled        => $enabled,
    manage_service => $manage_service,
    ensure_package => $ensure_package,
    package_name   => $::nova::params::api_package_name,
    service_name   => $::nova::params::api_service_name,
    subscribe      => Class['cinder::client'],
  }

  nova_config {
    'DEFAULT/enabled_apis':          value => $enabled_apis;
    'DEFAULT/volume_api_class':      value => $volume_api_class;
    'DEFAULT/ec2_listen':            value => $api_bind_address;
    'DEFAULT/osapi_compute_listen':  value => $auth_host;
    'DEFAULT/metadata_listen':       value => $metadata_listen;
    'DEFAULT/osapi_volume_listen':   value => $api_bind_address;
    'DEFAULT/osapi_compute_workers': value => $osapi_compute_workers_real;
    'DEFAULT/ec2_workers':           value => $ec2_workers;
    'DEFAULT/metadata_workers':      value => $metadata_workers;
    'DEFAULT/use_forwarded_for':     value => $use_forwarded_for;
    'DEFAULT/auth_strategy':         value => 'keystone';
    'DEFAULT/rpc_backend':           value => 'rabbit';
    'osapi_v3/enabled':              value => $osapi_v3;
    'DEFAULT/api_paste_config':      value => '/etc/nova/api-paste.ini';
    'DEFAULT/ec2_private_dns_show_ip':      value => 'True';
  }
  if $::osfamily == 'Debian' {
     nova_config {
          'DEFAULT/enabled_apis':          value => 'ec2,osapi_compute,metadata';
     }
  }
  elsif $::osfamily == 'RedHat' {
     nova_config {
          'DEFAULT/enabled_apis':          value => 'ec2,osapi_compute';
     }
  }
  
  #nova_config {
  #  'database/connection':           value  => "mysql://nova:$admin_password@$vip_ip/nova";
  #}

  if ($neutron_metadata_proxy_shared_secret){
    nova_config {
      'neutron/service_metadata_proxy': value => true;
      'neutron/metadata_proxy_shared_secret':
        value => $neutron_metadata_proxy_shared_secret;
    }
  } else {
    nova_config {
      'neutron/service_metadata_proxy':       value  => true;
      'neutron/metadata_proxy_shared_secret': ensure => absent;
    }
  }

  if $auth_uri {
    $auth_uri_real = $auth_uri
  } else {
    $auth_uri_real = "${auth_protocol}://${vip_ip}:5000"
    $auth_url_real = "${auth_protocol}://${vip_ip}:35357"
  }
  nova_config { 'keystone_authtoken/auth_uri': value => $auth_uri_real; }

  if $auth_version {
    nova_config { 'keystone_authtoken/auth_version': value => $auth_version; }
  } else {
    nova_config { 'keystone_authtoken/auth_version': ensure => absent; }
  }

  nova_config {
    #'keystone_authtoken/auth_host':         value => $auth_host;
    #'keystone_authtoken/auth_port':         value => $auth_port;
    #'keystone_authtoken/auth_protocol':     value => $auth_protocol;
    #'keystone_authtoken/admin_tenant_name': value => $admin_tenant_name;
    'keystone_authtoken/username':        value => $admin_user;
    'keystone_authtoken/password':    value => $admin_password, secret => true;
    'keystone_authtoken/auth_plugin': value => 'password';
    'keystone_authtoken/project_domain_id': value => 'default';
    'keystone_authtoken/user_domain_id': value => 'default';
    'keystone_authtoken/identity_uri'     : ensure => absent;
    'keystone_authtoken/project_name': value => 'services';
    'keystone_authtoken/auth_url': value => $auth_url_real;
    'oslo_messaging_rabbit/rabbit_host':    ensure => absent;
    'oslo_messaging_rabbit/rabbit_hosts':     value => join($::openstack::config::rabbitmq_hosts, ',');
    'oslo_messaging_rabbit/rabbit_userid':    value => $rabbit_userid;
    'oslo_messaging_rabbit/rabbit_password':    value => $rabbit_password;
  }
  nova_config {
    'DEFAULT/compute_driver':   value => 'libvirt.LibvirtDriver';
    'libvirt/virt_type':        value => 'qemu';
    #'libvirt/cpu_mode':         value => $libvirt_cpu_mode_real;
    #'libvirt/inject_password':  value => $libvirt_inject_password;
    #'libvirt/inject_key':       value => $libvirt_inject_key;
    #'libvirt/inject_partition': value => $libvirt_inject_partition;
  }
  nova_config {
    'oslo_concurrency/lock_path':    value => '/var/lib/nova/tmp';
  }

  if $auth_admin_prefix {
    validate_re($auth_admin_prefix, '^(/.+[^/])?$')
    nova_config {
      'keystone_authtoken/auth_admin_prefix': value => $auth_admin_prefix;
    }
  } else {
    nova_config {
      'keystone_authtoken/auth_admin_prefix': ensure => absent;
    }
  }

  if $keystone_ec2_url {
    nova_config {
      'DEFAULT/keystone_ec2_url': value => $keystone_ec2_url;
      #package { 'python-pip':
      #  ensure => latest,
      #}
    }
    if !defined(Package['pyssf']) {
      package { 'pyssf':
        ensure   => latest,
        provider => pip,
        require  => Package['python-pip']
      }
    }
    package { 'openstackocci':
      ensure   => latest,
      provider => 'pip',
      require  => Package['python-pip'],
    }
  }

  if ($ratelimits != undef) {
    nova_paste_api_ini {
      'filter:ratelimit/paste.filter_factory': value => $ratelimits_factory;
      'filter:ratelimit/limits':               value => $ratelimits;
    }
  }

  # Added arg and if statement prevents this from being run
  # where db is not active i.e. the compute
  if $sync_db {
    Package<| title == 'nova-api' |> -> Exec['nova-db-sync']
    exec { 'nova-db-sync':
      command     => '/usr/bin/nova-manage db sync',
      refreshonly => true,
      #subscribe   => Exec['post-nova_config'],
    }
  }

  # Remove auth configuration from api-paste.ini
  nova_paste_api_ini {
    'filter:authtoken/auth_uri':          ensure => absent;
    'filter:authtoken/auth_host':         ensure => absent;
    'filter:authtoken/auth_port':         ensure => absent;
    'filter:authtoken/auth_protocol':     ensure => absent;
    'filter:authtoken/admin_tenant_name': ensure => absent;
    'filter:authtoken/admin_user':        ensure => absent;
    'filter:authtoken/admin_password':    ensure => absent;
    'filter:authtoken/auth_admin_prefix': ensure => absent;
  }

  if $pci_alias {
    nova_config {
      'DEFAULT/pci_alias': value => check_array_of_hash($pci_alias);
    }
  }

  if $validate {
    $defaults = {
      'nova-api' => {
        'command'  => "nova --os-auth-url ${auth_uri_real} --os-tenant-name ${admin_tenant_name} --os-username ${admin_user} --os-password ${admin_password} flavor-list",
      }
    }
    $validation_options_hash = merge ($defaults, $validation_options)
    create_resources('openstacklib::service_validation', $validation_options_hash, {'subscribe' => 'Service[nova-api]'})
  }
}
