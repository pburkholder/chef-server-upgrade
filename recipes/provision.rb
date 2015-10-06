#
# Cookbook Name:: chef_server_upgrade
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
require 'chef/provisioning/aws_driver'

provision_name = 'chef_server_upgrade'
inbound_ip     = '108.56.0.0/16'
image_id       = 'ami-bc8131d4'
key_name       = 'pburkholder-one'

with_driver 'aws::us-east-1' do
  aws_security_group provision_name do
    description name
    inbound_rules([
      { port: 22, protocol: :tcp, sources: [inbound_ip] },
      { port: 443, protocol: :tcp, sources: ['172.31.0.0/16'] },
      { port: 443, protocol: :tcp, sources: [inbound_ip] }
    ])
  end

  # use the Centos 'official' AMI,
  # which unfortunately uses a root login
  with_machine_options(
    ssh_username: 'root',
    bootstrap_options: {
      instance_type: 'm1.small',
      image_id: image_id,
      security_group_ids: [provision_name],
      key_name: key_name
    }
  )

  %w(cs-prod).each do |cs_machine|
    machine cs_machine do
      action :converge
      recipe 'chef_server_upgrade::chefserver'
    end
  end
end
