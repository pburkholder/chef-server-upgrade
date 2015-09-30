
# Assume: cs-prod.pburkholder.com chefserver-prod,
# and cs-test.pburkholder.com for the test machine

remote_file 'private-chef.rpm' do
  path '/root/private-chef.rpm'
  source 'https://web-dl.packagecloud.io/chef/stable/packages/el/6/private-chef-#{version}-1.el6.x86_64.rpm'
  checksum '6766b26039ace2c4749b870cb0d7840c1546da0470840f75e41ff587fce6a8de'
end

package 'private-chef' do
  action :install
  source '/root/private-chef.rpm'
  notifies :run, 'execute[pc-reconfigure]', :delayed
end

directory '/etc/opscode' do
  mode '0755'
end

file '/etc/opscode/chef-server.rb' do
  content "api_fqdn 'cs-prod.pburkholder.com'\n"
  mode '0644'
  notifies :run, 'execute[pc-reconfigure]', :delayed
end

execute 'pc-reconfigure' do
  command '/opt/opscode/bin/private-chef-ctl reconfigure'
  action :nothing
end

gem_package 'knife-opc' do
  gem_binary '/opt/chef/embedded/bin/gem'
end

knife_rb = <<-END.gsub(/^ +/, '')
  node_name "pivotal"
  chef_server_url "https://127.0.0.1:443"
  chef_server_root "https://127.0.0.1:443"
  client_key "/etc/opscode/pivotal.pem"
  ssl_verify_mode :verify_none
END

file '/root/knife.rb' do
  content knife_rb
end

execute 'create_prod_org' do
  creates '/root/prod.pem'
  command 'knife opc org create prod prod > /root/prod.pem'
  action :run
end

commands = <<-END
knife opc user create superadmin Peter Burkholder pburkholder@chef.io NotTooLate2bSecure > superadmin.pem
knife opc org user add prod superadmin
END
