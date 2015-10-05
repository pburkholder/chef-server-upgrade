default[:chef_server_upgrade][:api_fqdn] = 'cs-prod.cheffian.com'
default[:chef_server_upgrade][:version] = '11.3.2'
default[:chef_server_upgrade][:homeip] = '108.56.0.0/16'

provision_name = 'chef_server_upgrade'
inbound_ip     = '108.56.0.0/16'
image_id       = 'ami-bc8131d4'
key_name       = 'pburkholder-one'
