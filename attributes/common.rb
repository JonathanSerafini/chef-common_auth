
# Namespace for sudoers lwrp attribute definitions
#
default[:common][:sudoers] ||= {}

# Dependency
#
default[:common][:chef_gems][:secure_data_bag] = {
  compile_time: true
}

