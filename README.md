# common_auth cookbook

A cookbook which attempts to simulate group based policies in a Chef/Linux environment by allowing you to define groups of users to install on the machine. Additionally, the recipes and custom resources will manage both sudoers and openssh. 

# Requiremetns

* Chef **12.7.0** or later.

# Platform

* Ubuntu

# Attributes / Data Bags

The goal of this cookbook is to manage authentication related resources through a mixture of node attributes and data\_bag\_item, with node attributes taking precedence over the contents of a data\_bag\_item.

### common\_auth.groups

This namespace contains directives which relate to the group management on the system. With this cookbook, groups are typically used as the first class citizens who determine which users are added.

- *data_bag*: The data\_bag in which group items are stored.
- *config*: A hash of groups which should be added.
- *managed*: A hash of groups which were added during a previous Chef run. 

##### common\_auth.groups.config

This hash represents the groups which should be managed during the Chef run. The _key_ represents the group's name and the value is a hash containing optional `common_group_account` properties which should supplement or override those found within the data\_bag\_item with a similar name.

In addition to the standard resource properties supported, a special key if `include_members` is supported which indicates that any members of this group should be added as users needing to be managed during the chef run.

If no _action_ is defined in the properties, and no _action_ is defined in the data\_bag\_item, then the _action_ will default to `:nothing`.

```json
{
  "common_auth": {
    "groups": {
      "config": {
        "sysadmins": {
          "members": ["user1", "user2"],
          "include_members": true
        }
      }
    }
  }
}
```

##### common\_auth.groups.managed

This hash represents the groups which would managed during a previous Chef run. The _key_ represents the group name and the value is a boolean indicating whether the user existed or was removed by the last action.

When a `common_group_account` resource executes it's action, it will automatically ensure that it logs it's last action to this hash. Additionally, when deleting, if the attribute's boolean value had been set to false during the previous Chef run, then it will be deleted from the hash. 

*NOTE*: This hash should _not_ be modified manually. 

##### Config Hash / DataBagItem format

The format of the data\_bag\_item follows that of of the [common_group_account](resources/common_group_account.rb) custom resource. With the inclusing of the _include_members_ key which is used outside of the custom resource. 

Additionally, through functionally provided by [common_attrs](https://github.com/JonathanSerafini/chef-common_attrs), these data_bag_items may contain optional namespaces.

```json
{
  "id": "group_1",
  "name": "group1",
  "gid": 1234,
  "members": ["user1","user2"],
  "require_members": true,
  "include_members": true,
  "sudoer": {
    "runas": "root",
    "nopasswd": false
  },
  "_production": {
    "members": ["superuser"]
  },
  "_staging": {
    "members": ["user1","user2"]
  },
  "action": "create"
}
```

### common_auth.users

This namespace contains directives which relate to the user management on the system. Although individual members may be referened for inclusion with these attributes, they should generally be pulled in via their group memberships.

- *data_bag*: The data\_bag in which user items are stored.
- *config*: A hash of users which should be added.
- *managed*: A hash of users which were added during a previous Chef run. 
- *defaults*: A hash of default values which should be used for all users.
- *search\_user\_memberships*: A boolean determining whether the recipe DSL should lookup the _memberships_ key in user data\_bag\_items when loading users.

##### common\_auth.users.config

This hash represents the users which should be managed during the Chef run. The _key_ represents the user's name and the value is a hash containing optional `common_user_account` properties which should supplement or override those found within the data\_bag\_item with a similar name.

If no _action_ is defined in the properties, and no _action_ is defined in the data\_bag\_item, then the _action_ will default to `:create`.

##### common\_auth.users.managed

This hash represents the users which would managed during a previous Chef run. The _key_ represents the user name and the value is a boolean indicating whether the user existed or was removed by the last action.

When a `common_user_account` resource executes it's action, it will automatically ensure that it logs it's last action to this hash. Additionally, when deleting, if the attribute's boolean value had been set to false during the previous Chef run, then it will be deleted from the hash. 

*NOTE*: This hash should _not_ be modified manually. 

##### common\_auth.users.search\_user\_memberships

This boolean configures the DSL methods so that an additional search is perfromed against the _common\_auth.users.data_bag_ looking for users whom have a _memberships_ array value which contains a group which would be created during the Chef run. 

This is effectively similar to adding a `members` item on a group object, and allows you to define group memberships as part of the user definition instead of the group's. When dealing with users part of many groups, it may provide for a better workflow.

It is, however, important to note that this option may _not_ be used in conjuction with EncryptedDataBagItem since this would cause the _memberships_ property to be encrypted. Instead, it is recommended that [SecureDataBagItem](https://github.com/JonathanSerafini/chef-secure_data_bag) be used to selectively encrypt only those fields which contain private content.

##### Config Hash / DataBagItem format

The format of the data\_bag\_item follows that of of the [common_user_account](resources/common_user_account.rb) custom resource. With the inclusing of the _memberships_ optional key which is used outside of the custom resource. 

Additionally, through functionally provided by [common_attrs](https://github.com/JonathanSerafini/chef-common_attrs), these data_bag_items may contain optional namespaces.

```json
{
  "id": "user.1",
  "name": "user1",
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

### common\_auth.sudoers

A Hash containing sudoers definitions which will drive the creation of `sudo` LWRP entries.

This is empty by default, except when the cookbook detects that it is being run inside of Vagrant, where the Vagrant user will be granted access.

### common\_auth.openssh.allow\_groups

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

### common\_auth.openssh.match\_groups

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

### common\_user\_account

Resource which will be responsible for creating a `user` resource and optionally a `common_user_keys` resource. Additionally, the creation or deletion of these attributes will be stored in `node` attributes to ensure that users are deleted if ommitted from configuration.

### common\_user\_keys

Resource which will manage a user's ssh public authorized\_keys, ssh private rsa keys and will automatically create an ssh\_wrapper script for each private key.

### common\_group\_account

Resource which will be responsible for creating a `group` resource and optinially a `sudoers` resource.

# Recipes

### common\_auth::auth

This recipe will generate user and group resources based on attributes.

### common\_auth:openssh

This recipe will call the opeenssh cookbook to manage this service.

### common\_auth::sudoers

This recipe will generate sudo LWRP instances based on attributes.
