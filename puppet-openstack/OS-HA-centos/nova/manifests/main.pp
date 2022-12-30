class nova::main {
    class { 'nova::db::mysql':
       password   => $::openstack::config::mysql_pass_nova,
       host       => $::openstack::config::controller_address_management,
    }

    class { 'nova::keystone::auth':
       password   => $::openstack::config::mysql_pass_nova,
       #host       => $::openstack::config::controller_address_management,
       public_address => $::openstack::config::controller_address_api,
       admin_address => $::openstack::config::controller_address_management,
       internal_address => $::openstack::config::controller_address_management,
       region => $::openstack::config::region,
    }
    class { 'nova::cert':
       enabled        = 'true', 
    }
    class { 'nova::conductor':
       enabled        = 'true',
    }
    class { 'nova::consoleauth':
       enabled        = true,
    }
    class { 'nova::vncproxy':
       enabled        = 'true',
       host           = $::openstack::config::controller_address_management,
    }
    class { 'nova::scheduler':
       enabled        = 'true',
    }
    class { 'nova::client': }
    class { 'nova::api':
       admin_password  = $::openstack::config::
       enabled         = 'true',
       auth_host       = $::openstack::config::controller_address_management,
       rabbit_userid   = $::openstack::config::rabbitmq_user
       rabbit_password = $::openstack::config::rabbitmq_password,
    }  
    class { 'nova::db' :
       database_connection   = 'mysql://nova:NOVA_DBPASS@vip_ip/nova',
       database_idle_timeout = 1000,
    }
    class { 'nova::proxy' :
       host              = $::openstack::config::controller_address_management,
    }
}

 
