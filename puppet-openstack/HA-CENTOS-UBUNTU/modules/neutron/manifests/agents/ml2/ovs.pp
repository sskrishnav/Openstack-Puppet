#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: neutron::agents::ml2::ovs
#
# Setups OVS neutron agent when using ML2 plugin
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to 'present'
#
# [*enabled*]
#   (required) Whether or not to enable the OVS Agent
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*bridge_uplinks*]
#   (optional) List of interfaces to connect to the bridge when doing
#   bridge mapping.
#   Defaults to empty list
#
# [*bridge_mapping*]
#   (optional) List of <physical_network>:<bridge>
#   Defaults to empty list
#
# [*integration_bridge*]
#   (optional) Integration bridge in OVS
#   Defaults to 'br-int'
#
# [*enable_tunneling*]
#   (optional) Enable or not tunneling
#   Defaults to false
#
# [*tunnel_types*]
#   (optional) List of types of tunnels to use when utilizing tunnels,
#   either 'gre' or 'vxlan'.
#   Defaults to false
#
# [*local_ip*]
#   (optional) Local IP address of GRE tunnel endpoints.
#   Required when enabling tunneling
#   Defaults to false
#
# [*tunnel_bridge*]
#   (optional) Bridge used to transport tunnels
#   Defaults to 'br-tun'
#
# [*vxlan_udp_port*]
#   (optional) The UDP port to use for VXLAN tunnels.
#   Defaults to '4789'
#
# [*polling_interval*]
#   (optional) The number of seconds the agent will wait between
#   polling for local device changes.
#   Defaults to '2"
#
# [*l2_population*]
#   (optional) Extension to use alongside ml2 plugin's l2population
#   mechanism driver.
#   Defaults to false
#
# [*arp_responder*]
#   (optional) Enable or not the ARP responder.
#   Recommanded when using l2 population mechanism driver.
#   Defaults to false
#
# [*firewall_driver*]
#   (optional) Firewall driver for realizing neutron security group function.
#   Defaults to 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'.
#
# [*enable_distributed_routing*]
#   (optional) Set to True on L2 agents to enable support
#   for distributed virtual routing.
#   Defaults to false
#
class neutron::agents::ml2::ovs (
  $package_ensure             = 'present',
  $enabled                    = true,
  $manage_service             = true,
  $bridge_uplinks             = [],
  $bridge_mappings            = [],
  $integration_bridge         = 'br-int',
  $enable_tunneling           = true,
  $enable_security_group      = true,
  $enable_ipset               = true,
  $tunnel_types               = [],
  $local_ip                   = false,
  $tunnel_bridge              = 'br-tun',
  $vxlan_udp_port             = 4789,
  $polling_interval           = 2,
  $l2_population              = false,
  $arp_responder              = false,
  $firewall_driver            = 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
  $enable_distributed_routing = false,
) {

  include ::neutron::params
  require vswitch::ovs

  if $enable_tunneling and ! $local_ip {
    fail('Local ip for ovs agent must be set when tunneling is enabled')
  }

  if $enable_tunneling and $enable_distributed_routing and ! $l2_population {
    fail('L2 population must be enabled when DVR and tunneling are enabled')
  }

  Package['neutron-ovs-agent'] -> Neutron_agent_ovs<||>
  Neutron_agent_ovs<||> ~> Service['neutron-ovs-agent-service']

  if ($bridge_mappings != []) {
    # bridge_mappings are used to describe external networks that are
    # *directly* attached to this machine.
    # (This has nothing to do with VM-VM comms over neutron virtual networks.)
    # Typically, the network node - running L3 agent - will want one external
    # network (often this is on the control node) and the other nodes (all the
    # compute nodes) will want none at all.  The only other reason you will
    # want to add networks here is if you're using provider networks, in which
    # case you will name the network with bridge_mappings and add the server's
    # interfaces that are attached to that network with bridge_uplinks.
    # (The bridge names can be nearly anything, they just have to match between
    # mappings and uplinks; they're what the OVS switches will get named.)

    # Set config for bridges that we're going to create
    # The OVS neutron plugin will talk in terms of the networks in the bridge_mappings
    $br_map_str = join($bridge_mappings, ',')
    neutron_agent_ovs {
      'ovs/bridge_mappings': value => $br_map_str;
    }
    neutron::plugins::ovs::bridge{ $bridge_mappings:
      before => Service['neutron-ovs-agent-service'],
    }
    neutron::plugins::ovs::port{ $bridge_uplinks:
      before => Service['neutron-ovs-agent-service'],
    }
  }

  #neutron_agent_ovs {
    #'agent/polling_interval':           value => $polling_interval;
    #'agent/l2_population':              value => $l2_population;
    #'agent/arp_responder':              value => $arp_responder;
    #'agent/enable_distributed_routing': value => $enable_distributed_routing;
    #'ovs/integration_bridge':           value => $integration_bridge;
  #}
  neutron_agent_ovs {
    'agent/polling_interval':           ensure => absent;
    'agent/l2_population':              ensure => absent;
    'agent/arp_responder':              ensure => absent;
    'agent/enable_distributed_routing': ensure => absent;
    'ovs/integration_bridge':           value => $integration_bridge; 
  }
  if $enable_security_group {
    neutron_agent_ovs { 'securitygroup/enable_security_group': value => $enable_security_group }
  } else {
    neutron_agent_ovs { 'securitygroup/enable_security_group': ensure => absent }
  }
 
  if $enable_ipset {
    neutron_agent_ovs { 'securitygroup/enable_ipset': value => $enable_security_group }
  } else {
    neutron_agent_ovs { 'securitygroup/enable_ipset': ensure => absent }
  }

  if $firewall_driver {
    neutron_agent_ovs { 'securitygroup/firewall_driver': value => $firewall_driver }
  } else {
    neutron_agent_ovs { 'securitygroup/firewall_driver': ensure => absent }
  }

  if $enable_tunneling {
    neutron_agent_ovs {
      'ovs/enable_tunneling': value => true;
      'ovs/tunnel_bridge':    value => $tunnel_bridge;
      #'ovs/enable_tunneling': ensure => absent;
      #'ovs/tunnel_bridge':    ensure => absent;
      'ovs/local_ip':         value => $local_ip;
    }

    if size($tunnel_types) > 0 {
      neutron_agent_ovs {
        'agent/tunnel_types': value => join($tunnel_types, ',');
      }
    }
    if 'vxlan' in $tunnel_types {
      validate_vxlan_udp_port($vxlan_udp_port)
      neutron_agent_ovs {
        'agent/vxlan_udp_port': value => $vxlan_udp_port;
      }
    }
  } else {
    neutron_agent_ovs {
      #'ovs/enable_tunneling': value  => false;
      #'ovs/tunnel_bridge':    ensure => absent;
      'ovs/local_ip':         ensure => absent;
    }
  }


  if $::neutron::params::ovs_agent_package {
    package { 'neutron-ovs-agent':
      ensure => $package_ensure,
      name   => $::neutron::params::ovs_agent_package,
      tag    => 'openstack',
    }
  } else {
    # Some platforms (RedHat) do not provide a separate
    # neutron plugin ovs agent package. The configuration file for
    # the ovs agent is provided by the neutron ovs plugin package.
    if ! defined(Package['neutron-ovs-agent']) {
      package { 'neutron-ovs-agent':
        ensure => $package_ensure,
        name   => $::neutron::params::ovs_server_package,
        tag    => 'openstack',
      }
    }
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'neutron-ovs-agent-service':
    ensure  => $service_ensure,
    name    => $::neutron::params::ovs_agent_service,
    enable  => $enabled,
    require => Class['neutron'],
  }

  if $::neutron::params::ovs_cleanup_service {
    Package['neutron-ovs-agent'] -> Service['ovs-cleanup-service']
    service { 'ovs-cleanup-service':
      name   => $::neutron::params::ovs_cleanup_service,
      enable => $enabled,
    }
  }
}
