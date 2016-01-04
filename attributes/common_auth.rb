
#
# Users
#

# Data bag to fetch users definitions from
#
default[:common][:auth][:users][:data_bag] = "users"

# Hash containing a list of managed users overrides
#
default[:common][:auth][:users][:config] = Mash.new

# Array containing a list of managed users
# ** This should never be manually modified
#
default[:common][:auth][:users][:managed] = Array.new

# Default settings for users
#
default[:common][:auth][:users][:defaults][:home] = "/home"
default[:common][:auth][:users][:defaults][:shell] = "/bin/false"

#
# Groups
#

# Data bag to fetch groups definitions from
#
default[:common][:auth][:groups][:data_bag] = "groups"

# Hash containing a list of managed groups overrides
#
default[:common][:auth][:groups][:config] = Mash.new

# Array containing a list of managed groups
# ** This should never be manually modified
#
default[:common][:auth][:groups][:managed] = Array.new

