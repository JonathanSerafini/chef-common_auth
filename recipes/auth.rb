# Install the secure_data_bag gem
require 'secure_data_bag'

# Enqueue user and group items to manage
# - managed: items that were managed during a previous run
# - config: items that _may_ be managed during this run
#
users_requested = [
  node[:common_auth][:users][:config].keys
].flatten.compact.uniq

users_managed = [
  node[:common_auth][:users][:managed].keys,
  node[:common_auth][:users][:config].keys
].flatten.compact.uniq

groups_requested = [
  node[:common_auth][:groups][:config].keys
].flatten.compact.uniq

groups_managed = [
  node[:common_auth][:groups][:managed].keys,
  node[:common_auth][:groups][:config].keys
].flatten.compact.uniq

# Fetch group data_bag items
#
groups = search(node[:common_auth][:groups][:data_bag], "id:*").map do |item|
  # Apply databag namespace if present
  #
  item_name = item["name"] || item["id"]
  item = item.to_common_namespace
  item["name"] ||= item_name

  # Apply attribute override if present
  #
  override = node[:common_auth][:groups][:config].fetch(item_name, {})
  item = Chef::Mixin::DeepMerge.merge(item, override)

  # Ensure that this item is meant to be managed
  #
  next if not groups_managed.include?(item_name)

  # Ensure that strays are deleted
  #
  if not groups_requested.include?(item_name)
    item["action"] = "remove"
  end

  # Set default action to :nothing if no action provided
  # - Perhaps this is only used to generate a list of users
  item["action"] ||= "nothing"

  # Enqueue group members 
  #
  if item["include_members"]
    members = Array(item["members"])
    users_requested.concat(members)
    users_managed.concat(members)
  end

  # Return item
  #
  item
end.compact

# Fetch user data_bag items
#
users = search(node[:common_auth][:users][:data_bag], "id:*").map do |item|
  # Apply databag namespace if present
  #
  item = SecureDataBag::Item.from_item(item)
  item = item.to_common_namespace
  item_name = item["name"] || item["id"]

  # Apply attribute override if present
  #
  override = node[:common_auth][:users][:config].fetch(item_name, {})
  item = Chef::Mixin::DeepMerge.merge(item, override)

  # Ensure that this item is meant to be managed
  #
  next if not users_managed.include?(item_name)

  # Ensure that strays are deleted
  #
  if not users_requested.include?(item_name)
    item["action"] = "remove"
  end

  # Set default action to :nothing if no action provided
  #
  item["action"] ||= "nothing"

  # Return item
  #
  item
end.compact

# Create user resources
#
users.each do |item|
  common_user_account item["name"] || item["id"] do
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
groups.each do |item|
  common_group_account item["name"] || item["id"] do
    common_properties(item)
  end
end
