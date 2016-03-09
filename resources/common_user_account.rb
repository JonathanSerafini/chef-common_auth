
resource_name :common_user_account

property :name,
  kind_of:  String,
  identity: true,
  name_property: true

property :uid,
  kind_of:  Integer,
  identity: true,
  coerce:   proc { |value| value.to_i }

property :gid,
  kind_of:  Integer,
  identity: true,
  coerce:   proc { |value| value.to_i }

property :comment,
  kind_of:  String,
  default: "Managed by Chef"

property :home,
  kind_of:  String,
  identity: true,
  default:  lazy { |r| 
    ::File.join(node[:common_auth][:users][:defaults][:home], "#{r.name}")
  }

property :shell,
  kind_of:  String,
  identity: true,
  default:  lazy { node[:common_auth][:users][:defaults][:shell] }

property :password,
  kind_of:  String,
  regex:    /^\$6\$/,
  coerce:   proc { |value| Common::Delegator::ObfuscatedType.new(value) }

property :keys,
  kind_of:  Hash,
  coerce:   proc { |value| Common::Delegator::ObfuscatedType.new(value) }

property :manage_home,
  kind_of: [TrueClass, FalseClass],
  default: true

property :manage_keys,
  kind_of: [TrueClass, FalseClass],
  default: true

action :create do
  node.set[:common_auth][:users][:managed][name] = true

  user new_resource.name do
    uid       new_resource.uid
    gid       new_resource.gid
    home      new_resource.home
    shell     new_resource.shell
    comment   new_resource.comment
    password  new_resource.password
    manage_home new_resource.manage_home
  end
  
  common_user_keys new_resource.name do
    owner new_resource.name
    group new_resource.name
    home  new_resource.home
    common_properties(new_resource.keys)
    only_if { new_resource.manage_keys }
  end
end

action :remove do
  if node[:etc][:passwd][name]
    node.set[:common_auth][:users][:managed][name] = false
  else
    node.normal[:common_auth][:users][:managed].delete(name)
  end

  user new_resource.name do
    action :remove
  end
end

action :lock do
  node.set[:common_auth][:users][:managed][name] = true

  user new_resource.name do
    action :lock
  end
end

action :unlock do
  node.set[:common_auth][:users][:managed][name] = true

  user name do
    action :unlock
  end
end
