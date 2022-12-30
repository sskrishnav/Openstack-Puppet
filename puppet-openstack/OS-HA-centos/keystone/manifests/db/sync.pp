#
# Class to execute "keystone-manage db_sync
#
class keystone::db::sync {
  exec { 'keystone-manage db_sync':
    path        => '/usr/bin',
    user        => 'keystone',
    refreshonly => true,
    subscribe   => [Package['keystone'], Keystone_config['database/connection']],
    require     => User['keystone'],
  }

  #exec { "wait_for_some_time_after_sync" :
  #  command     => "sleep 60",
  #  path        => "/usr/bin:/bin:/usr/local/bin",
  #  require     => [ Exec["keystone-manage db_sync"] ]
  #}

  Exec['keystone-manage db_sync'] ~> Service<| title == 'keystone' |>
}
