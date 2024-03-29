# == Class: nova
#
# This class is used to specify configuration parameters that are common
# across all nova services.
#
# === Parameters:
#
# [*ensure_package*]
#   (optional) The state of nova packages
#   Defaults to 'present'
#
# [*nova_cluster_id*]
#   (optional) Deprecated. This parameter does nothing and will be removed.
#   Defaults to 'localcluster'
#
# [*sql_connection*]
#   (optional) Deprecated. Use database_connection instead.
#   Defaults to false
#
# [*sql_idle_timeout*]
#   (optional) Deprecated. Use database_idle_timeout instead
#   Defaults to false
#
# [*database_connection*]
#   (optional) Connection url to connect to nova database.
#   Defaults to false
#
# [*slave_connection*]
#   (optional) Connection url to connect to nova slave database (read-only).
#   Defaults to false
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle db connections are reaped.
#   Defaults to 3600
#
# [*rpc_backend*]
#   (optional) The rpc backend implementation to use, can be:
#     rabbit (for rabbitmq)
#     qpid (for qpid)
#     zmq (for zeromq)
#   Defaults to 'rabbit'
#
# [*image_service*]
#   (optional) Service used to search for and retrieve images.
#   Defaults to 'nova.image.local.LocalImageService'
#
# [*glance_api_servers*]
#   (optional) List of addresses for api servers.
#   Defaults to 'localhost:9292'
#
# [*memcached_servers*]
#   (optional) Use memcached instead of in-process cache. Supply a list of memcached server IP's:Memcached Port.
#   Defaults to false
#
# [*rabbit_host*]
#   (optional) Location of rabbitmq installation.
#   Defaults to 'localhost'
#
# [*rabbit_hosts*]
#   (optional) List of clustered rabbit servers.
#   Defaults to false
#
# [*rabbit_port*]
#   (optional) Port for rabbitmq instance.
#   Defaults to '5672'
#
# [*rabbit_password*]
#   (optional) Password used to connect to rabbitmq.
#   Defaults to 'guest'
#
# [*rabbit_userid*]
#   (optional) User used to connect to rabbitmq.
#   Defaults to 'guest'
#
# [*rabbit_virtual_host*]
#   (optional) The RabbitMQ virtual host.
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
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to false
#
# [*qpid_hostname*]
#   (optional) Location of qpid server
#   Defaults to 'localhost'
#
# [*qpid_port*]
#   (optional) Port for qpid server
#   Defaults to '5672'
#
# [*qpid_username*]
#   (optional) Username to use when connecting to qpid
#   Defaults to 'guest'
#
# [*qpid_password*]
#   (optional) Password to use when connecting to qpid
#   Defaults to 'guest'
#
# [*qpid_heartbeat*]
#   (optional) Seconds between connection keepalive heartbeats
#   Defaults to 60
#
# [*qpid_protocol*]
#   (optional) Transport to use, either 'tcp' or 'ssl''
#   Defaults to 'tcp'
#
# [*qpid_sasl_mechanisms*]
#   (optional) Enable one or more SASL mechanisms
#   Defaults to false
#
# [*qpid_tcp_nodelay*]
#   (optional) Disable Nagle algorithm
#   Defaults to true
#
# [*service_down_time*]
#   (optional) Maximum time since last check-in for up service.
#   Defaults to 60
#
# [*logdir*]
#   (optional) Deprecated. Use log_dir instead.
#   Defaults to false
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/nova'
#
# [*state_path*]
#   (optional) Directory for storing state.
#   Defaults to '/var/lib/nova'
#
# [*lock_path*]
#   (optional) Directory for lock files.
#   On RHEL will be '/var/lib/nova/tmp' and on Debian '/var/lock/nova'
#   Defaults to $::nova::params::lock_path
#
# [*verbose*]
#   (optional) Set log output to verbose output.
#   Defaults to false
#
# [*periodic_interval*]
#   (optional) Seconds between running periodic tasks.
#   Defaults to '60'
#
# [*report_interval*]
#   (optional) Interval at which nodes report to data store.
#    Defaults to '10'
#
# [*monitoring_notifications*]
#   (optional) Whether or not to send system usage data notifications out on the message queue. Only valid for stable/essex.
#   Defaults to false
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to false
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'
#
# [*use_ssl*]
#   (optional) Enable SSL on the API server
#   Defaults to false, not set
#
# [*enabled_ssl_apis*]
#   (optional) List of APIs to SSL enable
#   Defaults to []
#   Possible values : 'ec2', 'osapi_compute', 'metadata'
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
# [*nova_user_id*]
#   (optional) Create the nova user with the specified gid.
#   Changing to a new uid after specifying a different uid previously,
#   or using this option after the nova account already exists will break
#   the ownership of all files/dirs owned by nova. It is strongly encouraged
#   not to use this option and instead create user before nova class or
#   for network shares create netgroup into which you'll put nova on all the
#   nodes. If undef no user will be created and user creation will standardly
#   happen in nova-common package.
#   Defaults to undef.
#
# [*nova_group_id*]
#   (optional) Create the nova user with the specified gid.
#   Changing to a new uid after specifying a different uid previously,
#   or using this option after the nova account already exists will break
#   the ownership of all files/dirs owned by nova. It is strongly encouraged
#   not to use this option and instead create group before nova class or for
#   network shares create netgroup into which you'll put nova on all the
#   nodes. If undef no user or group will be created and creation will
#   happen in nova-common package.
#   Defaults to undef.
#
# [*nova_public_key*]
#   (optional) Install public key in .ssh/authorized_keys for the 'nova' user.
#   Expects a hash of the form { type => 'key-type', key => 'key-data' } where
#   'key-type' is one of (ssh-rsa, ssh-dsa, ssh-ecdsa) and 'key-data' is the
#   actual key data (e.g, 'AAAA...').
#
# [*nova_private_key*]
#   (optional) Install private key into .ssh/id_rsa (or appropriate equivalent
#   for key type).  Expects a hash of the form { type => 'key-type', key =>
#   'key-data' }, where 'key-type' is one of (ssh-rsa, ssh-dsa, ssh-ecdsa) and
#   'key-data' is the contents of the private key file.
#
# [*nova_shell*]
#   (optional) Set shell for 'nova' user to the specified value.
#   Defaults to '/bin/false'.
#
# [*mysql_module*]
#   (optional) Deprecated. Does nothing.
#
# [*notification_driver*]
#   (optional) Driver or drivers to handle sending notifications.
#   Value can be a string or a list.
#   Defaults to []
#
# [*notification_topics*]
#   (optional) AMQP topic used for OpenStack notifications
#   Defaults to 'notifications'
#
# [*notify_api_faults*]
#   (optional) If set, send api.fault notifications on caught
#   exceptions in the API service
#   Defaults to false
#
# [*notify_on_state_change*]
#   (optional) If set, send compute.instance.update notifications
#   on instance state changes. Valid values are None for no notifications,
#   "vm_state" for notifications on VM state changes, or "vm_and_task_state"
#   for notifications on VM and task state changes.
#   Defaults to undef
#
# [*os_region_name*]
#   (optional) Sets the os_region_name flag. For environments with
#   more than one endpoint per service, this is required to make
#   things such as cinder volume attach work. If you don't set this
#   and you have multiple endpoints, you will get AmbiguousEndpoint
#   exceptions in the nova API service.
#   Defaults to undef
class nova(
  $ensure_package           = 'present',
  $database_connection      = true,
  $slave_connection         = false,
  $database_idle_timeout    = 3600,
  $rpc_backend              = 'rabbit',
  $image_service            = 'nova.image.glance.GlanceImageService',
  # these glance params should be optional
  # this should probably just be configured as a glance client
  #$vip_ip                   = undef,
  $glance_api_servers       = 'localhost:9292',
  $memcached_servers        = false,
  $rabbit_host              = 'localhost',
  $rabbit_hosts             = false,
  $rabbit_password          = 'guest',
  $rabbit_port              = '5672',
  $rabbit_userid            = 'guest',
  $rabbit_virtual_host      = '/',
  $rabbit_use_ssl           = false,
  $rabbit_ha_queues         = undef,
  $kombu_ssl_ca_certs       = undef,
  $kombu_ssl_certfile       = undef,
  $kombu_ssl_keyfile        = undef,
  $kombu_ssl_version        = 'TLSv1',
  $amqp_durable_queues      = false,
  $qpid_hostname            = 'localhost',
  $qpid_port                = '5672',
  $qpid_username            = 'guest',
  $qpid_password            = 'guest',
  $qpid_sasl_mechanisms     = false,
  $qpid_heartbeat           = 60,
  $qpid_protocol            = 'tcp',
  $qpid_tcp_nodelay         = true,
  #$auth_strategy            = 'keystone',
  $service_down_time        = 60,
  $log_dir                  = '/var/log/nova',
  $state_path               = '/var/lib/nova',
  $lock_path                = $::nova::params::lock_path,
  $verbose                  = true,
  $debug                    = true,
  $periodic_interval        = '60',
  $report_interval          = '10',
  $rootwrap_config          = '/etc/nova/rootwrap.conf',
  $use_ssl                  = false,
  $enabled_ssl_apis         = ['ec2', 'metadata', 'osapi_compute'],
  $ca_file                  = false,
  $cert_file                = false,
  $key_file                 = false,
  $nova_user_id             = undef,
  $nova_group_id            = undef,
  $nova_public_key          = undef,
  $nova_private_key         = undef,
  $nova_shell               = '/bin/false',
  # deprecated in folsom
  #$root_helper = $::nova::params::root_helper,
  $monitoring_notifications = false,
  $use_syslog               = false,
  $use_stderr               = true,
  $log_facility             = 'LOG_USER',
  $install_utilities        = true,
  $notification_driver      = [],
  $notification_topics      = 'notifications',
  $notify_api_faults        = false,
  $notify_on_state_change   = undef,
  # DEPRECATED PARAMETERS
  $mysql_module             = undef,
  # this is how to query all resources from our clutser
  $nova_cluster_id          = undef,
  $sql_connection           = false,
  $sql_idle_timeout         = false,
  $logdir                   = false,
  $os_region_name           = 'openstack',
) inherits nova::params {

  # maintain backward compatibility
  #include nova::db
  package { "$::nova::params::common_package_name":
    ensure  => $ensure_package,
    name    => $::nova::params::common_package_name,
    require => [Package['python-nova']],
    tag     => ['openstack', 'nova'],
  }

  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  if $nova_cluster_id {
    warning('The nova_cluster_id parameter is deprecated and has no effect.')
  }

  validate_array($enabled_ssl_apis)
  if empty($enabled_ssl_apis) and $use_ssl {
      warning('enabled_ssl_apis is empty but use_ssl is set to true')
  }

  if $use_ssl {
    if !$cert_file {
      fail('The cert_file parameter is required when use_ssl is set to true')
    }
    if !$key_file {
      fail('The key_file parameter is required when use_ssl is set to true')
    }
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

  if $nova_group_id {
    warning('The nova_group_id will be deprecated, please create group manually')
    group { 'nova':
      ensure  => present,
      system  => true,
      gid     => $nova_group_id,
      before  => Package["$::nova::params::common_package_name"],
    }
  }
  if $nova_user_id {
    warning('The nova_user_id will be deprecated, please create user manually')
    user { 'nova':
      ensure     => present,
      system     => true,
      groups     => 'nova',
      home       => '/var/lib/nova',
      managehome => false,
      shell      => $nova_shell,
      uid        => $nova_user_id,
      gid        => $nova_group_id,
      before     => Package["$::nova::params::common_package_name"],
      require    => Group['nova'],
    }
  }

  if $nova_public_key or $nova_private_key {
    file { '/var/lib/nova/.ssh':
      ensure  => directory,
      mode    => '0700',
      owner   => 'nova',
      group   => 'nova',
      require => Package["$::nova::params::common_package_name"],
    }

    if $nova_public_key {
      if ! $nova_public_key[key] or ! $nova_public_key['type'] {
        fail('You must provide both a key type and key data.')
      }

      ssh_authorized_key { 'nova-migration-public-key':
        ensure  => present,
        key     => $nova_public_key[key],
        type    => $nova_public_key['type'],
        user    => 'nova',
        require => File['/var/lib/nova/.ssh'],
      }
    }

    if $nova_private_key {
      if ! $nova_private_key[key] or ! $nova_private_key['type'] {
        fail('You must provide both a key type and key data.')
      }

      $nova_private_key_file = $nova_private_key['type'] ? {
        'ssh-rsa'   => '/var/lib/nova/.ssh/id_rsa',
        'ssh-dsa'   => '/var/lib/nova/.ssh/id_dsa',
        'ssh-ecdsa' => '/var/lib/nova/.ssh/id_ecdsa',
        default     => undef
      }

      if ! $nova_private_key_file {
        fail("Unable to determine name of private key file.  Type specified was '${nova_private_key['type']}' but should be one of: ssh-rsa, ssh-dsa, ssh-ecdsa.")
      }

      file { $nova_private_key_file:
        content => $nova_private_key[key],
        mode    => '0600',
        owner   => 'nova',
        group   => 'nova',
        require => [ File['/var/lib/nova/.ssh'], Package["$::nova::params::common_package_name"] ],
      }
    }
  }


  # all nova_config resources should be applied
  # after the nova common package
  # before the file resource for nova.conf is managed
  # and before the post config resource
  Package["$::nova::params::common_package_name"] -> Nova_config<| |> -> File['/etc/nova/nova.conf']
  #Nova_config<| |> ~> Exec['post-nova_config']

  # TODO - see if these packages can be removed
  # they should be handled as package deps by the OS
  package { 'python':
    ensure => present,
  }
  package { 'python-greenlet':
    ensure  => present,
    require => Package['python'],
  }

  if $install_utilities {
    class { 'nova::utilities': }
  }

  # this anchor is used to simplify the graph between nova components by
  # allowing a resource to serve as a point where the configuration of nova begins
  anchor { 'nova-start': }

  package { 'python-nova':
    ensure  => $ensure_package,
    require => Package['python-greenlet'],
    tag     => ['openstack', 'nova'],
  }


  file { '/etc/nova/nova.conf':
    mode    => '0640',
    owner   => 'nova',
    group   => 'nova',
    require => Package["$::nova::params::common_package_name"],
  }

  # used by debian/ubuntu in nova::network_bridge to refresh
  # interfaces based on /etc/network/interfaces
  exec { 'networking-refresh':
    command     => '/sbin/ifdown -a ; /sbin/ifup -a',
    refreshonly => true,
  }

  nova_config { 'DEFAULT/image_service': value => $image_service }
  $vip_ip = $::openstack::config::haproxy_listen_ip
  if $image_service == 'nova.image.glance.GlanceImageService' {
    if $glance_api_servers {
      nova_config { 
         #'glance/api_servers': ensure => absent; 
         'glance/host': value => $vip_ip;
         'database/connection':           value  => $database_connection; 
       }
      }
    }
  


  if $memcached_servers {
    nova_config { 'DEFAULT/memcached_servers': value  => join($memcached_servers, ',') }
  } else {
    nova_config { 'DEFAULT/memcached_servers': ensure => absent }
  }

  # we keep "nova.openstack.common.rpc.impl_kombu" for backward compatibility
  # but since Icehouse, "rabbit" is enough.
  if $rpc_backend == 'nova.openstack.common.rpc.impl_kombu' or $rpc_backend == 'rabbit' {
    # I may want to support exporting and collecting these
    nova_config {
      'DEFAULT/rabbit_password':     value => $rabbit_password, secret => true;
      'DEFAULT/rabbit_userid':       value => $rabbit_userid;
      'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
      'DEFAULT/rabbit_use_ssl':      value => $rabbit_use_ssl;
      'DEFAULT/amqp_durable_queues': value => $amqp_durable_queues;
    }

    if $rabbit_use_ssl {

      if $kombu_ssl_ca_certs {
        nova_config { 'DEFAULT/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs; }
      } else {
        nova_config { 'DEFAULT/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $kombu_ssl_certfile or $kombu_ssl_keyfile {
        nova_config {
          'DEFAULT/kombu_ssl_certfile': value => $kombu_ssl_certfile;
          'DEFAULT/kombu_ssl_keyfile':  value => $kombu_ssl_keyfile;
        }
      } else {
        nova_config {
          'DEFAULT/kombu_ssl_certfile': ensure => absent;
          'DEFAULT/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $kombu_ssl_version {
        nova_config { 'DEFAULT/kombu_ssl_version':  value => $kombu_ssl_version; }
      } else {
        nova_config { 'DEFAULT/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      nova_config {
        'DEFAULT/kombu_ssl_ca_certs': ensure => absent;
        'DEFAULT/kombu_ssl_certfile': ensure => absent;
        'DEFAULT/kombu_ssl_keyfile':  ensure => absent;
        'DEFAULT/kombu_ssl_version':  ensure => absent;
      }
    }

    if $rabbit_hosts {
      nova_config { 'DEFAULT/rabbit_hosts':     value => join($rabbit_hosts, ',') }
    } 
    else {
      nova_config { 'DEFAULT/rabbit_host':      value => $rabbit_host }
      nova_config { 'DEFAULT/rabbit_port':      value => $rabbit_port }
      nova_config { 'DEFAULT/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
    }
    #if $rabbit_ha_queues == undef {
    #  if $rabbit_hosts {
        #nova_config { 'DEFAULT/rabbit_ha_queues': value => true }
    #  } else {
        #nova_config { 'DEFAULT/rabbit_ha_queues': value => false }
    #  }
    #} else {
      #nova_config { 'DEFAULT/rabbit_ha_queues': value => $rabbit_ha_queues }
    #}
  
  }
  # we keep "nova.openstack.common.rpc.impl_qpid" for backward compatibility
  # but since Icehouse, "qpid" is enough.
  if $rpc_backend == 'nova.openstack.common.rpc.impl_qpid' or $rpc_backend == 'qpid' {
    nova_config {
      'DEFAULT/qpid_hostname':               value => $qpid_hostname;
      'DEFAULT/qpid_port':                   value => $qpid_port;
      'DEFAULT/qpid_username':               value => $qpid_username;
      'DEFAULT/qpid_password':               value => $qpid_password, secret => true;
      'DEFAULT/qpid_heartbeat':              value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol':               value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay':            value => $qpid_tcp_nodelay;
    }
    if is_array($qpid_sasl_mechanisms) {
      nova_config {
        'DEFAULT/qpid_sasl_mechanisms': value => join($qpid_sasl_mechanisms, ' ');
      }
    }
    elsif $qpid_sasl_mechanisms {
      nova_config {
        'DEFAULT/qpid_sasl_mechanisms': value => $qpid_sasl_mechanisms;
      }
    }
    else {
      nova_config {
        'DEFAULT/qpid_sasl_mechanisms': ensure => absent;
      }
    }
  }

  # SSL Options
  if $use_ssl {
    nova_config {
      'DEFAULT/enabled_ssl_apis' : value => join($enabled_ssl_apis, ',');
      'DEFAULT/ssl_cert_file' :    value => $cert_file;
      'DEFAULT/ssl_key_file' :     value => $key_file;
    }
    if $ca_file {
      nova_config { 'DEFAULT/ssl_ca_file' :
        value => $ca_file,
      }
    } else {
      nova_config { 'DEFAULT/ssl_ca_file' :
        ensure => absent,
      }
    }
  } else {
    nova_config {
      'DEFAULT/enabled_ssl_apis' : ensure => absent;
      'DEFAULT/ssl_cert_file' :    ensure => absent;
      'DEFAULT/ssl_key_file' :     ensure => absent;
      'DEFAULT/ssl_ca_file' :      ensure => absent;
    }
  }

  if $logdir {
    warning('The logdir parameter is deprecated, use log_dir instead.')
    $log_dir_real = $logdir
  } else {
    $log_dir_real = $log_dir
  }

  if $log_dir_real {
    file { $log_dir_real:
      ensure  => directory,
      mode    => '0750',
      owner   => 'nova',
      group   => $::nova::params::nova_log_group,
      require => Package["$::nova::params::common_package_name"],
    }
    nova_config { 'DEFAULT/log_dir': value => $log_dir_real;}
  } else {
    nova_config { 'DEFAULT/log_dir': ensure => absent;}
  }

  if $monitoring_notifications {
    warning('The monitoring_notifications parameter is deprecated, use notification_driver instead.')
    $notification_driver_real = 'nova.openstack.common.notifier.rpc_notifier'
  } else {
    $notification_driver_real = is_string($notification_driver) ? {
      true    => $notification_driver,
      default => join($notification_driver, ',')
    }
  }

  nova_config {
    'DEFAULT/verbose':             value => $verbose;
    'DEFAULT/debug':               value => $debug;
    'DEFAULT/use_stderr':          value => $use_stderr;
    'DEFAULT/notification_driver': value => $notification_driver_real;
    'DEFAULT/notification_topics': value => $notification_topics;
    'DEFAULT/notify_api_faults':   value => $notify_api_faults;
    #'DEFAULT/logdir': ensure => absent;
    # Following may need to be broken out to different nova services
    'DEFAULT/state_path':          value => $state_path;
    'DEFAULT/lock_path':           value => $lock_path;
    'DEFAULT/service_down_time':   value => $service_down_time;
    'DEFAULT/rootwrap_config':     value => $rootwrap_config;
    'DEFAULT/report_interval':     value => $report_interval; 
    #require                              => Package["$::nova::params::common_package_name"],
  }

}
