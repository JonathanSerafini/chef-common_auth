# common_auth cookbook

A cookbook which will create users, group, sudoers and configure openssh with the design to be based on group policies.

# Requiremetns

* Chef **12.7.0** or later.

# Platform

* Ubuntu

# Attributes / Data Bags

The goal of this cookbook is to manage authentication related resources through a mixture of node attributes and data_bag_item, with node attributes taking precedence over the contents of a data_bag_item.

### common_auth.groups

This namespace contains directives which will manage groups on a system as well as optionally populate a list of users to manage.

```json
{
  "id": "group1",
  "gid": 1234,
  "members": ["user1","user2"],
  "require_members": true,
  "include_members": true,
  "sudoer": {
    "runas": "root",
    "nopasswd": false
  },
  "action": "create"
}
```

###### common_auth.groups.data_bag

The data_bag from which to pull group definitions, which provide the bulk of a group's definitions.

Additionally, though functionally provided by [common_attrs](https://github.com/JonathanSerafini/chef-common_attrs), these data_bag_items may contain optional namespaces.

```json
{
  "id": "group1",
  "gid": 1234,
  "require_members": true,
  "include_members": true,
  "_production": {
    "members": ["superuser"]
  },
  "_staging": {
    "members": ["user1","user2"]
  }
}
```

###### common_auth.groups.config

A hash containing attribute level overrides for the data_bag_item contents. These can be useful when you wish to provide overrides from a Cookbook, PolicyFile, Role or Environment.

```json
{
  "config": {
    "group1": {
      "action": "delete"
    }
  }
}
```

###### common_auth.groups.managed

A hash containing a list of groups which should be managed on this machine. Each hash value may be either True symbolizing that this item should be managed or False, symbolizing that the group is safe to be deleted.

During the Chef run, the common_group_account LWRPs will update this Hash at the `node` precedence level, to ensure that the system keeps track of groups which had previously been managed during a Chef run and have since been deleted form the data_bag.

```json
{
  "managed": {
    "group1": true,
    "group2": false
  }
}
```

### common_auth.users

This namespace contains directives which will manage users on a system.

```json
{
  "id": "user1",
  "uid": 1234,
  "gid": 1234,
  "common": "Managed by Chef",
  "home": "/home/user1",
  "shell": "/bin/bash",
  "password": "$6...",
  "keys": {
    "public_keys": {
      "pubkey1": "SHA",
      "pubkey2": "SHA"
    },
    "private_keys": {
      "privkey1": "SHA"
    }
  },
  "action": "create"
}
```

###### common_auth.users.data_bag

The data_bag from which to pull user definitions, which provide the bulk of a user's definitions.

These items may be un-encrypted, encrypted or be partially encrypted with the [secure_data_bag](https://github.com/JonathanSerafini/chef-secure_data_bag) gem.

Additionally, though functionally provided by [common_attrs](https://github.com/JonathanSerafini/chef-common_attrs), these data_bag_items may contain optional namespaces.

```json
{
  "id": "user1",
  "_production": {
    "password": "$6prodpass"
  },
  "_staging": {
    "password": "$6stagpass"
  }
}
```

###### common_auth.users.config

A hash containing attribute level overrides for the data_bag_item contents. These can be useful when you wish to provide overrides from a Cookbook, PolicyFile, Role or Environment.

```json
{
  "config": {
    "user1": {
      "action": "delete"
    }
  }
}
```

###### common_auth.users.managed

A hash containing a list of users which should be managed on this machine. Each hash value may be either True symbolizing that this item should be managed or False, symbolizing that the group is safe to be deleted.

During the Chef run, the common_user_account LWRPs will update this Hash at the `node` precedence level, to ensure that the system keeps track of users which had previously been managed during a Chef run and have since been deleted form the data_bag.

```json
{
  "managed": {
    "user1": true,
    "user2": false
  }
}
```


### common_auth.sudoers

A Hash containing sudoers definitions which will drive the creation of `sudo` LWRP entries.

This is empty by default, except when the cookbook detects that it is being run inside of Vagrant, where the Vagrant user will be granted access.

### common_auth.openssh.allow_groups

Hash of OpenSSH AllowGroup directives that will override the standard OpenSSH cookbook attributes.

```json
{
  "allow_groups": {
    "group1": true,
    "group2": false
  }
}
```

This is empty by default, excpet when the cookbook detects that is is being run inside of Vagrant.

### common_auth.openssh.match_groups

Hash of OpenSSH Match group statements which will override the standard OpenSSH cookbook attributes.

```json
{
  "match_groups": {
    "group1": {
      "allow_tcp_forwarding": "yes"
    }
  }
}
```

*todo* : Ideally i'd like to move this into the group LWRP at some point.

# Resources

### common_user_account

Resource which will be responsible for creating a `user` resource and optionally a `common_user_keys` resource. Additionally, the creation or deletion of these attributes will be stored in `node` attributes to ensure that users are deleted if ommitted from configuration.

### common_user_keys

Resource which will manage a user's ssh public authorized_keys, ssh private rsa keys and will automatically create an ssh_wrapper script for each private key.

### common_group_account

Resource which will be responsible for creating a `group` resource and optinially a `sudoers` resource.

# Recipes

### common_auth::auth

This recipe will generate user and group resources based on attributes.

### common_auth:openssh

This recipe will call the opeenssh cookbook to manage this service.

### common_auth::sudoers

This recipe will generate sudo LWRP instances based on attributes.
