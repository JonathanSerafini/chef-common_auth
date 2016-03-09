
# Namespace for sudoers lwrp attribute definitions
#
default[:common_auth][:sudoers] ||= {}

if ::File.exists?("/dev/vagrant-vg")
  Chef::Log.info "granting vagrant sudo access"
  default[:common_auth][:sudoers][:vagrant][:nopasswd] = true
  default[:common_auth][:sudoers][:vagrant][:runas] = "root"
  default[:common_auth][:sudoers][:vagrant][:user] = "vagrant"
end


