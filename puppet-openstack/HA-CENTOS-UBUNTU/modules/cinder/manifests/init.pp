# == Class: cinder
#
#  Cinder base package & configuration
#
# === Parameters
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to 'false'
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to 'false'
#
# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to false.
#
# [*database_connection*]
#    Url used to connect to database.
#    (Optional) Defaults to
#    'sqlite:////var/lib/cinder/cinder.sqlite'
#
# [*database_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to 3600.
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to 1.
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to undef.
#
# [*database_max_retries*]
#   Maximum db connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to 10.
#
# [*database_retry_interval*]
#   Interval between retries of opening a sql connection.
#   (Optional) Defaults to 10.
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to undef.
#
# [*rpc_backend*]
#   (Optional) Use these options to configure the RabbitMQ message system.
#   Defaults to 'cinder.openstack.common.rpc.impl_kombu'
#
# [*control_exchange*]
#   (Optional)
#   Defaults to 'openstack'.
#
# [*rabbit_host*]
#   (Optional) IP or hostname of the rabbit server.
#   Defaults to '127.0.0.1'
#
# [*rabbit_port*]
#   (Optional) Port of the rabbit server.
#   Defaults to 5672.
#
# [*rabbit_hosts*]
#   (Optional) Array of host:port (used with HA queues).
#   If defined, will remove rabbit_host & rabbit_port parameters from config
#   Defaults to undef.
#
# [*rabbit_userid*]
#   (Optional) User to connect to the rabbit server.
#   Defaults to 'guest'
#
# [*rabbit_password*]
#   (Required) Password to connect to the rabbit_server.
#   Defaults to empty. Required if using the Rabbit (kombu)
#   backend.
#
# [*rabbit_virtual_host*]
#   (Optional) Virtual_host to use.
#   Defaults to '/'
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
# [*amqp_durable_queues*]
#   Use durable queues in amqp.
#   (Optional) Defaults to false.
#
# [*qpid_hostname*]
#   (Optional) Location of qpid server
#   Defaults to 'localhost'.
#
# [*qpid_port*]
#   (Optional) Port for qpid server.
#   Defaults to '5672'.
#
# [*qpid_username*]
#   (Optional) Username to use when connecting to qpid.
#   Defaults to 'guest'.
#
# [*qpid_password*]
#   (Optional) Password to use when connecting to qpid.
#   Defaults to 'false'.
#
# [*qpid_sasl_mechanisms*]
#   (Optional) ENable one or more SASL mechanisms.
#   Defaults to 'false'.
#
# [*qpid_heartbeat*]
#   (Optional) Seconds between connection keepalive heartbeats.
#   Defaults to '60'.
#
# [*qpid_protocol*]
#   (Optional) Transport to use, either 'tcp' or 'ssl'.
#   Defaults to 'tcp'.
#
# [*qpid_tcp_nodelay*]
#   (Optional) Disable Nagle Algorithm.
#   Defaults to 'true'.
#
# [*qpid_reconnect*]
#
# [*qpid_reconnect_timeout*]
#
# [*qpid_reconnect_limit*]
#
# [*qpid_reconnect_interval*]
#
# [*qpid_reconnect_interval_min*]
#
# [*qpid_reconnect_interval_max*]
#
# [*use_syslog]
#   Use syslog for logging.
#   (Optional) Defaults to false.
#
# [*log_facility*]
#   Syslog facility to receive log lines.
#   (Optional) Defaults to LOG_USER.
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/cinder'
#
# [*use_ssl*]
#   (optional) Enable SSL on the API server
#   Defaults to false, not set
#
# [*cert_file*]
#   (optinal) Certificate file to use when starting API server securely
#   Defaults to false, not set
#
# [*key_file*]
#   (optional) Private key file to use when starting API server securely
#   Defaults to false, not set
#
# [*ca_file*]
#   (optional) CA certificate file to use to verify connecting clients
#   Defaults to false, not set_
#
# [*storage_availability_zone*]
#   (optional) Availability zone of the node.
#   Defaults to 'nova'
#
# [*default_availability_zone*]
#   (optional) Default availability zone for new volumes.
#   If not set, the storage_availability_zone option value is used as
#   the default for new volumes.
#   Defaults to false
#
# [*api_paste_config*]
#   (Optional)
#   Defaults to '/etc/cinder/api-paste.ini',
#
# [*enable_v1_api*]
#   (Optional) Whether to enable the v1 API (true/false).
#   This will be deprecated in Kilo.
#   Defaults to 'true'.
#
# [*enable_v2_api*]
#   (Optional) Whether to enable the v1 API (true/false).
#   Defaults to 'true'.
#
# === Deprecated Parameters
#
# [*mysql_module*]
#   DEPRECATED. Does nothing.
#
class cinder (
  $database_connection         = 'sqlite:////var/lib/cinder/cinder.sqlite',
  $database_idle_timeout       = '3600',
  $database_min_pool_size      = '1',
  $database_max_pool_size      = undef,
  $database_max_retries        = '10',
  $database_retry_interval     = '10',
  $database_max_overflow       = undef,
  $rpc_backend                 = 'cinder.openstack.common.rpc.impl_kombu',
  $control_exchange            = 'openstack',
  $rabbit_host                 = '127.0.0.1',
  $rabbit_port                 = 5672,
  $rabbit_hosts                = false,
  $rabbit_virtual_host         = '/',
  $rabbit_userid               = 'guest',
  $rabbit_password             = false,
  $rabbit_use_ssl              = false,
  $kombu_ssl_ca_certs          = undef,
  $kombu_ssl_certfile          = undef,
  $kombu_ssl_keyfile           = undef,
  $kombu_ssl_version           = 'TLSv1',
  $amqp_durable_queues         = false,
  $qpid_hostname               = 'localhost',
  $qpid_port                   = '5672',
  $qpid_username               = 'guest',
  $qpid_password               = false,
  $qpid_sasl_mechanisms        = false,
  $qpid_reconnect              = true,
  $qpid_reconnect_timeout      = 0,
  $qpid_reconnect_limit        = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval     = 0,
  $qpid_heartbeat              = 60,
  $qpid_protocol               = 'tcp',
  $qpid_tcp_nodelay            = true,
  $package_ensure              = 'present',
  $use_ssl                     = false,
  $ca_file                     = false,
  $cert_file                   = false,
  $key_file                    = false,
  $api_paste_config            = '/etc/cinder/api-paste.ini',
  $use_syslog                  = false,
  $log_facility                = 'LOG_USER',
  $log_dir                     = '/var/log/cinder',
  $verbose                     = false,
  $debug                       = false,
  $storage_availability_zone   = 'nova',
  $default_availability_zone   = false,
  $enable_v1_api               = true,
  $enable_v2_api               = true,
  # DEPRECATED PARAMETERS
  $mysql_module                = undef,
) {

  include ::cinder::params
  Package["$::cinder::params::package_name"] -> Cinder_config<||>
  Package["$::cinder::params::package_name"] -> Cinder_api_paste_ini<||>
  

  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  if $use_ssl {
    if !$cert_file {
      fail('The cert_file parameter is required when use_ssl is set to true')
    }
    if !$key_file {
      fail('The key_file parameter is required when use_ssl is set to true')
    }
  }

  # this anchor is used to simplify the graph between cinder components by
  # allowing a resource to serve as a point where the configuration of cinder begins
  anchor { 'cinder-start': }
  package { "$::cinder::params::package_name":
    ensure  => $package_ensure,
    name    => $::cinder::params::package_name,
    tag     => 'openstack',
    require => Anchor['cinder-start'],
  }
  

  if $rpc_backend == 'cinder.openstack.common.rpc.impl_kombu' {

    if ! $rabbit_password {
      fail('Please specify a rabbit_password parameter.')
    }

    cinder_config {
      'oslo_messaging_rabbit/rabbit_password':     value => $rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_userid':       value => $rabbit_userid;
      'oslo_messaging_rabbit/rabbit_virtual_host': value => $rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl':      value => $rabbit_use_ssl;
      'DEFAULT/control_exchange':    value => $control_exchange;
      'DEFAULT/amqp_durable_queues': value => $amqp_durable_queues;
    }

    if $rabbit_hosts {
      cinder_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => join($rabbit_hosts, ',') }
      cinder_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => true }
      cinder_config { 'oslo_messaging_rabbit/rabbit_host':      ensure => absent }
      cinder_config { 'oslo_messaging_rabbit/rabbit_port':      ensure => absent }
    } else {
      cinder_config { 'oslo_messaging_rabbit/rabbit_host':      value => $rabbit_host }
      cinder_config { 'oslo_messaging_rabbit/rabbit_port':      value => $rabbit_port }
      cinder_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
      cinder_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
    }

    if $rabbit_use_ssl {
      cinder_config { 'oslo_messaging_rabbit/kombu_ssl_version': value => $kombu_ssl_version }

      if $kombu_ssl_ca_certs {
        cinder_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs }
      } else {
        cinder_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent}
      }

      if $kombu_ssl_certfile {
        cinder_config { 'oslo_messaging_rabbit/kombu_ssl_certfile': value => $kombu_ssl_certfile }
      } else {
        cinder_config { 'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent}
      }

      if $kombu_ssl_keyfile {
        cinder_config { 'oslo_messaging_rabbit/kombu_ssl_keyfile': value => $kombu_ssl_keyfile }
      } else {
        cinder_config { 'oslo_messaging_rabbit/kombu_ssl_keyfile': ensure => absent}
      }
    } else {
      cinder_config {
        'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
      }
    }

  }

  if $rpc_backend == 'cinder.openstack.common.rpc.impl_qpid' {

    if ! $qpid_password {
      fail('Please specify a qpid_password parameter.')
    }

    cinder_config {
      'DEFAULT/qpid_hostname':               value => $qpid_hostname;
      'DEFAULT/qpid_port':                   value => $qpid_port;
      'DEFAULT/qpid_username':               value => $qpid_username;
      'DEFAULT/qpid_password':               value => $qpid_password, secret => true;
      'DEFAULT/qpid_reconnect':              value => $qpid_reconnect;
      'DEFAULT/qpid_reconnect_timeout':      value => $qpid_reconnect_timeout;
      'DEFAULT/qpid_reconnect_limit':        value => $qpid_reconnect_limit;
      'DEFAULT/qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'DEFAULT/qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'DEFAULT/qpid_reconnect_interval':     value => $qpid_reconnect_interval;
      'DEFAULT/qpid_heartbeat':              value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol':               value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay':            value => $qpid_tcp_nodelay;
      'DEFAULT/amqp_durable_queues':         value => $amqp_durable_queues;
    }

    if is_array($qpid_sasl_mechanisms) {
      cinder_config {
        'DEFAULT/qpid_sasl_mechanisms': value => join($qpid_sasl_mechanisms, ' ');
      }
    } elsif $qpid_sasl_mechanisms {
      cinder_config {
        'DEFAULT/qpid_sasl_mechanisms': value => $qpid_sasl_mechanisms;
      }
    } else {
      cinder_config {
        'DEFAULT/qpid_sasl_mechanisms': ensure => absent;
      }
    }
  }

  if ! $default_availability_zone {
    $default_availability_zone_real = $storage_availability_zone
  } else {
    $default_availability_zone_real = $default_availability_zone
  }

  cinder_config {
    'database/connection':               value => $database_connection, secret => true;
    'database/idle_timeout':             value => $database_idle_timeout;
    'database/min_pool_size':            value => $database_min_pool_size;
    'database/max_retries':              value => $database_max_retries;
    'database/retry_interval':           value => $database_retry_interval;
    'DEFAULT/verbose':                   value => $verbose;
    'DEFAULT/debug':                     value => $debug;
    'DEFAULT/api_paste_config':          value => $api_paste_config;
    'DEFAULT/rpc_backend':               value => $rpc_backend;
    'DEFAULT/storage_availability_zone': value => $storage_availability_zone;
    'DEFAULT/default_availability_zone': value => $default_availability_zone_real;
  }

  if $database_max_pool_size {
    cinder_config {
      'database/max_pool_size': value => $database_max_pool_size;
    }
  } else {
    cinder_config {
      'database/max_pool_size': ensure => absent;
    }
  }

  if $database_max_overflow {
    cinder_config {
      'database/max_overflow': value => $database_max_overflow;
    }
  } else {
    cinder_config {
      'database/max_overflow': ensure => absent;
    }
  }

  if($database_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    require 'mysql::bindings'
    require 'mysql::bindings::python'
  } elsif($database_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

  } elsif($database_connection =~ /sqlite:\/\//) {

  } else {
    fail("Invalid db connection ${database_connection}")
  }

  if $log_dir {
    cinder_config {
      'DEFAULT/log_dir': value => $log_dir;
    }
  } else {
    cinder_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # SSL Options
  if $use_ssl {
    cinder_config {
      'DEFAULT/ssl_cert_file' : value => $cert_file;
      'DEFAULT/ssl_key_file' :  value => $key_file;
    }
    if $ca_file {
      cinder_config { 'DEFAULT/ssl_ca_file' :
        value => $ca_file,
      }
    } else {
      cinder_config { 'DEFAULT/ssl_ca_file' :
        ensure => absent,
      }
    }
  } else {
    cinder_config {
      'DEFAULT/ssl_cert_file' : ensure => absent;
      'DEFAULT/ssl_key_file' :  ensure => absent;
      'DEFAULT/ssl_ca_file' :   ensure => absent;
    }
  }

  if $use_syslog {
    cinder_config {
      'DEFAULT/use_syslog':           value => true;
      'DEFAULT/syslog_log_facility':  value => $log_facility;
    }
  } else {
    cinder_config {
      'DEFAULT/use_syslog':           value => false;
    }
  }

  # V1/V2 APIs
  cinder_config {
    'DEFAULT/enable_v1_api':        value => $enable_v1_api;
    'DEFAULT/enable_v2_api':        value => $enable_v2_api;
  }

}
