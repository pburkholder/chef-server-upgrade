# chef-server-upgrade

1. Provision the chef-server with `chef-client -z recipes\provision.rb`

That in turn runs `recipes\chefserver.rb` to set up the 11.3.2 chef server

From that box:
- grab the public DNS and set that as a CNAME for the `api_fqdn`
- grab the `prod.pem` as a validator pem and save to $home/.chef/prod.pem
- grab superadmin.pem as your client key and save to $home/.chef/superadmin.pem
- `knife ssl fetch`


2. set up to use the new chef server

3. test a single node

4. spin up a bunch


TODO: Enter the cookbook description here.
