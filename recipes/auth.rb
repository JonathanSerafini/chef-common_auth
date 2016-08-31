# Install the secure_data_bag gem
require 'secure_data_bag'

# Include common_auth business logic methods
send(:extend, CommonAuth::DSL)

load_common_auth_groups
load_common_auth_users

# Create user resources
#
common_auth_users_state.each do |name, item|
  common_user_account name do
    common_properties(item)
  end
end

# Reload the ohai::passwd to ensure groups can inspect properly
#
ohai "redetect /etc/passwd" do
  name "passwd"
  action :reload
end

# Create group resources
#
common_auth_groups_state.each do |name, item|
  common_group_account name do
    common_properties(item)
  end
end

# Cleanup run_state
#
common_auth_clear_cache
