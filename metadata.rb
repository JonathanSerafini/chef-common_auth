name 'common_auth'
maintainer 'Jonathan Serafini'
maintainer_email 'jonathan@serafini.ca'
issues_url 'https://github.com/JonathanSerafini/chef-common_auth/issues'
source_url 'https://github.com/JonathanSerafini/chef-common_auth'
license 'apachev2'
description 'Resources to help manage Linux users, groups, sudo and openssh'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
chef_version '>= 12.7'
version '0.1.9'

gem 'secure_data_bag'   # Support more data_bag_item formats

depends 'common_attrs'  '~> 0.4.0'
depends 'sudo',         '~> 2.9.0'
depends 'openssh',      '~> 2.0.0'
