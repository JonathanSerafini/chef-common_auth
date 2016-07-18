
# Apply common namespaced attributes to openssh for sshd_config generation
#
node.normal[:openssh][:server][:allow_groups] = 
  node[:common_auth][:openssh][:allow_groups].map {|k,v| k if v}.compact

node[:common_auth][:openssh][:match_groups].each do |key, hash|
  node.normal[:openssh][:server][:match]["Group #{key}"] = hash
end

# Proceed with openssh installation
#
include_recipe "openssh::default"

