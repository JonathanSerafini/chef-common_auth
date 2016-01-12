
resource_name :group_account

property :name,
  kind_of:  String,
  identity: true,
  name_property: true

property :gid,
  kind_of:  Integer,
  coerce: proc { |value| value.to_i }

property :members,
  kind_of: Array,
  default: Array.new

property :sudoer,
  kind_of: Hash,
  default: Hash.new

action :create do
  # Register this managed group to support deletions
  #
  node.set[:common][:auth][:groups][:managed][name] = true

  group name do
    gid gid
    members members
  end

  sudo name do
    load_properties(sudoer)
    action :nothing if sudoer.empty?
  end
end

action :remove do
  if node[:etc][:group][name]
    node.set[:common][:auth][:groups][:managed][name] = false
  else
    node.normal[:common][:auth][:groups][:managed].delete(name)
  end

  sudo name do
    action :remove
  end

  group name do
    action :remove
  end
end
