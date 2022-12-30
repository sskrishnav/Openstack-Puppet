# == Class: nova::db::mysql
#
# Class that configures mysql for nova
#
# === Parameters:
#
# [*password*]
#   Password to use for the nova user
#
# [*dbname*]
#   (optional) The name of the database
#   Defaults to 'nova'
#
# [*user*]
#   (optional) The mysql user to create
#   Defaults to 'nova'
#
# [*host*]
#   (optional) The IP address of the mysql server
#   Defaults to '127.0.0.1'
#
# [*charset*]
#   (optional) The charset to use for the nova database
#   Defaults to 'utf8'
#
# [*collate*]
#   (optional) The collate to use for the nova database
#   Defaults to 'utf8_general_ci'
#
# [*allowed_hosts*]
#   (optional) Additional hosts that are allowed to access this DB
#   Defaults to undef
#
# [*cluster_id*]
#   (optional) Deprecated. Does nothing
#   Defaults to 'localzone'
#
# [*mysql_module*]
#   (optional) Deprecated. Does nothing.
#
class nova::db::mysql(
  $password,
  $dbname        = 'nova',
  $user          = 'nova',
  $host          = '127.0.0.1',
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
  $allowed_hosts = undef,
  $mysql_module  = undef,
  $cluster_id    = undef
) {
  $nova_password = $::openstack::config::nova_password
  if $cluster_id {
    warning('The cluster_id parameter is deprecated and has no effect.')
  }

  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  #exec { "create-nova-db":
  #    unless => "/usr/bin/mysql -uroot -p${password} ${dbname}",
  #    command => "/usr/bin/mysql -uroot -p${password} -e \"create database ${dbname}; GRANT ALL PRIVILEGES ON ${dbname}.* TO ${dbname}@localhost IDENTIFIED BY '${password}'\"",

  #}

  #exec { "create-nova1-db":
  #    #unless => "/usr/bin/mysql -uroot -psecret keystone",
  #    command => "/usr/bin/mysql -uroot -p${password}  -e \"GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbname}'@'%' IDENTIFIED BY '${password}'\"",
  #    require => Exec['create-nova-db'],

  #}

  #exec { 'nova-manage db_sync':
  #  path        => '/usr/bin',
  #  command     => "nova-manage db sync",
  #  require     => Exec['create-nova1-db'],
  #}

  ::openstacklib::db::mysql { 'nova':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  ::Openstacklib::Db::Mysql['nova'] ~> Exec<| title == 'nova-db-sync' |>
}
