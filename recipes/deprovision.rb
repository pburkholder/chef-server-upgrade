#
# Cookbook Name:: chef_server_upgrade
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
require 'chef/provisioning/aws_driver'
provision_name = 'chef_server_upgrade'

with_driver 'aws::us-east-1' do
  %w(cs-prod).each do |cs_machine|
    machine cs_machine do
      action :destroy
    end
  end
  #aws_security_group provision_name do
  #  description name
  #  action :destroy
  #end
end
