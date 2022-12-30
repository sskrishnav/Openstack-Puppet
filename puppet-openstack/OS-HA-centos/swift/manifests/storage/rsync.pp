class swift::storage::rsync(
  $mgmt_ip,
) {

  concat::fragment { 'swift_rsync':
    target  => '/etc/rsyncd.conf',
    content => template('swift/rsyncd.conf.erb'),
    order   => '26',
  }

}
