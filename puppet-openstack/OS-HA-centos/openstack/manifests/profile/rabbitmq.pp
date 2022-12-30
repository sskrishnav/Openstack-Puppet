# The profile to install rabbitmq and set the firewall
class openstack::profile::rabbitmq {
  $management_address = $::openstack::config::controller_address_management

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "usr/local/bin/" ] }

  #if $::osfamily == 'RedHat' {
  #  package { 'erlang':
  #    ensure  => installed,
  #    before  => Package['rabbitmq-server'],
  #    require => Yumrepo['erlang-solutions'],
  #  }
  #}

  rabbitmq_user { $::openstack::config::rabbitmq_user:
    ensure   => present,
    admin    => true,
    password => $::openstack::config::rabbitmq_password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { "${openstack::config::rabbitmq_user}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }
  #->Anchor<| title == 'nova-start' |>

  if $::openstack::config::high_availability == "true" { 
    $config_cluster = true
    $cluster_nodes = $::openstack::config::rabbitmq_cluster_nodes
    $wipe_db_on_cookie_change = true
  }
  else {
    $config_cluster = false
    $cluster_nodes = []
    $wipe_db_on_cookie_change = false
  }

  package {"curl":
    ensure => present,
  }

  class { '::rabbitmq':
    service_ensure    => 'running',
    port              => 5672,
    delete_guest_user => true,
    config_cluster    => $config_cluster,
    cluster_nodes     => $cluster_nodes,
    wipe_db_on_cookie_change => $wipe_db_on_cookie_change,
    require => Package['curl']
  }

  #To miirro the rabbitmq ports
  #rabbitmqctl set_policy ha-all '^(?!amq\.).*' '{"ha-mode": "all"}'
  exec {"rabbitmq_mirror":
    command => "rabbitmqctl set_policy ha-all '^(?!amq\.).*' '{\"ha-mode\": \"all\"}'",
    require => Class["::rabbitmq"]
  }

}
