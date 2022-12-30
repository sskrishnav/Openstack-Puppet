#keystone::apache-wsgi class
class keystone::apache-wsgi {

  $host = $::openstack::config::controller_address_management,

  file { '/etc/apache2/apache2.conf':
    ensure => present,
  } 
  file_line { 'Append a line to apache2.conf':
    path => '/etc/apache2/apache2.conf',
    line => "ServerName ${host}",
    require => File['/etc/apache2/apache2.conf'],
  }

  file_line { 'public':
    path => '/etc/puppet/modules/keystone/manifests/wsgi-keystone.conf',
    line => "Listen $host:5000",
  }

  file_line { 'private':
    path => '/etc/puppet/modules/keystone/manifests/wsgi-keystone.conf',
    line => "Listen $host:35357",
    require => File_line['public'],
  }

  exec { 'copy':
       command   => 'cp /etc/puppet/modules/keystone/manifests/wsgi-keystone.conf /etc/apache2/sites-available/.',
       path      => '/bin',
       require   => File_line['private'],
  }

  exec { 'link':
       command   => 'ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled',
       path      => '/bin',
       require   => Exec['copy'],
  }

  file { '/var/www/cgi-bin':
    ensure => 'directory',
    owner  => 'keystone',
    group  => 'keystone',
    recurse => 'true',
    mode   => '0755',
    require => Exec['link'],
  }

  file { '/var/www/cgi-bin/keystone':
    ensure => 'directory',
    owner  => 'keystone',
    group  => 'keystone',
    recurse => 'true',
    mode   => '0755',
    require => [ Exec['link'], File['/var/www/cgi-bin'] ]
  }

  #package { 'curl':
  #  ensure => 'present',
  #}
  notice( "step4" )
  exec { 'curl-copy':
       command   => 'curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin',
       path      => '/usr/bin',
       require   => [ File['/var/www/cgi-bin/keystone'] ]
  }
  notice( "step5" )
  file { '/var/www/cgi-bin/keystone/main':
    ensure => 'present',
    mode   => '0755',
    require => Exec['curl-copy'],
  }

  file { '/var/www/cgi-bin/keystone/admin':
    ensure => 'present',
    mode   => '0755',
    require => Exec['curl-copy'],
  }

  
  notice( "step6" )
  service { 'apache2':
      ensure  => 'running',
      enable  => 'true',
      require => Exec['curl-copy'],
  }
  notice( "step7" )
  exec { 'restart':
      command => "service apache2 restart",
      path    => ["/usr/sbin", "/usr/bin", "/sbin", "/bin/", "/root/"],
      require => Service['apache2'],
  }
}   
