#keepalived installation 
class openstack::profile::keepalived ($priority) {
    include ::keepalived
    
    keepalived::vrrp::script { 'check_haproxy':
        script => '/usr/bin/killall -0 haproxy',
    }
    
    keepalived::vrrp::instance { 'VI_50':
        interface         => $::openstack::config::keepalived_interface,
        state             => 'MASTER',
        virtual_router_id => '50',
        priority          => "$priority",
        auth_type         => 'PASS',
        auth_pass         => $::openstack::config::keepalived_auth_pass,
        virtual_ipaddress => $::openstack::config::keepalived_virtual_ip,
        track_script      => 'check_haproxy',
    }

}
