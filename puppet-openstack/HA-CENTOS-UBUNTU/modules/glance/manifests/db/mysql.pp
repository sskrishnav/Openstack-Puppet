# The glance::db::mysql class creates a MySQL database for glance.
# It must be used on the MySQL server
#
# == Parameters
#
#  [*password*]
#    password to connect to the database. Mandatory.
#
#  [*dbname*]
#    name of the database. Optional. Defaults to glance.
#
#  [*user*]
#    user to connect to the database. Optional. Defaults to glance.
#
#  [*host*]
#    the default source host user is allowed to connect from.
#    Optional. Defaults to 'localhost'
#
#  [*allowed_hosts*]
#    other hosts the user is allowd to connect from.
#    Optional. Defaults to undef.
#
#  [*charset*]
#    the database charset. Optional. Defaults to 'utf8'
#
#  [*collate*]
#    the database collation. Optional. Defaults to 'utf8_general_ci'
#
#  [*mysql_module*]
#   (optional) Deprecated. Does nothing.
#
class glance::db::mysql(
  $password,
  $dbname        = undef,
  $user          = undef,
  $host          = undef,
  $allowed_hosts = undef,
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
  $cluster_id    = 'localzone',
  $mysql_module  = undef,
) {

  $glance_pass = $::openstack::config::glance_password
  $mysql_root_pass = $::openstack::config::mysql_root_password
  
  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  validate_string($password)

  #exec { "create-${dbname}-db":
  #    unless => "/usr/bin/mysql -uroot -p${password} $dbname",
  #    command => "/usr/bin/mysql -uroot -p${password} -e \"create database ${dbname}; GRANT ALL PRIVILEGES ON ${dbname}.* TO ${dbname}@localhost IDENTIFIED BY '${glance_pass}'\"",

  #}

  #exec { "grant-to-db-${dbname}":
  #    command => "/usr/bin/mysql -uroot -p${password} -e \"GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbname}'@'%' IDENTIFIED BY '${glance_pass}'\"",
  #    require => Exec["create-${dbname}-db"],

  #}
  #exec { "grant-to-db1-${dbname}":
  #    command => "/usr/bin/mysql -uroot -p${password} -e \"GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbname}'@'192.168.57.%' IDENTIFIED BY '${glance_pass}'\"",
  #    require => Exec["grant-to-db-${dbname}"],

  #}

  #exec { 'glance-manage db_sync':
  #  path        => '/usr/bin',
  #  command     => "glance-manage db_sync",
  #  require     => Exec["grant-to-db1-${dbname}"],
  #}

  ::openstacklib::db::mysql { 'glance':
      user => $user,
      password_hash => mysql_password($password),
      dbname => $dbname,
      host => $host,
      charset => $charset,
      collate => $collate,
      allowed_hosts => $allowed_hosts,
   }
   ::Openstacklib::Db::Mysql['glance'] ~> Exec<| title == 'glance-manage db_sync' |>
}

#}



