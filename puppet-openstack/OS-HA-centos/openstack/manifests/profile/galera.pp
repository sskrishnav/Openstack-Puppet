#Using Galera module.
class openstack::profile::galera {
    #$galera_package_name_internal = 'galera-3'

    if $::hostname =~ /^[\w-]+1$/ {
        $galera_servers = []
    }
    else {
        $galera_servers = $::openstack::config::galera_servers
    }
    $galera_master = $::openstack::config::galera_master
    $vendor_type = $::openstack::config::galera_vendor_type
    $local_ip = $::openstack::config::galera_local_ip
    $root_password = $::openstack::config::galera_root_password
    $status_password = $::openstack::config::galera_status_password

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "usr/local/bin/" ] }

    class galera_repo {
        yumrepo { 'mariadb':
            descr     => 'MariaDB Yum Repo',
            enabled   => 1,
            gpgcheck  => 1,
            gpgkey    => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
            baseurl   => 'http://yum.mariadb.org/10.0/rhel7-amd64/',
        }
    }
    include galera_repo

    #exec { "apt-get update":
    #    command => "apt-get update"
    #    command => "apt-key adv --keyserver hkp://keys.gnupg.net:80 --recv-keys 0xcbcb082a1bb943db"
    #} ->

    #exec {"add_galera_key":
    #    command => "apt-key adv --keyserver ${repo_keyserver} --recv-keys ${repo_key}",
    #    before => Class["::galera"],
    #}
    
    #package {"software-properties-common": 
    #    ensure => installed,
    #}

    #exec {"add_galera_repo_url":
    #    command => "add-apt-repository '${repo_location}'",
    #    before => Class["::galera"],
    #    require => Package['software-properties-common'],
    #}

    class { '::galera':
        #require => [Exec["add_galera_key"], Exec["add_galera_repo_url"]],
        require => Class["galera_repo"],
        galera_servers => $galera_servers,
        galera_master  => $galera_master,
        vendor_type => $vendor,
        local_ip => $local_ip,
        bind_address => $local_ip,
        root_password => $root_password,
        status_password => $status_password,
        configure_repo => false,

        mysql_port => 3306,
        wsrep_state_transfer_port => 4444,
        wsrep_inc_state_transfer_port => 4568,

        wsrep_group_comm_port => 4567,

        override_options => {
            'mysqld' => {
                'bind_address' => $local_ip,
                'collation-server' => 'utf8_general_ci',
                'init-connect' => 'SET NAMES utf8',
                'character-set-server' => 'utf8',
            }
        }
    }

    exec {"wait_after_galera_config":
        command => "sleep 30",
        require => Class['::galera']
    }
}
