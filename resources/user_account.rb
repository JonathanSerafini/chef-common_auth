
resource_name :user_account

property :name,
  kind_of:  String,
  identity: true,
  name_property: true

property :uid,
  kind_of:  Integer,
  identity: true,
  coerce: proc { |value| value.to_i }

property :gid,
  kind_of:  Integer,
  identity: true,
  coerce: proc { |value| value.to_i }

property :comment,
  kind_of:  String,
  default: "Managed by Chef"

property :home,
  kind_of:  String,
  identity: true,
  default:  lazy { |r| 
    ::File.join(node[:common][:auth][:users][:defaults][:home], "#{r.name}")
  }

property :shell,
  kind_of:  String,
  identity: true,
  default:  lazy { node[:common][:auth][:users][:defaults][:shell] }

property :password,
  kind_of:  String,
  regex:    /^\$6\$/

property :keys,
  kind_of:  Hash

property :manage_home,
  kind_of: [TrueClass, FalseClass],
  default: True

property :manage_keys,
  kind_of: [TrueClass, FalseClass],
  default: True

action :create do
  node.set[:common][:auth][:users][:managed][name] = true

  user name do
    uid     uid
    gid     gid
    home    home
    shell   shell
    comment comment
    password password
    manage_home manage_home
  end

  user_keys name do
    owner name
    group name
    home  home
    load_properties(keys)
    only_if { manage_keys }
  end
end

action :remove do
  if node[:etc][:passwd][name]
    node.set[:common][:auth][:users][:managed][name] = false
  else
    node.normal[:common][:auth][:users][:managed].delete(name)
  end

  user name do
    action :remove
  end
end

action :lock do
  node.set[:common][:auth][:users][:managed][name] = true

  user name do
    action :lock
  end
end

action :unlock do
  node.set[:common][:auth][:users][:managed][name] = true

  user name do
    action :unlock
  end
end
