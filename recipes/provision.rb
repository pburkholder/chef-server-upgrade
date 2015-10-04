#
# Cookbook Name:: chef_server_upgrade
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
require 'chef/provisioning/aws_driver'

provision_name = 'chef_server_upgrade'

with_driver 'aws::us-east-1' do
  aws_security_group provision_name do
    description name
    inbound_rules '108.56.240.213/32' => 22
  end

  with_machine_options(
    ssh_username: 'root',
    bootstrap_options: {
      instance_type: 'm1.small',
      image_id: 'ami-bc8131d4',
      security_group_ids: [provision_name],
      key_name: 'pburkholder-one'
    }
  )

  %w(cs-prod cs-test).each do |cs_machine|
    machine cs_machine do
      action :allocate
      recipe 'chef_server_upgrade::chefserver'
    end
  end
end
