
resource_name :user_keys

property :owner,
  kind_of:  String,
  identity: true

property :group,
  kind_of:  String,
  identity: true,
  default: lazy { |r| r.owner }

property :home,
  kind_of:  String,
  identity: true,
  default:  lazy { |r| "/home/#{r.name}" }

property :public_keys,
  kind_of: Hash,
  default: Hash.new

property :private_keys,
  kind_of: Hash,
  default: Hash.new

action :create do
  directory "#{home}/.ssh" do
    owner owner
    group group
    mode  0700
  end

  template "#{home}/.ssh/authorized_keys2" do
    owner owner
    group group
    mode  0600
    variables(
      public_keys: public_keys
    )
  end

  private_keys.each do |name, key|
    file "#{home}/.ssh/#{name}.rsa" do
      owner owner
      group group
      mode  0600
      sensitive true
      content key
    end

    file "#{home}/.ssh/#{name}.cmd" do
      owner owner
      group group
      mode  0700
      content "#!/bin/sh exec \
        /usr/bin/ssh \
          -i #{home}/.ssh/#{name}.rsa 
          -o \"StrictHostKeyChecking=no\" \
          \"$@\"
      "
    end
  end
end

action :delete do
  template "#{home}/.ssh/authorized_keys2" do
    action :delete
  end

  private_keys.keys.each do |name|
    file "#{home}/.ssh/#{name}.rsa" do
      action :delete
    end

    file "#{home}/.ssh/#{name}.cmd" do
      action :delete
    end
  end
end
