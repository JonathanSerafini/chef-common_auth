
resource_name :common_group_account

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

property :require_members,
  kind_of: [TrueClass, FalseClass],
  default: true

property :sudoer,
  kind_of: Hash,
  default: Hash.new

action :create do
  # Register this managed group to support deletions
  #
  node.set[:common_auth][:groups][:managed][name] = true

  if new_resource.require_members
    new_resource.members.each do |member|
      next if node[:etc][:passwd].keys.include?(member)
      raise ArgumentError.new "This group requires the presence of #{member}"
    end
  end

  group name do
    gid gid
    members members
  end

  sudo name do
    common_properties(sudoer)
    action :nothing if sudoer.empty?
  end
end

action :remove do
  if node[:etc][:group][name]
    node.set[:common_auth][:groups][:managed][name] = false
  else
    node.normal[:common_auth][:groups][:managed].delete(name)
  end

  sudo name do
    action :remove
  end

  group name do
    action :remove
  end
end
