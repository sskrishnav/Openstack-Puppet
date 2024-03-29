# == Class: glance::registry
#
# Installs and configures glance-registry
#
# === Parameters
#
#  [*keystone_password*]
#    (required) The keystone password for administrative user
#
#  [*package_ensure*]
#    (optional) Ensure state for package. Defaults to 'present'.  On RedHat
#    platforms this setting is ignored and the setting from the glance class is
#    used because there is only one glance package.
#
#  [*verbose*]
#    (optional) Enable verbose logs (true|false). Defaults to false.
#
#  [*debug*]
#    (optional) Enable debug logs (true|false). Defaults to false.
#
#  [*bind_host*]
#    (optional) The address of the host to bind to. Defaults to '0.0.0.0'.
#
#  [*bind_port*]
#    (optional) The port the server should bind to. Defaults to '9191'.
#
#  [*log_file*]
#    (optional) Log file for glance-registry.
#    If set to boolean false, it will not log to any file.
#    Defaults to '/var/log/glance/registry.log'.
#
#  [*log_dir*]
#    (optional) directory to which glance logs are sent.
#    If set to boolean false, it will not log to any directory.
#    Defaults to '/var/log/glance'
#
# [*sql_idle_timeout*]
#   (optional) Deprecated. Use database_idle_timeout instead
#   Defaults to false
#
# [*sql_connection*]
#   (optional) Deprecated. Use database_connection instead.
#   Defaults to false
#
# [*database_connection*]
#   (optional) Connection url to connect to nova database.
#   Defaults to 'sqlite:///var/lib/glance/glance.sqlite'
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Defaults to 3600
#
#  [*auth_type*]
#    (optional) Authentication type. Defaults to 'keystone'.
#
#  [*auth_host*]
#    (optional) Address of the admin authentication endpoint.
#    Defaults to '127.0.0.1'.
#
#  [*auth_port*]
#    (optional) Port of the admin authentication endpoint. Defaults to '35357'.
#
#  [*auth_admin_prefix*]
#    (optional) path part of the auth url.
#    This allow admin auth URIs like http://auth_host:35357/keystone/admin.
#    (where '/keystone/admin' is auth_admin_prefix)
#    Defaults to false for empty. If defined, should be a string with a leading '/' and no trailing '/'.
#
#  [*auth_protocol*]
#    (optional) Protocol to communicate with the admin authentication endpoint.
#    Defaults to 'http'. Should be 'http' or 'https'.
#
#  [*auth_uri*]
#    (optional) Complete public Identity API endpoint.
#
#  [*keystone_tenant*]
#    (optional) administrative tenant name to connect to keystone.
#    Defaults to 'services'.
#
#  [*keystone_user*]
#    (optional) administrative user name to connect to keystone.
#    Defaults to 'glance'.
#
#  [*use_syslog*]
#    (optional) Use syslog for logging.
#    Defaults to false.
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to true
#
#  [*log_facility*]
#    (optional) Syslog facility to receive log lines.
#    Defaults to LOG_USER.
#
#  [*manage_service*]
#    (optional) If Puppet should manage service startup / shutdown.
#    Defaults to true.
#
#  [*enabled*]
#    (optional) Should the service be enabled.
#    Defaults to true.
#
#  [*purge_config*]
#    (optional) Whether to create only the specified config values in
#    the glance registry config file.
#    Defaults to false.
#
# [*cert_file*]
#   (optinal) Certificate file to use when starting registry server securely
#   Defaults to false, not set
#
# [*key_file*]
#   (optional) Private key file to use when starting registry server securely
#   Defaults to false, not set
#
# [*ca_file*]
#   (optional) CA certificate file to use to verify connecting clients
#   Defaults to false, not set
#
# [*sync_db*]
#   (Optional) Run db sync on the node.
#   Defaults to true
#
#  [*mysql_module*]
#  (optional) Deprecated. Does nothing.
#
class glance::registry(
  $keystone_password,
  $package_ensure        = 'present',
  $verbose               = false,
  $debug                 = false,
  $bind_host             = undef,
  $bind_port             = '9191',
  $log_file              = '/var/log/glance/registry.log',
  $log_dir               = '/var/log/glance',
  $database_connection   = 'mysql://',
  $database_idle_timeout = 3600,
  $auth_type             = 'keystone',
  $auth_host             = undef, 
  $auth_port             = '35357',
  $auth_admin_prefix     = false,
  $auth_uri              = false,
  $auth_protocol         = 'http',
  $keystone_tenant       = 'services',
  $keystone_user         = 'glance',
  $pipeline              = 'keystone',
  $use_syslog            = false,
  $use_stderr            = true,
  $auth_url              = undef,
  $log_facility          = 'LOG_USER',
  $manage_service        = true,
  $enabled               = true,
  $purge_config          = false,
  $cert_file             = false,
  $key_file              = false,
  $ca_file               = false,
  $sync_db               = false,
  $glance_username       = hiera(castlight::mysql::glance::user),
  #$host                  = hiera(castlight::controller::address::management),
  $host                     = $::openstack::config::haproxy_listen_ip,
  # DEPRECATED PARAMETERS
  $mysql_module          = undef,
  $sql_idle_timeout      = false,
  $sql_connection        = false,
) inherits glance {

  require keystone::python

  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  if ( $glance::params::api_package_name != $glance::params::registry_package_name ) {
    ensure_packages( [$glance::params::registry_package_name],
      {
        ensure => $package_ensure,
        tag    => ['openstack'],
      }
    )
  }

  Package[$glance::params::registry_package_name] -> File['/etc/glance/']
  Package[$glance::params::registry_package_name] -> Glance_registry_config<||>

  Glance_registry_config<||> ~> Exec<| title == 'glance-manage db_sync' |>
  Glance_registry_config<||> ~> Service['glance-registry']

  File {
    ensure  => present,
    owner   => 'glance',
    group   => 'glance',
    mode    => '0640',
    notify  => Service['glance-registry'],
    require => Class['glance']
  }

  if $sql_connection {
    warning('The sql_connection parameter is deprecated, use database_connection instead.')
    $database_connection_real = $sql_connection
  } else {
    $database_connection_real = $database_connection
  }

  if $sql_idle_timeout {
    warning('The sql_idle_timeout parameter is deprecated, use database_idle_timeout instead.')
    $database_idle_timeout_real = $sql_idle_timeout
  } else {
    $database_idle_timeout_real = $database_idle_timeout
  }

  if $database_connection_real {
    if($database_connection_real =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    } elsif($database_connection_real =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

    } elsif($database_connection_real =~ /sqlite:\/\//) {

    } else {
      fail("Invalid db connection ${database_connection_real}")
    }
    glance_registry_config {
      'database/connection':   value => $database_connection_real, secret => true;
      'database/idle_timeout': value => $database_idle_timeout_real;
      'database/sqlite_db'   : ensure => absent;
      'database/backend'     : ensure => absent;
    }
  }

  glance_registry_config {
    'DEFAULT/verbose':    value => $verbose;
    'DEFAULT/debug':      value => $debug;
    'DEFAULT/bind_host':  value => $bind_host;
    'DEFAULT/bind_port':  value => $bind_port;
    'DEFAULT/use_stderr': value => $use_stderr;
    'DEFAULT/notification_driver': value => 'noop';
  }

  if $auth_uri {
    glance_registry_config { 'keystone_authtoken/auth_uri': value => $auth_uri; }
  } else {
    glance_registry_config {  
        'keystone_authtoken/auth_uri': value => "${auth_protocol}://${host}:5000";
        'keystone_authtoken/auth_plugin': value => 'password';
        'keystone_authtoken/project_domain_id': value => 'default';
        'keystone_authtoken/user_domain_id': value => 'default';
        'keystone_authtoken/project_name': value => 'services';
        'keystone_authtoken/username': value => $glance_username;
        'keystone_authtoken/password': value => $keystone_password;
        'keystone_authtoken/revocation_cache_time': value => '10';
        'keystone_authtoken/auth_url'         : value => "${auth_protocol}://${host}:35357";
        'keystone_authtoken/identity_uri'     : ensure => absent;
        'DEFAULT/rabbit_host'                 : ensure => absent;
        'DEFAULT/rpc_backend'                 : value  => 'rabbit';
        'DEFAULT/rabbit_hosts':     value => join($::openstack::config::rabbitmq_hosts, ',');
        'DEFAULT/rabbit_userid'               : value => $::openstack::config::rabbitmq_user;
        'DEFAULT/rabbit_password'             : value => $::openstack::config::rabbitmq_password;
     }
  }
  # auth config
  #glance_registry_config {
  #  'keystone_authtoken/auth_host':     value => $auth_host;
  #  'keystone_authtoken/auth_port':     value => $auth_port;
  #  'keystone_authtoken/auth_protocol': value => $auth_protocol;
  #}

  if $auth_admin_prefix {
    validate_re($auth_admin_prefix, '^(/.+[^/])?$')
    glance_registry_config {
      'keystone_authtoken/auth_admin_prefix': value => $auth_admin_prefix;
    }
  } else {
    glance_registry_config {
      'keystone_authtoken/auth_admin_prefix': ensure => absent;
    }
  }

  # Set the pipeline, it is allowed to be blank
  if $pipeline != '' {
    validate_re($pipeline, '^(\w+([+]\w+)*)*$')
    glance_registry_config {
      'paste_deploy/flavor':
        ensure => present,
        value  => $pipeline,
    }
  } else {
    glance_registry_config { 'paste_deploy/flavor': ensure => absent }
  }

  # keystone config
  if $auth_type == 'keystone' {
    glance_registry_config {
      'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
      'keystone_authtoken/admin_user'       : value => $keystone_user;
      'keystone_authtoken/admin_password'   : value => $keystone_password, secret => true;
    }
  }

  # SSL Options
  if $cert_file {
    glance_registry_config {
      'DEFAULT/cert_file' : value => $cert_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/cert_file': ensure => absent;
    }
  }
  if $key_file {
    glance_registry_config {
      'DEFAULT/key_file'  : value => $key_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/key_file': ensure => absent;
    }
  }
  if $ca_file {
    glance_registry_config {
      'DEFAULT/ca_file'   : value => $ca_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/ca_file': ensure => absent;
    }
  }

  # Logging
  if $log_file {
    glance_registry_config {
      'DEFAULT/log_file': value  => $log_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $log_dir {
    glance_registry_config {
      'DEFAULT/log_dir': value  => $log_dir;
    }
  } else {
    glance_registry_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # Syslog
  if $use_syslog {
    glance_registry_config {
      'DEFAULT/use_syslog':           value => true;
      'DEFAULT/syslog_log_facility':  value => $log_facility;
    }
  } else {
    glance_registry_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  resources { 'glance_registry_config':
    purge => $purge_config
  }

  file { ['/etc/glance/glance-registry.conf',
          '/etc/glance/glance-registry-paste.ini']:
  }


  if $manage_service {
    if $enabled {
      if $sync_db {
        Exec['glance-manage db_sync'] ~> Service['glance-registry']

        exec { 'glance-manage db_sync':
          command     => $::glance::params::db_sync_command,
          path        => '/usr/bin',
          user        => 'glance',
          refreshonly => true,
          logoutput   => on_failure,
          subscribe   => [Package[$glance::params::registry_package_name], File['/etc/glance/glance-registry.conf']],
        }
      }
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'glance-registry':
    ensure     => $service_ensure,
    name       => $::glance::params::registry_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/glance/glance-registry.conf'],
    require    => Class['glance']
  }

}
