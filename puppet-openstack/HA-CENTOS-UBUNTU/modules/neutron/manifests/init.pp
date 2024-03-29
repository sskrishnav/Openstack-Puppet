# == Class: neutron
#
# Installs the neutron package and configures
# /etc/neutron/neutron.conf
#
# === Parameters:
#
# [*enabled*]
#   (required) Whether or not to enable the neutron service
#   true/false
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to 'present'
#
# [*verbose*]
#   (optional) Verbose logging
#   Defaults to False
#
# [*debug*]
#   (optional) Print debug messages in the logs
#   Defaults to False
#
# [*bind_host*]
#   (optional) The IP/interface to bind to
#   Defaults to 0.0.0.0 (all interfaces)
#
# [*bind_port*]
#   (optional) The port to use
#   Defaults to 9696
#
# [*core_plugin*]
#   (optional) Neutron plugin provider
#   Defaults to openvswitch
#   Could be bigswitch, brocade, cisco, embrane, hyperv, linuxbridge, midonet, ml2, mlnx, nec, nicira, plumgrid, ryu, opencontrail (full path)
#
#   Example for opencontrail:
#
#     class {'neutron' :
#       core_plugin => 'neutron.plugins.opencontrail.contrail_plugin:NeutronPluginContrailCoreV2'
#     }
#
# [*service_plugins*]
#   (optional) Advanced service modules.
#   Could be an array that can have these elements:
#   router, firewall, lbaas, vpnaas, metering
#   Defaults to empty
#
# [*auth_strategy*]
#   (optional) How to authenticate
#   Defaults to 'keystone'. 'noauth' is the only other valid option
#
# [*base_mac*]
#   (optional) The MAC address pattern to use.
#   Defaults to fa:16:3e:00:00:00
#
# [*mac_generation_retries*]
#   (optional) How many times to try to generate a unique mac
#   Defaults to 16
#
# [*dhcp_lease_duration*]
#   (optional) DHCP lease
#   Defaults to 86400 seconds
#
# [*dhcp_agents_per_network*]
#   (optional) Number of DHCP agents scheduled to host a network.
#   This enables redundant DHCP agents for configured networks.
#   Defaults to 1
#
# [*network_device_mtu*]
#   (optional) The MTU size for the interfaces managed by neutron
#   Defaults to undef
#
# [*dhcp_agent_notification*]
#   (optional) Allow sending resource operation notification to DHCP agent.
#   Defaults to true
#
# [*allow_bulk*]
#   (optional) Enable bulk crud operations
#   Defaults to true
#
# [*allow_pagination*]
#   (optional) Enable pagination
#   Defaults to false
#
# [*allow_sorting*]
#   (optional) Enable sorting
#   Defaults to false
#
# [*allow_overlapping_ips*]
#   (optional) Enables network namespaces
#   Defaults to false
#
# [*api_extensions_path*]
#   (optional) Specify additional paths for API extensions that the
#   module in use needs to load.
#   Defaults to undef
#
# [*report_interval*]
#   (optional) Seconds between nodes reporting state to server; should be less than
#   agent_down_time, best if it is half or less than agent_down_time.
#   agent_down_time is a config for neutron-server, set by class neutron::server
#   report_interval is a config for neutron agents, set by class neutron
#   Defaults to: 30
#
# [memcache_servers]
#   List of memcache servers in format of server:port.
#   Optional. Defaults to false. Example: ['localhost:11211']
#
# [*control_exchange*]
#   (optional) What RPC queue/exchange to use
#   Defaults to neutron

# [*rpc_backend*]
#   (optional) what rpc/queuing service to use
#   Defaults to impl_kombu (rabbitmq)
#
# [*rabbit_password*]
# [*rabbit_host*]
# [*rabbit_port*]
# [*rabbit_user*]
#   (optional) Various rabbitmq settings
#
# [*rabbit_hosts*]
#   (optional) array of rabbitmq servers for HA.
#   A single IP address, such as a VIP, can be used for load-balancing
#   multiple RabbitMQ Brokers.
#   Defaults to false
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to false
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to 'TLSv1'
#
# [*kombu_reconnect_delay*]
#   (optional) The amount of time to wait before attempting to reconnect
#   to MQ provider. This is used in some cases where you may need to wait
#   for the provider to propery premote the master before attempting to
#   reconnect. See https://review.openstack.org/#/c/76686
#   Defaults to '1.0'
#
# [*qpid_hostname*]
# [*qpid_port*]
# [*qpid_username*]
# [*qpid_password*]
# [*qpid_heartbeat*]
# [*qpid_protocol*]
# [*qpid_tcp_nodelay*]
# [*qpid_reconnect*]
# [*qpid_reconnect_timeout*]
# [*qpid_reconnect_limit*]
# [*qpid_reconnect_interval*]
# [*qpid_reconnect_interval_min*]
# [*qpid_reconnect_interval_max*]
#   (optional) various QPID options
#
# [*use_ssl*]
#   (optinal) Enable SSL on the API server
#   Defaults to false, not set
#
# [*cert_file*]
#   (optinal) certificate file to use when starting api server securely
#   defaults to false, not set
#
# [*key_file*]
#   (optional) Private key file to use when starting API server securely
#   Defaults to false, not set
#
# [*ca_file*]
#   (optional) CA certificate file to use to verify connecting clients
#   Defaults to false, not set
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to false
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to LOG_USER
#
# [*log_file*]
#   (optional) Where to log
#   Defaults to false
#
# [*log_dir*]
#   (optional) Directory where logs should be stored
#   If set to boolean false, it will not log to any directory
#   Defaults to /var/log/neutron
#
# [*state_path*]
#   (optional) Where to store state files. This directory must be writable
#   by the user executing the agent
#   Defaults to: /var/lib/neutron
#
# [*lock_path*]
#   (optional) Where to store lock files. This directory must be writeable
#   by the user executing the agent
#   Defaults to: /var/lib/neutron/lock
#
class neutron (
  $enabled                     = true,
  $package_ensure              = 'present',
  $verbose                     = false,
  $debug                       = false,
  $bind_host                   = '0.0.0.0',
  $bind_port                   = '9696',
  $core_plugin                 = 'openvswitch',
  $service_plugins             = undef,
  $auth_strategy               = 'keystone',
  $base_mac                    = 'fa:16:3e:00:00:00',
  $mac_generation_retries      = 16,
  $dhcp_lease_duration         = 86400,
  $dhcp_agents_per_network     = 2,
  $network_device_mtu          = undef,
  $dhcp_agent_notification     = true,
  $allow_bulk                  = true,
  $allow_pagination            = false,
  $allow_sorting               = false,
  $allow_overlapping_ips       = false,
  $api_extensions_path         = undef,
  $root_helper                 = 'sudo neutron-rootwrap /etc/neutron/rootwrap.conf',
  $report_interval             = '30',
  $memcache_servers            = false,
  $control_exchange            = 'neutron',
  $rpc_backend                 = 'rabbit',
  $rabbit_password             = false,
  $rabbit_host                 = 'localhost',
  $rabbit_hosts                = false,
  $rabbit_port                 = '5672',
  $rabbit_user                 = 'guest',
  $rabbit_virtual_host         = '/',
  $rabbit_use_ssl              = false,
  $kombu_ssl_ca_certs          = undef,
  $kombu_ssl_certfile          = undef,
  $kombu_ssl_keyfile           = undef,
  $kombu_ssl_version           = 'TLSv1',
  $kombu_reconnect_delay       = '1.0',
  $qpid_hostname               = 'localhost',
  $qpid_port                   = '5672',
  $qpid_username               = 'guest',
  $qpid_password               = 'guest',
  $qpid_heartbeat              = 60,
  $qpid_protocol               = 'tcp',
  $qpid_tcp_nodelay            = true,
  $qpid_reconnect              = true,
  $qpid_reconnect_timeout      = 0,
  $qpid_reconnect_limit        = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval     = 0,
  $use_ssl                     = false,
  $cert_file                   = false,
  $key_file                    = false,
  $ca_file                     = false,
  $use_syslog                  = false,
  $log_facility                = 'LOG_USER',
  $log_file                    = false,
  $log_dir                     = '/var/log/neutron',
  $state_path                  = '/var/lib/neutron',
  $lock_path                   = '/var/lib/neutron/lock',
) {

  include ::neutron::params

  Package["$::neutron::params::package_name"] -> Neutron_config<||>
  Package["$::neutron::params::package_name"] -> Nova_Admin_Tenant_Id_Setter<||>

  if $use_ssl {
    if !$cert_file {
      fail('The cert_file parameter is required when use_ssl is set to true')
    }
    if !$key_file {
      fail('The key_file parameter is required when use_ssl is set to true')
    }
  }

  if $ca_file and !$use_ssl {
    fail('The ca_file parameter requires that use_ssl to be set to true')
  }

  if $kombu_ssl_ca_certs and !$rabbit_use_ssl {
    fail('The kombu_ssl_ca_certs parameter requires rabbit_use_ssl to be set to true')
  }
  if $kombu_ssl_certfile and !$rabbit_use_ssl {
    fail('The kombu_ssl_certfile parameter requires rabbit_use_ssl to be set to true')
  }
  if $kombu_ssl_keyfile and !$rabbit_use_ssl {
    fail('The kombu_ssl_keyfile parameter requires rabbit_use_ssl to be set to true')
  }
  if ($kombu_ssl_certfile and !$kombu_ssl_keyfile) or ($kombu_ssl_keyfile and !$kombu_ssl_certfile) {
    fail('The kombu_ssl_certfile and kombu_ssl_keyfile parameters must be used together')
  }

  if $memcache_servers {
    validate_array($memcache_servers)
  }

  File {
    require => Package["$::neutron::params::package_name"],
    owner   => 'root',
    group   => 'neutron',
  }

  file { '/etc/neutron':
    ensure => directory,
  }

  file { '/etc/neutron/neutron.conf': }

  package { "$::neutron::params::package_name":
    ensure => $package_ensure,
    name   => $::neutron::params::package_name,
    tag    => 'openstack',
  }

  neutron_config {
    'DEFAULT/verbose':                 value => $verbose;
    'DEFAULT/debug':                   value => $debug;
    'DEFAULT/bind_host':               value => $bind_host;
    'DEFAULT/bind_port':               value => $bind_port;
    'DEFAULT/auth_strategy':           value => $auth_strategy;
    'DEFAULT/core_plugin':             value => $core_plugin;
    #'DEFAULT/base_mac':                value => $base_mac;
    'DEFAULT/mac_generation_retries':  value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':     value => $dhcp_lease_duration;
    'DEFAULT/dhcp_agents_per_network': value => $dhcp_agents_per_network;
    'DEFAULT/dhcp_agent_notification': value => $dhcp_agent_notification;
    'DEFAULT/allow_bulk':              value => $allow_bulk;
    'DEFAULT/allow_pagination':        value => $allow_pagination;
    'DEFAULT/allow_sorting':           value => $allow_sorting;
    'DEFAULT/allow_overlapping_ips':   value => $allow_overlapping_ips;
    'DEFAULT/control_exchange':        value => $control_exchange;
    'DEFAULT/rpc_backend':             value => $rpc_backend;
    #'DEFAULT/api_extensions_path':     value => $api_extensions_path;
    'DEFAULT/state_path':              value => $state_path;
    'DEFAULT/lock_path':               value => $lock_path;
    'agent/root_helper':               value => $root_helper;
    'agent/report_interval':           value => $report_interval;
  }

  if $log_file {
    neutron_config {
      'DEFAULT/log_file': value => $log_file;
      'DEFAULT/log_dir':  value => $log_dir;
    }
  } else {
    if $log_dir {
      neutron_config {
        'DEFAULT/log_dir':  value  => $log_dir;
        'DEFAULT/log_file': ensure => absent;
      }
    } else {
      neutron_config {
        'DEFAULT/log_dir':  ensure => $log_dir;
        'DEFAULT/log_file': ensure => absent;
      }
    }
  }

  if $network_device_mtu {
    neutron_config {
      'DEFAULT/network_device_mtu':           value => $network_device_mtu;
    }
  } else {
    neutron_config {
      'DEFAULT/network_device_mtu':           ensure => absent;
    }
  }


  if $service_plugins {
    if is_array($service_plugins) {
      neutron_config { 'DEFAULT/service_plugins': value => join($service_plugins, ',') }
    } else {
      fail('service_plugins should be an array.')
    }
  }

  #if $memcache_servers {
  #  neutron_config {
  #    'DEFAULT/memcached_servers':  value => join($memcache_servers, ',');
  #  }
  #} else {
  #  neutron_config {
  #    'DEFAULT/memcached_servers':  ensure => absent;
  #  }
  #}


  if $rpc_backend == 'rabbit' {
    if ! $rabbit_password {
      fail('When rpc_backend is rabbitmq, you must set rabbit password')
    }
    if $rabbit_hosts {
      neutron_config { 'oslo_messaging_rabbit/rabbit_hosts':     value  => join($rabbit_hosts, ',') }
      neutron_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value  => true }
    } else  {
      neutron_config { 'oslo_messaging_rabbit/rabbit_host':      value => $rabbit_host }
      neutron_config { 'oslo_messaging_rabbit/rabbit_port':      value => $rabbit_port }
      neutron_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
      neutron_config { 'oslo_messaging_rabbit/rabbit_ha_queues': ensure=> absent; }
    }

    neutron_config {
      'oslo_messaging_rabbit/rabbit_userid':         value => $rabbit_user;
      'oslo_messaging_rabbit/rabbit_password':       value => $rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_virtual_host':   value => $rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl':        value => $rabbit_use_ssl;
      'oslo_messaging_rabbit/kombu_reconnect_delay': value => $kombu_reconnect_delay;
    }

    if $rabbit_use_ssl {

      if $kombu_ssl_ca_certs {
        neutron_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs; }
      } else {
        neutron_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $kombu_ssl_certfile or $kombu_ssl_keyfile {
        neutron_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': value => $kombu_ssl_certfile;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  value => $kombu_ssl_keyfile;
        }
      } else {
        neutron_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $kombu_ssl_version {
        neutron_config { 'oslo_messaging_rabbit/kombu_ssl_version':  value => $kombu_ssl_version; }
      } else {
        neutron_config { 'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      neutron_config {
        'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
      }
    }

  }

  if $rpc_backend == 'neutron.openstack.common.rpc.impl_qpid' {
    neutron_config {
      'DEFAULT/qpid_hostname':               value => $qpid_hostname;
      'DEFAULT/qpid_port':                   value => $qpid_port;
      'DEFAULT/qpid_username':               value => $qpid_username;
      'DEFAULT/qpid_password':               value => $qpid_password, secret => true;
      'DEFAULT/qpid_heartbeat':              value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol':               value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay':            value => $qpid_tcp_nodelay;
      'DEFAULT/qpid_reconnect':              value => $qpid_reconnect;
      'DEFAULT/qpid_reconnect_timeout':      value => $qpid_reconnect_timeout;
      'DEFAULT/qpid_reconnect_limit':        value => $qpid_reconnect_limit;
      'DEFAULT/qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'DEFAULT/qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'DEFAULT/qpid_reconnect_interval':     value => $qpid_reconnect_interval;
    }
  }

  # SSL Options
  neutron_config { 'DEFAULT/use_ssl' : value => $use_ssl; }
  if $use_ssl {
    neutron_config {
      'DEFAULT/use_ssl'       : value => $use_ssl;
      'DEFAULT/ssl_cert_file' : value => $cert_file;
      'DEFAULT/ssl_key_file'  : value => $key_file;
    }
    if $ca_file {
      neutron_config { 'DEFAULT/ssl_ca_file'   : value => $ca_file; }
    } else {
      neutron_config { 'DEFAULT/ssl_ca_file'   : ensure => absent; }
    }
  } 
  #else {
  #  neutron_config {
  #    'DEFAULT/use_ssl'      : ensure => absent;
  #    'DEFAULT/ssl_cert_file': ensure => absent;
  #    'DEFAULT/ssl_key_file':  ensure => absent;
  #    'DEFAULT/ssl_ca_file':   ensure => absent;
  #  }
  #}

  if $use_syslog {
    neutron_config {
      'DEFAULT/use_syslog':           value => true;
      'DEFAULT/syslog_log_facility':  value => $log_facility;
    }
  } else {
    neutron_config {
      'DEFAULT/use_syslog':           value => false;
    }
  }
}
