
# Data bag to fetch groups definitions from
#
default[:common_auth][:groups][:data_bag] = "auth_groups"

# Hash containing a list of managed groups overrides
#
default[:common_auth][:groups][:config] = Mash.new

# Mash containing a list of managed groups
# ** This should never be manually modified
#
default[:common_auth][:groups][:managed] = Mash.new

