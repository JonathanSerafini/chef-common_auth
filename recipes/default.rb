
# Ensure common_linux runs firs so as to install required packages
include_recipe "common_linux::default"

include_recipe "#{cookbook_name}::auth"
include_recipe "#{cookbook_name}::sudo"
include_recipe "#{cookbook_name}::openssh"

