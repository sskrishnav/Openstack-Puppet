# The profile to install the Glance API and Registry services
# Note that for this configuration API controls the storage,
# so it is on the storage node instead of the control node
class openstack::profile::glance::api {

   include openstack::common::glance

   if $::openstack::config::high_availability == "true" {
     if $::osfamily == 'Debian' {
       Haproxy::Balancermember<||> -> Package['glance']
       Service['haproxy'] -> Package['glance']
       Haproxy::Balancermember<||> -> Package['glance-api']
       Service['haproxy'] -> Package['glance-api']
       Haproxy::Balancermember<||> -> Package['glance-registry']
       Service['haproxy'] -> Package['glance-registry']
       Haproxy::Balancermember<||> -> Exec<| title == 'glance-manage db_sync' |>
       Service['haproxy'] -> Exec<| title == 'glance-manage db_sync' |>
     }
     elsif $::osfamily == 'Redhat'{
       Haproxy::Balancermember<||> -> Package['openstack-glance']
       Service['haproxy'] -> Package['openstack-glance']
       Haproxy::Balancermember<||> -> Exec<| title == 'glance-manage db_sync' |>
       Service['haproxy'] -> Exec<| title == 'glance-manage db_sync' |>  
     }
  }
} 
