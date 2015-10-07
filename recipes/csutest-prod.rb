# chef_server_upgrade
# Recipe:: csutest-prod
#
# Create test nodes that associate to the 'prod' org on
# the cs_prod server for testing chef_server_upgrades

require 'chef/provisioning/aws_driver'
require_relative '../libraries/helpers'

role = 'csutest'
org  = 'prod'
inbound_ip     = '108.56.0.0/16'

role_org = role + '-' + org

with_driver 'aws::us-east-1' do
  aws_security_group role_org do
    description name
    inbound_rules inbound_ip => 22
  end

  aws_launch_configuration role_org do
    image 'ami-d85e75b0' # Trusty
    instance_type 'm1.small'
    options(
      security_groups: [role_org],
      # iam_instance_profile: 'pburkholder-ec2-bootstrap',
      # iam_instance_profile: 'cheffian-ec2-bootstrap',
      key_pair: 'pburkholder-one',
      user_data: user_data
    )
  end

  aws_auto_scaling_group role_org do
    desired_capacity 8
    min_size 0
    max_size 10
    launch_configuration role_org
    availability_zones ['us-east-1c']
  end
end
