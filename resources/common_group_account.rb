
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

# Ensure that the resource is applied regardless of whether we are in why_run
# or standard mode.
#
# Refer to chef/chef#4537 for this uncommon syntax
action_class do
  def whyrun_supported?
    true
  end
end

action :create do
  # Register this managed group to support deletions
  #
  node.set[:common_auth][:groups][:managed][name] = true

  if new_resource.require_members and not whyrun_mode?
    new_resource.members.each do |member|
      next if node[:etc][:passwd].keys.include?(member)
      raise ArgumentError.new "This group requires the presence of #{member}"
    end
  elsif whyrun_mode?
    Chef.run_context.events.whyrun_assumption(:create,
      new_resource,
      "would ensure presence of members: #{new_resource.members.join(", ")}"
    )
  end

  group name do
    gid gid
    members members
  end

  sudo name do
    common_properties(sudoer)
    group name unless sudoer.key?("group")
    action :nothing unless sudoer
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
