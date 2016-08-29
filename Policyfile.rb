name 'common_auth'
default_source :supermarket

default['common_auth']['groups']['config'].tap do |config|
  #config['devops']['members'] = ['']
  config['devops']['action'] = 'create'
end

run_list 'common_auth::default'
cookbook 'common_auth', path: '.'
cookbook 'common_attrs'
