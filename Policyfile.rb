
name "common_auth"
default_source :supermarket

default[:common_auth][:groups][:config][:devops] = true

default[:common_auth].tap do |config|
  config[:sudoers][:ubuntu].tap do |sudoer|
    sudoer[:user] = "ubuntu"
    sudoer[:runas] = "root"
    sudoer[:nopasswd] = true
  end

  config[:sudoers][:deploy].tap do |sudoer|
    sudoer[:group] = "deploy"
    sudoer[:runas] = "root"
    sudoer[:nopasswd] = true
    sudoer[:commands] = ["/usr/bin/chef-client"]
  end

  config[:sudoers]["90-cloud-init-users"].tap do |sudoer|
    sudoer[:action] = "remove"
  end
end

default[:authorization][:sudo][:groups] = %w(devops)
default[:openssh][:server][:allow_groups] = %w(devops deploy)

run_list "common_auth::default"
cookbook "common_auth", path: "."
cookbook "common_linux", path: "../common_linux"
cookbook "common_attrs", path: "../common_attrs"
cookbook "rsyslog_ng", path: "../rsyslog_ng"
