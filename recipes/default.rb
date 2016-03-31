
# Ensure common_linux runs firs so as to install required packages
chef_gem "secure_data_bag" do
  compile_time true
end

include_recipe "#{cookbook_name}::auth"
include_recipe "#{cookbook_name}::sudo"
include_recipe "#{cookbook_name}::openssh"

