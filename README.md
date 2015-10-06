# chef-server-upgrade -- All commands are 'root'

## References

https://getchef.zendesk.com/hc/en-us/articles/204223664-How-Can-I-Clone-A-Chef-Server-System-For-Testing-Patches-or-Upgrades-

https://docs.chef.io/upgrade_server.html

## Validate your current install passes tests

```
private-chef-ctl test
```

## Stop things in sane state

```
private-chef-ctl reconfigure
private-chef-ctl stop
/bin/rm -f /etc/opscode/chef-server.rb #  (settings will be copied from private-chef.rb)
```

## Make the backups

```
# Backup just the data and configs:
chefbackup='/var/chefbackup.tar'
for i in \
  "`find /var/opt/opscode -name "data" && find /var/opt/opscode/rabbitmq -name "db"`"; do
    tar -cvpf $chefbackup $i;
done

tar --append -pvf $chefbackup /etc/opscode --exclude /etc/opscode/chef-server-running.json
bzip2 $chefbackup

# Backup everything -- we shouldn't need it, but just in case
tar -czpf /var/chefall.tgz /var/opt/opscode /etc/opscode
```

## Verify the backup

```
ls -lh $chefbackup.bz2 # should be 8M at a min
bzip2 -d -c $chefbackup.bz2 | tar -tf -   # should see lots of files
```

## Get the RPM onto the box for the current version and the next version

```
curl -L \
  https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.2.0-1.el6.x86_64.rpm \
  -o /root/chef-server.rpm -vs
curl -L \
  https://web-dl.packagecloud.io/chef/stable/packages/el/6/private-chef-11.3.2-1.el6.x86_64.rpm \
  -o /root/private-chef.rpm -vs
```

## Do the upgrade

```
rpm -Uvh --nopostun /root/chef-server.rpm
chef-server-ctl upgrade  # go get coffee
chef-server-ctl start
```

## Test

###  On chef-server machine

```
chef-server-ctl test
```

### on clients

`chef-client`

### on workstation

```
knife node list
knife node search '*:*'
knife cookbook upload ...
```

## Rollback

```
chef-server-ctl stop
rpm --erase chef-server-core
rpm -Uvh --nopostun /root/private-chef.rpm
```

### Cleanup the database files

```
RM='/bin/rm -rf'
for i in \
  "`find /var/opt/opscode -name "data" && find /var/opt/opscode/rabbitmq -name "db"`"; do
    $RM $i;
    $RM /etc/opscode
done
```

### Restore databases and test

```
bzip2 -d -c $chefbackup.bz2 | tar -C / -xvf -
private-chef-ctl reconfigure
private-chef-ctl start
private-chef-ctl test
```

### Also the tests above for the upgrade

## Done with upgrade/rollback


# Set up for the upgrade test:

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
