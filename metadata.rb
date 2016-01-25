name 'common_auth'
maintainer 'Jonathan Serafini'
maintainer_email 'jonathan@serafini.ca'
license 'apachev2'
description 'Installs/Configures chef_common_auth'
long_description 'Installs/Configures chef_common_auth'
version '0.1.1'

#depends 'common_core'  # Install SecureBag gem
depends 'common_utils' # DataBagItem.common_namespaced support
depends 'sudo'
depends 'openssh'
