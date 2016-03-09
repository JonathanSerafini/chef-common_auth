 
# Hash of AllowGroup directives for openssh which will override what is
# currently defined in the openssh namespace.
#
default[:common_auth][:openssh][:allow_groups] ||= {}

if ::File.exists?("/dev/vagrant-vg")
  Chef::Log.info "granting vagrant ssh access"
  default[:common_auth][:openssh][:allow_groups][:vagrant] = true
end

# Hash of Group matchers which will override what is currently defined in the
# openssh namespace
#
default[:common_auth][:openssh][:match_groups] ||= {}

