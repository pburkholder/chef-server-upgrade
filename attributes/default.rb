default['chef-server']['api_fqdn'] = 'ec11.pburkholder.com'
default['chef-server']['version'] = '11.3.2'
default['cs113']['version'] = '11.3.2'

ROLE COOKBOOK
cookbooks/registration/attributes/default:Y
default['cs113']['version'] = '11.4.3'

cookbooks/registration/recipes/default:Y
include_recipe 'base'
include_recipe 'security'

cookbooks/purchase/attributes/default:
default['cs113']['version'] = '11.4.2'

APPLICATION


include_recipe 'cs113::chefserver'

RUNLIST:

role['registration']
  runlist: base, security, java, registration


recipe['registration']


ENVIRONMENT COOKBOOK PATTER
cookbooks/my_prod/
cookbooks/my_dev/

CHEF ENVIRONMENTS
chef-repo/environments
  dev.json
  prod.json

  prod_blue.json
  prod_green.json





attributes: {
  top_level
  'cs113':
    'version': '13.3.4'
}


knife environment from file prod.json
