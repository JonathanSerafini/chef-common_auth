# common_auth

A cookbook designed to apply users to machines by using a "group policy" sort of approach.

# Requiremetns

This cookbook requires *Chef 12.5.0* or later.

# Platform

Ubuntu / AWS

# Attributes

- `common.auth.users.data_bag`: a data_bag containing encrypted data_bag_items for user_account resources. 
- `common.auth.users.config`: a Hash containing `user_account` resource definitions or override values.
- `common.auth.users.managed`: an Array of `user_account` names which are currently being managed on this node. As long as a `user_account` existed either at the beginning or the end of the chef run, the user will be listed in the Array. This Array is managed internally and *should not be editied* manually.
- `common.auth.users.defaults`: default properties to apply to all user_account resources.

- `common.auth.groups.data_bag`: a data_bag containing plain-text data_bag_items for group_account resources.
- `common.auth.groups.config`: a Hash containing `group_account` resource definitions or override values.
- `common.auth.groups.managed`: an Array of `group_account` names which are currently beging managed on this node. 

- `common.sudoers`: a Hash containing `sudo` resource definitions.

# Resources

## user_account

A system / shell user account which wraps around the `user` builtin resource.

## user_keys

A resource designed to create ssh public_keys, private_keys as well as ssh command wrappers.

## group_account

A system / shell group account which wraps around the `group` builtin resource.

# TODO

- better integration of openssh AllowGroups

