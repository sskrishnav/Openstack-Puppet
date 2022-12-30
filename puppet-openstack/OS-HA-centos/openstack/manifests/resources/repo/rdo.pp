# RDO repo (supports both RHEL-alikes and Fedora, requires EPEL)
class openstack::resources::repo::rdo(
  $release = 'kilo'
) {
  include openstack::resources::repo::epel

  #$release_cap = capitalize($release)
  $release_cap = "kilo"

  if $::osfamily == 'RedHat' {
    case $::operatingsystem {
      fedora: { $dist = 'fedora' }
      default: { $dist = 'epel' }
    }
    # $lsbmajdistrelease is only available with redhat-lsb installed
    $osver = regsubst($::operatingsystemrelease, '(\d+)\..*', '\1')

    package { 'openstack-selinux':
        ensure => present,
    }

    package { 'erlang':
        ensure => present,
        require   => [ Package['openstack-selinux'], Yumrepo['erlang-solutions'] ]
        #require   => [ Yumrepo['erlang-solutions' ] 
    }
    
    yumrepo { 'openstack-kilo':
      #baseurl  => "http://repos.fedorapeople.org/repos/openstack/openstack-${release}/${dist}-${osver}/",
      baseurl  => "http://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7/",
      descr    => "OpenStack ${release_cap} Repository",
      enabled  => 1,
      gpgcheck => 1,
      #gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-${release_cap}",
      gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-kilo",
      priority => 98,
      notify   => Exec['yum_refresh'],
    }
    file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-${release_cap}":
      source => "puppet:///modules/openstack/RPM-GPG-KEY-RDO-${release_cap}",
      owner  => root,
      group  => root,
      mode   => '0644',
      before => Yumrepo['openstack-kilo'],
    }
    Yumrepo<||> -> Package<||>

  }
}
