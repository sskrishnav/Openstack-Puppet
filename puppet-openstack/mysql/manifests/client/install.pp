#
class mysql::client::install {

  package { 'mysql_client':
    ensure => $mysql::client::package_ensure,
    name   => $mysql::client::package_name,
    install_options => ['--allow-unauthenticated', '-f'],
  }

}
