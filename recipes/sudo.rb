
include_recipe "sudo::default"

node[:common][:sudoers].each do |name, hash|
  sudo name do
    load_properties(hash)
  end
end


