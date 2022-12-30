#Using HA Proxy.
class openstack::profile::haproxy {
    $vip_ip = $::openstack::config::haproxy_listen_ip
    $ports = $::openstack::config::haproxy_listen_ports
    $local_ip = $::openstack::config::haproxy_local_ip
    $members = $::openstack::config::haproxy_members

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "usr/local/bin/" ] }

    sysctl { 'net.ipv4.ip_nonlocal_bind': val => '1' }~>
    sysctl { 'net.ipv4.ip_forward': val => '1' }~>

    exec {'sysctl':
        command => "sysctl -p",
        logoutput => true,
    }

    class { '::haproxy':
        global_options   => {
            'log'     => "${local_ip} local0",
            'chroot'  => '/var/lib/haproxy',
            'pidfile' => '/var/run/haproxy.pid',
            'maxconn' => '4000',
            'user'    => 'haproxy',
            'group'   => 'haproxy',
            'daemon'  => '',
            'stats'   => 'socket /var/lib/haproxy/stats',
        },
    }
    $ports.each | $port | {
        if $port == "3306" {
            $mode = "tcp"
            $check = "mysql-check user haproxy"
        }
        elsif $port in ["8080", "8777"] {
            $mode = undef;
            $check = "tcpka tcplog"
        }
        else {
            $mode = undef;
            $check = "httpchk"
        }
        haproxy::listen { "haproxy_${port}":
            collect_exported => false,
            mode    => $mode,
            bind    => {
                "${vip_ip}:${port}" => [],
            },
            options => {
                'option'  => [
                "$check",
                ],
                'balance' => 'roundrobin',
            },
        }
        
        $members.each | $member | {
            if ($port in ["3306", "35357", "5000"]) and ($member['hostname'] !~ /^[\w-]+1$/) {
                $member_options = ['check', 'inter 2000', 'rise 2', 'fall 5', 'backup']
            }
            else {
                $member_options = ['check', 'inter 2000', 'rise 2', 'fall 5']
            }

            haproxy::balancermember { "haproxy_${member}_${port}":
                listening_service => "haproxy_${port}",
                ports             => "${port}",
                server_names      => $member['hostname'],
                ipaddresses       => $member['ipaddress'],
                options           => $member_options,
            }
        }
    }
    
#    anchor { 'haproxy2::start': }
#    anchor { 'haproxy2::end': }
#    Anchor['haproxy2::start'] -> Haproxy::Balancermember<||> -> Package['glance-api'] -> Package['glance-registry'] -> Package['cinder-api'] -> Package['heat-api'] -> Exec<| title == 'keystone-manage db_sync' |> -> Exec<| title == 'glance-manage db_sync' |> -> Exec<| title == 'nova-db-sync' |> -> Exec<| title == 'neutron-db-sync' |> -> Exec<| title == 'cinder-manage db_sync' |> -> Exec<| title == 'heat-dbsync' |> -> Anchor['haproxy2::end']


    #Haproxy::Balancermember<||> -> Package['keystone']
    #Service['haproxy'] -> Package['keystone']
    #Haproxy::Balancermember<||> -> Package['glance']
    #Service['haproxy'] -> Package['glance']
    #Haproxy::Balancermember<||> -> Package['glance-api']
    #Service['haproxy'] -> Package['glance-api']
    #Haproxy::Balancermember<||> -> Package['glance-registry']
    #Service['haproxy'] -> Package['glance-registry']
    #Haproxy::Balancermember<||> -> Package['cinder']
    #Service['haproxy'] -> Package['cinder']
    #Haproxy::Balancermember<||> -> Package['cinder-api']
    #Service['haproxy'] -> Package['cinder-api']
    #Haproxy::Balancermember<||> -> Package['heat-api']
    #Service['haproxy'] -> Package['heat-api']
    #Haproxy::Balancermember<||> -> Package['ceilometer-api']
    #Service['haproxy'] -> Package['ceilometer-api']
    #Haproxy::Balancermember<||> -> Exec<| title == 'keystone-manage db_sync' |>
    #Service['haproxy'] -> Exec<| title == 'keystone-manage db_sync' |>
    #Haproxy::Balancermember<||> -> Exec<| title == 'glance-manage db_sync' |>
    #Service['haproxy'] -> Exec<| title == 'glance-manage db_sync' |>
    #Haproxy::Balancermember<||> -> Exec<| title == 'nova-db-sync' |>
    #Service['haproxy'] -> Exec<| title == 'nova-db-sync' |>
    #Haproxy::Balancermember<||> -> Exec<| title == 'cinder-manage db_sync' |>
    #Service['haproxy'] -> Exec<| title == 'cinder-manage db_sync' |>
    #Haproxy::Balancermember<||> -> Exec<| title == 'heat-dbsync' |>
    #Service['haproxy'] -> Exec<| title == 'heat-dbsync' |>
    #Haproxy::Balancermember<||> -> Exec<| title == 'ceilometer-dbsync' |>
    #Service['haproxy'] -> Exec<| title == 'ceilometer-dbsync' |>
    
    
    #Haproxy::Balancermember<||> ~> Service['glance-api'] ~> Service['haproxy']
    #Haproxy::Balancermember<||> ~> Service['glance-registry'] ~> Service['haproxy'] 
    #Service['haproxy'] -> Exec<| title == 'keystone-manage db_sync' |>
    #Service['haproxy'] -> Exec<| title == 'glance-manage db_sync' |>
    #Exec<| title == 'keystone-manage db_sync'|> -> Class['keystone::service']

    #add haproxy user in mysql DB
    mysql_user {"haproxy@$local_ip":
        ensure => 'present',
    }

    #To enable haproxy logs
    file { "/etc/rsyslog.d/haproxy.conf":
        ensure => present,
    }
    
    $changes = [
        "\$ModLoad imudp",
        "\$UDPServerRun 514",
        "\$template Haproxy,\"%msg%\\n\"",
        "local0.=info -/var/log/haproxy.log;Haproxy",
        "local0.notice -/var/log/haproxy-status.log;Haproxy",
        "local0.* ~ ",
    ]
    $changes.each | $line | {
        file_line { "Append $line to /etc/rsyslog.d/haproxy.conf":
            path => "/etc/rsyslog.d/haproxy.conf",
            line => "$line",
            require => File['/etc/rsyslog.d/haproxy.conf']
        }
        File_line["Append $line to /etc/rsyslog.d/haproxy.conf"] ~> Exec<| title == 'rsyslogd restart' |>
    }

    Exec<| title == 'rsyslogd restart' |> ~> Service['haproxy']

    exec {'rsyslogd restart':
        command => "sudo service rsyslog restart",
        logoutput => true,
    }
}

