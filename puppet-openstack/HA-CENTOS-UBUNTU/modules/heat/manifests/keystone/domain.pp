# == Class: heat::keystone::domain
#
# Configures heat domain in Keystone.
#
# Note: Implementation is done by heat-keystone-setup-domain script temporarily
#       because currently puppet-keystone does not support v3 API
#
# === Parameters
#
# [*auth_url*]
#   Keystone auth url
#
# [*keystone_admin*]
#   Keystone admin user
#
# [*keystone_password*]
#   Keystone admin password
#
# [*keystone_tenant*]
#   Keystone admin tenant name
#
# [*domain_name*]
#   Heat domain name. Defaults to 'heat'.
#
# [*domain_admin*]
#   Keystone domain admin user which will be created. Defaults to 'heat_admin'.
#
# [*domain_password*]
#   Keystone domain admin user password. Defaults to 'changeme'.
#
class heat::keystone::domain (
  $auth_url          = undef,
  $keystone_admin    = undef,
  $keystone_password = undef,
  $keystone_tenant   = undef,
  $domain_name       = 'heat',
  $domain_admin      = 'heat_admin',
  $domain_password   = 'changeme',
) {

  include heat::params

  $cmd_evn = [
    "OS_TENANT_NAME=${keystone_tenant}",
    "OS_USERNAME=${keystone_admin}",
    "OS_PASSWORD=${keystone_password}",
    "OS_AUTH_URL=${auth_url}",
    "HEAT_DOMAIN=${domain_name}",
    "HEAT_DOMAIN_ADMIN=${domain_admin}",
    "HEAT_DOMAIN_PASSWORD=${domain_password}"
  ]
  if $::osfamily == 'Debian' {
    exec { 'heat_domain_create':
      path        => '/usr/bin',
      command     => 'heat-keystone-setup-domain &>/dev/null',
      environment => $cmd_evn,
      require     => Package['heat-common'],
    }
  }
  if $::osfamily == 'RedHat' {
    exec { 'heat_domain_create':
      path        => '/usr/bin',
      command     => 'heat-keystone-setup-domain &>/dev/null',
      environment => $cmd_evn,
      require     => Package['openstack-heat-common'],
    }
  }

  heat_config {
    'DEFAULT/stack_domain_admin':          value => $domain_admin;
    'DEFAULT/stack_domain_admin_password': value => $domain_password, secret => true;
    'DEFAULT/stack_user_domain_name':      value => $domain_name;
  }

}
