# common_auth cookbook

A cookbook which will create users, group, sudoers and configure openssh with the design to be based on group policies. 

# Requiremetns

This cookbook requires *Chef 12.7.0* or later.

# Platform

Ubuntu

# Document

Comments will be found throughout the attribute, resource and library files so that the documentation and code are more closely linked. What's found in this Readme will be more of a high-level overview.

# Attributes

The goal of this cookbook is to manage authentication related resources through a mixture of `node` attributes and `data_bag_item`. 

## common_auth[:groups]

- data_bag: The data bag which contains group definitions
- config: Hash of group_name => resource properties for attribute overrides
- managed: Hash of users which have previously been managed (managed attribute)

## common_auth[:users]

- data_bag: The data bag which contains user definitions
- config: Hash of user_name => resource properties for attribute overrides
- managed: Hash of users which have previously been managed (managed attribute)
- default: Hash of default user resource properties

## common_auth[:sudoers]

Hash containing suders resource definitions

## common_auth[:openssh][:allow_groups]

Hash of OpenSSH AllowGroup directives that will override the standard openssh cookbook attributes.

## common_auth[:openssh][:match_groups]

Hash of OpenSSH Match group statements

# Resources

### common_user_account

Resource which will be responsible for creating a `user` resource and optionally a `common_user_keys` resource. Additionally, the creation or deletion of these attributes will be stored in `node` attributes to ensure that users are deleted if ommitted from configuration.

### common_user_keys

Resource which will manage a user's ssh public authorized_keys, ssh private rsa keys and will automatically create an ssh_wrapper script for each private key.

### common_group_account

Resource which will be responsible for creating a `group` resource and optinially a `sudoers` resource.

# DataBag Formats

DataBagItem formats should match the resource definitions for both `user` with an optional `keys` property matching `common_user_keys` as well as `group` items.

