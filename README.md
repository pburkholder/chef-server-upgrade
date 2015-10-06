# chef-server-upgrade

1. Provision the chef-server with `chef-client -z recipes\provision.rb -c .client.rb`

That in turn runs `recipes\chefserver.rb` to set up the 11.3.2 chef server

From that box:
- grab the public DNS and set that as a CNAME for the `api_fqdn`
- grab the `prod.pem` as a validator pem and save to $home/.chef/prod.pem
- grab superadmin.pem as your client key and save to $home/.chef/superadmin.pem
- `knife ssl fetch`

2. set up to use the new chef server

```
$env:CHEF_SERVER = 'prod'
knife ssl fetch https://cs-prod.cheffian.com
scp root@cs-prod.cheffian.com:prod.pem $home/.chef/prod.pem
scp root@cs-prod.cheffian.com:superadmin.pem $home/.chef/superadmin.pem
```

Add the role for our csutest Role

```
knife role from file roles/csutest-prod.json
```

4. Spin up an ASG

```
chef-client -c .\.client.rb -o 'chef_server_upgrade::csutest-prod'
```

5. Test

```
knife node list -c .client.rb
knife search node '*:*' -c client.rb
```



TODO: Enter the cookbook description here.
