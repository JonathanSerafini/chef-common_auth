
require 'secure_data_bag'

namespaces = node[:common][:environments][:active]

# Enqueue user and group items to manage
# - managed: items that were managed during a previous run
# - config: items that _may_ be managed during this run
#
user_queue = [
  node[:common][:auth][:users][:managed],
  node[:common][:auth][:users][:config].keys
].flatten.compact.uniq

group_queue = [
  node[:common][:auth][:groups][:managed],
  node[:common][:auth][:groups][:config].keys
].flatten.compact.uniq

# Fetch group data_bag items
#
groups = search(node[:common][:auth][:groups][:data_bag], "id:*").map do |item|
  # Apply databag namespace if present
  #
  item = item.common_namespaced(namespaces)
  item_name = item["name"] || item["id"]

  # Apply attribute override if present
  #
  override = node[:common][:auth][:groups][:config].fetch(item_name, {})
  item = Chef::Mixin::DeepMerge.merge(item, override)

  # Ensure that this item is present in group_queue
  #
  next if not group_queue.include?(item["name"]) and
          not group_queue.include?(item["id"])

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
users = search(node[:common][:auth][:users][:data_bag], "id:*").map do |item|
  # Apply databag namespace if present
  #
  item = SecureDataBag::Item.from_item item
  item = item.common_namespaced(namespaces)
  item_name = item["name"] || item["id"]

  # Apply attribute override if present
  #
  override =  node[:common][:auth][:users][:config].fetch(item_name, {})
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
  user_account item["name"] || item["id"] do
    load_properties(item)
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
  group_account item["name"] || item["id"] do
    load_properties(item)
  end
end

