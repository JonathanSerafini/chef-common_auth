
# Enqueue user and group items to manage
# - managed: items that were previously managed
# - config: items that are set to be managed 
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
groups = search(node[:common][:auth][:groups][:data_bag], "*").map do |item|
  item = item.namespaced(node[:common][:environments][:active])
  name = item["name"] || item["id"]
 
  if group_queue.include?(name)
    override =  node[:common][:auth][:groups][:config].fetch(name, {})
    override =  case override
                when Hash then override
                when TrueClass
                  { "action" => "create" }
                when FalseClass
                  { "action" => "remove" }
                end
    item = Chef::Mixin::DeepMerge.merge(item, override)
  else nil
  end
end.compact

# Enqueue user items provided by group_item members
#
groups.each do |item|
  user_queue.concat(item["members"])
end

user_queue.uniq!


# Fetch user data_bag items
#
users = search(node[:common][:auth][:users][:data_bag], "*").map do |item|
  item = item.namespaced(node[:common][:environments][:active])
  name = item["name"] || item["id"]
 
  if user_queue.include?(name)
    override =  node[:common][:auth][:users][:config].fetch(name, {})
    override =  case override
                when Hash then override
                when TrueClass
                  { "action" => "create" }
                when FalseClass
                  { "action" => "remove" }
                end
    item = Chef::Mixin::DeepMerge.merge(item, override)
  else nil
  end
end.compact

# Create user resources
#
users.each do |user|
  user_account item["name"] || item["id"] do
    load_properties(user)
  end
end

# Create group resources
#
groups.each do |group|
  group_account item["name"] || item["id"] do
    load_properties(group)
  end
end

