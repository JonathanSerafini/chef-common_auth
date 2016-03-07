 
# Hash of AllowGroup directives for openssh which will override what is
# currently defined in the openssh namespace.
#
default[:common_auth][:openssh][:allow_groups] ||= {}

# Hash of Group matchers which will override what is currently defined in the
# openssh namespace
#
default[:common_auth][:openssh][:match_groups] ||= {}

