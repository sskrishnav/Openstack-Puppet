class openstack::role::compute inherits ::openstack::role {
    include ::openstack::profile::firewall
    include ::openstack::profile::neutron::agent
    include ::openstack::profile::nova::compute
    #include ::openstack::profile::ceilometer::agent
}
