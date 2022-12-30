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

  file { "/etc/apache2/sites-available/wsgi-keystone.conf":
    source => "puppet:///modules/keystone/wsgi-keystone.conf",
  }

  file_line { 'public':
    path => '/etc/apache2/sites-available/wsgi-keystone.conf',
    line => "Listen $host:5000",
  }

  file_line { 'private':
    path => '/etc/apache2/sites-available/wsgi-keystone.conf',
    line => "Listen $host:35357",
    require => File_line['public'],
  }

  #exec { 'copy':
  #     command   => 'cp /etc/puppet/modules/keystone/manifests/wsgi-keystone.conf /etc/apache2/sites-available/.',
  #     path      => '/bin',
  #     require   => File_line['private'],
  #}

  file { "/etc/apache2/sites-enabled/wsgi-keystone.conf":
    ensure => 'link',
    target => "/etc/apache2/sites-available/wsgi-keystone.conf",
    require   => File_line['private'],
  }
  #exec { 'link':
  #     command   => 'ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled',
  #     path      => '/bin',
  #     require   => File["/etc/apache2/sites-available/wsgi-keystone.conf"],
  #}

  file { '/var/www/cgi-bin':
    ensure => 'directory',
    owner  => 'keystone',
    group  => 'keystone',
    recurse => 'true',
    mode   => '0755',
    require => File["/etc/apache2/sites-enabled/wsgi-keystone.conf"],
  }

  file { '/var/www/cgi-bin/keystone':
    ensure => 'directory',
    owner  => 'keystone',
    group  => 'keystone',
    recurse => 'true',
    mode   => '0755',
    require => [ File["/etc/apache2/sites-enabled/wsgi-keystone.conf"], File['/var/www/cgi-bin'] ]
  }

  exec { 'check_curl':
      unless => "dpkg -l | grep curl",
      command => "apt-get -q -y -o DPkg::Options::=--force-confold install curl",
      path    => ['/bin','/usr/bin','/sbin','/usr/sbin','/usr/local/sbin'],
      require => [ File['/var/www/cgi-bin/keystone'] ]
  }


  exec { 'curl-copy':
       command   => 'curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin',
       path      => '/usr/bin:/bin',
       require   => [ Exec['check_curl'] ]
  }

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

  
  service { 'apache2':
      ensure  => 'running',
      enable  => 'true',
      require => [ File['/var/www/cgi-bin/keystone/main'], File['/var/www/cgi-bin/keystone/admin'] ]
  }
  exec { 'restart':
      command => "service apache2 restart",
      path    => ["/usr/sbin", "/usr/bin", "/sbin", "/bin/", "/root/"],
      require => [ File['/var/www/cgi-bin/keystone/main'], File['/var/www/cgi-bin/keystone/admin'] ],
  }
}   

