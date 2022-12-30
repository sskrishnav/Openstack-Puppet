class keystone::apache-wsgi {

  
  file { '/etc/apache2/apache2.conf':
    ensure => present,
  }->
  file_line { 'Append a line to apache2.conf':
    path => '/etc/apache2/apache2.conf',
    line => "ServerName $hiera(openstack::mysql::host_address)",
  }

  exec { 'copy':
       command   => 'cp /etc/puppet/wsgi-keystone.conf /etc/apache2/sites-available/.',
       path      => '/bin',
  }

  exec { 'link':
       command   => 'ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled',
       path      => '/bin',
       require   => Exec['copy'],
  }

  file { '/var/www/cgi-bin/keystone':
    ensure => 'directory',
    owner  => 'keystone',
    group  => 'keystone',
    recurse => 'true',
    mode   => '0750',
  }

  package { 'curl':
    ensure => 'present',
  }

  exec { 'curl-copy':
       command   => 'curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo \
  | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin',
       path      => '/usr/bin',
       require   => [ Package['curl'], File['/var/www/cgi-bin/keystone'] ]
  }

  service { 'apache2':
      ensure  => 'running',
      enable  => 'true',
      require => [ Exec['curl-copy'], File['/var/www/cgi-bin/keystone'] ],
  }
}   


