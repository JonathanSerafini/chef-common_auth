
include_recipe "sudo::default"

node[:common_auth][:sudoers].each do |name, hash|
  sudo name do
    common_properties(hash)
  end
end


