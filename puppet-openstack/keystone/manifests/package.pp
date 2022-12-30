class keystone::package {
    Package { ensure => 'installed' }

    package { 'apache2': }
    package { 'libapache2-mod-wsgi': }
}
