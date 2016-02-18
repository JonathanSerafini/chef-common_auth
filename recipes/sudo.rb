
include_recipe "sudo::default"

node[:common_auth][:sudoers].each do |name, hash|
  sudo name do
    load_properties(hash)
  end
end


