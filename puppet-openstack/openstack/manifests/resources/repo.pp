#
# Sets up the package repos necessary to use OpenStack
# on RHEL-alikes and Ubuntu
#
class openstack::resources::repo(
  $release = 'kilo'
) {
  if !$::openstack::config::local_repo {
    case $release {
      'kilo', 'juno', 'icehouse', 'havana', 'grizzly': {
        if $::osfamily == 'RedHat' {
          class {'openstack::resources::repo::rdo': release => $release }
          class {'openstack::resources::repo::erlang': }
        } elsif $::osfamily == 'Debian' {
          class {'openstack::resources::repo::uca': release => $release }
        }
      }
      default: {
        fail { "FAIL: openstack::resources::repo parameter 'release' of '${release}' not recognized; please use one of 'kilo', 'juno', 'icehouse', 'havana', 'grizzly'.": }
      }
    }
  }
  else {
    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "usr/local/bin/" ] }
    if $::osfamily == 'Debian' {
      exec {"backup_ubuntu_repo":
        command => "mv /etc/apt/sources.list /etc/apt/sources.list.ubuntu"
      }
      class {'::apt':
        disable_keys       => true,
        purge_sources_list => true,
      }
      file_line{"add_local_repo":
        path => "/etc/apt/sources.list",
        line => $::openstack::config::local_repo,
      }

      anchor {"local_repo_begin":}
      anchor {"local_repo_end":}
      Anchor ['local_repo_begin'] -> 
      Exec['backup_ubuntu_repo'] ->
      Class['::apt'] -> 
      File_line['add_local_repo'] ->
      Anchor['local_repo_end']
      }
  }
}
