# The profile to set up the neutron server
class openstack::profile::neutron::server {
  openstack::resources::controller { 'neutron': }
  openstack::resources::database { 'neutron': }
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  include ::openstack::common::neutron
  include ::openstack::common::ovs

  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']

  if $::openstack::config::high_availability == "true" {
    if $::osfamily == 'Debian' {
      Haproxy::Balancermember<||> -> Package['neutron']
      Service['haproxy'] -> Package['neutron']
      Haproxy::Balancermember<||> -> Package['neutron-server']
      Service['haproxy'] -> Package['neutron-server']
      Haproxy::Balancermember<||> -> Exec['neutron-db-sync']
      Service['haproxy'] -> Exec['neutron-db-sync']
    }
    if $::osfamily == 'RedHat' {
      Haproxy::Balancermember<||> -> Package['openstack-neutron']
      Service['haproxy'] -> Package['openstack-neutron']
      #Haproxy::Balancermember<||> -> Package['neutron-server']
      #Service['haproxy'] -> Package['neutron-server']
      Haproxy::Balancermember<||> -> Exec['neutron-db-sync']
      Service['haproxy'] -> Exec['neutron-db-sync']
    }
  }
  
}
