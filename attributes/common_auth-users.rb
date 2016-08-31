
# Data bag to fetch users definitions from
#
default[:common_auth][:users][:data_bag] = "auth_users"

# Hash containing a list of managed users overrides
#
default[:common_auth][:users][:config] = Mash.new

# Mash containing a list of managed users
# ** This should never be manually modified
#
default[:common_auth][:users][:managed] = Mash.new

# Default settings for users
#
default[:common_auth][:users][:defaults][:home] = "/home"
default[:common_auth][:users][:defaults][:shell] = "/bin/false"

# Boolean determining whether we should search user data_bag_items for 
# membership array attributes when compiling a list of user data_bag_items 
# to load. This will effectively add an additional data_bag search to compile
# the list prior to fetching the items.
# @since 0.3.0
default[:common_auth][:users][:search_user_memberships] = false
