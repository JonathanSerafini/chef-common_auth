# Install the secure_data_bag gem
require 'secure_data_bag'

# Enqueue user and group items to manage
# - managed: items that were managed during a previous run
# - config: items that _may_ be managed during this run
#
user_queue = [
  node[:common_auth][:users][:managed],
  node[:common_auth][:users][:config].keys
].flatten.compact.uniq

group_queue = [
  node[:common_auth][:groups][:managed],
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

  # Ensure that this item is present in group_queue
  #
  next if not group_queue.include?(item_name)

  # Set default action to :nothing if no action provided
  # - Perhaps this is only used to generate a list of users
  item["action"] ||= "nothing"

  # Enqueue group members 
  #
  if item["include_members"]
    user_queue.concat(Array(item["members"]))
    user_queue.uniq!
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
  override =  node[:common_auth][:users][:config].fetch(item_name, {})
  item = Chef::Mixin::DeepMerge.merge(item, override)

  # Ensure that this item is present in user_queue
  #
  next if not user_queue.include?(item["name"]) and
          not user_queue.include?(item["id"])

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
