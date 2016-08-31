name 'common_auth'
default_source :supermarket

default[:common_auth][:users][:user_memberships] = true

default['common_auth']['groups']['config'].tap do |config|
  config['team_devops']['include_members'] = false
  config['team_devops']['members'] = ['jonathan']
  config['team_devops']['action'] = 'create'
end

run_list 'common_auth::default'
cookbook 'common_auth', path: '.'
cookbook 'common_attrs'
