
resource_name :common_user_keys

property :owner,
  kind_of:  String,
  identity: true

property :group,
  kind_of:  String,
  identity: true,
  default:  lazy { |r| r.owner }

property :home,
  kind_of:  String,
  identity: true,
  default:  lazy { |r| "/home/#{r.name}" }

property :public_keys,
  kind_of: Hash,
  default: Hash.new,
  coerce:  proc { |value| Common::Delegator::ObfuscatedType.new(value) }

property :private_keys,
  kind_of: Hash,
  default: Hash.new,
  coerce:  proc { |value| Common::Delegator::ObfuscatedType.new(value) }

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
  directory "#{new_resource.home}/.ssh" do
    owner new_resource.owner
    group new_resource.group
    mode  0700
    recursive true
  end

  template "#{new_resource.home}/.ssh/authorized_keys2" do
    owner new_resource.owner
    group new_resource.group
    mode  0600
    sensitive true
    variables(
      public_keys: new_resource.public_keys
    )
  end

  new_resource.private_keys.each do |name, key|
    file "#{new_resource.home}/.ssh/#{name}.rsa" do
      owner new_resource.owner
      group new_resource.group
      mode  0600
      sensitive true
      content key.to_s
    end

    file "#{new_resource.home}/.ssh/#{name}.cmd" do
      owner new_resource.owner
      group new_resource.group
      mode  0700
      content "#!/bin/sh
        exec /usr/bin/ssh \\
          -i #{new_resource.home}/.ssh/#{name}.rsa \\
          -o \"StrictHostKeyChecking=no\" \\
          \"$@\"
      "
    end
  end
end

action :delete do
  template "#{new_resource.home}/.ssh/authorized_keys2" do
    action :delete
  end

  new_resource.private_keys.keys.each do |name|
    file "#{new_resource.home}/.ssh/#{name}.rsa" do
      action :delete
    end

    file "#{new_resource.home}/.ssh/#{name}.cmd" do
      action :delete
    end
  end
end
