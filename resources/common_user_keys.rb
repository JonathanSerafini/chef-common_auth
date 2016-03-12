
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

action :create do
  directory "#{new_resource.home}/.ssh" do
    owner new_resource.owner
    group new_resource.group
    mode  0700
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

  private_keys.each do |name, key|
    file "#{new_resource.home}/.ssh/#{new_resource.name}.rsa" do
      owner new_resource.owner
      group new_resource.group
      mode  0600
      sensitive true
      content new_resource.key
    end

    file "#{new_resource.home}/.ssh/#{new_resource.name}.cmd" do
      owner new_resource.owner
      group new_resource.group
      mode  0700
      content "#!/bin/sh exec \
        /usr/bin/ssh \
          -i #{new_resource.home}/.ssh/#{new_resource.name}.rsa 
          -o \"StrictHostKeyChecking=no\" \
          \"$@\"
      "
    end
  end
end

action :delete do
  template "#{new_resource.home}/.ssh/authorized_keys2" do
    action :delete
  end

  private_keys.keys.each do |name|
    file "#{new_resource.home}/.ssh/#{new_resource.name}.rsa" do
      action :delete
    end

    file "#{new_resource.home}/.ssh/#{new_resource.name}.cmd" do
      action :delete
    end
  end
end
