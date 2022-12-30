# keystone common class
class openstack::common::keystone {
  if $::openstack::profile::base::is_controller {
    if $::openstack::config::high_availability == "true" {
      $admin_bind_host = $::openstack::config::controller_address_management
      $public_bind_host = $::openstack::config::controller_address_management
    }
    else {
      $public_bind_host = "0.0.0.0"
      $admin_bind_host = "0.0.0.0"
    }
  }
  else {
    $public_bind_host = "0.0.0.0"
    $admin_bind_host = "0.0.0.0"
  }

   #admin_token       =>  $::openstack::config::keystone_admin_token,
   #public_bind_host  =>  $::openstack::config::controller_address_management,
   #admin_bind_host   =>  $::openstack::config::controller_address_management,
   #rabbit_hosts      =>  $::openstack::config::rabbitmq_hosts,
   #rabbit_password   =>  $::openstack::config::rabbitmq_password,
   #rabbit_userid     =>  $::openstack::config::rabbitmq_user,
   #keystone_password =>  $::openstack::config::mysql_pass_keystone,
   #keystone_username =>  $::openstack::config::mysql_user_keystone,
   #host              =>  $::openstack::config::haproxy_listen_ip,
   #debug             =>  True

  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $::openstack::resources::connectors::keystone,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_controller,
    #admin_bind_host    => $admin_bind_host,
    public_bind_host    => $public_bind_host,
    admin_bind_host     => $admin_bind_host,
    rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    keystone_password   => $::openstack::config::mysql_pass_keystone,
    keystone_username   => $::openstack::config::mysql_user_keystone,
    host                => $::openstack::config::haproxy_listen_ip,
    mysql_module        => '2.2',
  }

  class { '::keystone::roles::admin':
    email        => $::openstack::config::keystone_admin_email,
    password     => $::openstack::config::keystone_admin_password,
    admin_tenant => 'admin',
  }
}
