class keystone::package {
    Package { ensure => 'installed' }
    if $::osfamily == 'Debian' {
       package { 'apache2': }
       package { 'libapache2-mod-wsgi': }
    }
    elsif $::osfamily == 'RedHat' {
       package { 'httpd': }
       package { 'mod_wsgi': }
    }
}
