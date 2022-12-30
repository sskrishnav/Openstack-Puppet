# Class: rsync
#
# This module manages rsync
#
class rsync($package_ensure = 'installed') {

  if !defined(Package["rsync"]) {
    package { 'rsync':
      ensure => $package_ensure,
    } -> Rsync::Get<| |>
  }
  else {
    Package["rsync"] -> Rsync::Get<| |>
  }
}
