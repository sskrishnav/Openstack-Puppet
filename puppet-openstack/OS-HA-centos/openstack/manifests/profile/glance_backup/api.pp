# The profile to install the Glance API and Registry services
# Note that for this configuration API controls the storage,
# so it is on the storage node instead of the control node
class openstack::profile::glance::api {

    #class { '::glance::api':
    #  keystone_password    => $::openstack::config::glance_password,
    #  glance_username      => $::openstack::config::mysql_user_glance,
    #  bind_host            => $::openstack::config::controller_address_management,
    #  registry_host        => $::openstack::config::controller_address_management,
    #  host                 => $::openstack::config::haproxy_listen_ip,
   #}
   include openstack::common::glance

   if $::openstack::config::high_availability == "true" {
     Haproxy::Balancermember<||> -> Package['glance']
     Service['haproxy'] -> Package['glance']
     Haproxy::Balancermember<||> -> Package['glance-api']
     Service['haproxy'] -> Package['glance-api']
     Haproxy::Balancermember<||> -> Package['glance-registry']
     Service['haproxy'] -> Package['glance-registry']
     Haproxy::Balancermember<||> -> Exec<| title == 'glance-manage db_sync' |>
     Service['haproxy'] -> Exec<| title == 'glance-manage db_sync' |>
   }

}
