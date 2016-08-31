module CommonAuth
  # Recipe DSL methods providing the business logic surrounding how user and 
  # group resources are instatiated based on node attributes and data_bag_item
  # @since 0.3.0
  module DSL
    #
    # Groups
    #

    # Cache of common_auth_group resource properties
    # @return [Hash] groups that should be defined during the Chef run
    # @since 0.3.0
    def common_auth_groups_state
      node.run_state[:common_auth_groups_state] ||= {}
    end

    # Getter/Setter for a single group in common_auth_group_state
    # @param name [String] the name of the group
    # @param group [Hash,Nil] the optional group to merge with any previous
    #   data already defined
    # @param override [Bool] a boolean defining whether the supplied group
    #   should be used as the default or overrides when merging
    # @return [Hash] the resulting group properties hash
    # @since 0.3.0
    def common_auth_group_state(name, group = nil, override = true)
      original_group = common_auth_groups_state.fetch(name, {})
      if group.nil? then original_group
      else
        items = override ? [original_group, group] : [group, original_group]
        common_auth_groups_state[name] = Chef::Mixin::DeepMerge.merge(*items)
      end
    end

    # Update common_auth_groups_state hashes with groups which had been managed
    # during previous Chef runs. These groups will have their actions default
    # to _false_ which is a special internal action used to delete groups
    # which have been removed from future management.
    # @since 0.3.0
    def load_common_auth_groups_managed
      node['common_auth']['groups']['managed'].each do |name, bool|
        group = common_auth_group_state(name, {})

        if group['action'].nil?
          Chef::Log.debug("common_auth group[#{name}] " \
                          "loaded with default action false")
          group['action'] = false
        end
      end
    end

    # Update common_auth_groups_state hashes with groups which have been 
    # defined in node attributes with optional overrides. If no action is
    # defined in the optioal overrides, they will default to _true_ which is a
    # special internal action used to create groups.
    # @since 0.3.0
    def load_common_auth_groups_requested
      node['common_auth']['groups']['config'].each do |name, override|
        group = common_auth_group_state(name, override)
        case group['action']
        when String
          Chef::Log.debug("common_auth group[#{name}] " \
                          "loaded override with action #{group['action']}")
        when nil, false
          group['action'] = true
          Chef::Log.debug("common_auth group[#{name}] " \
                          "loaded override with default action true")
        end
      end
    end

    # Update common_auth_groups_state hashes with data from data_bag_items. The
    # groups which will be loaded are those that have been defined either in
    # _managed or _requested and the values will be used as defaults.
    # @since 0.3.0
    def load_common_auth_groups_items
      query = [
        "id:(#{common_auth_groups_state.keys.join(' OR ')})",
        "name:(#{common_auth_groups_state.keys.join(' OR ')})",
      ].join(' OR ')

      search(node['common_auth']['groups']['data_bag'], query).each do |item|
        item = SecureDataBag::Item.from_item(item)
        data = item.to_common_namespace
        name = data['name'] || item.id
        group = common_auth_group_state(name, data, false)
        if data['action'] == String and not group['action'] == String
          Chef::Log.debug("common_auth group[#{name}] " \
                          "loaded with item action #{data['action']}")
          group['action'] = data['action']
        end
      end
    end

    # Update common_auth_groups_state hashes to ensure that we convert any
    # default or missing actions to their respective values.
    # @since 0.3.0
    def load_common_auth_groups_actions
      common_auth_groups_state.each do |name, group|
        case group['action']
        when nil
          Chef::Log.debug("common_auth group[#{name}] " \
                          "converting missing action to remove")
          group['action'] = 'remove'
        when false
          Chef::Log.debug("common_auth group[#{name}] " \
                          "converting default action false to remove")
          group['action'] = 'remove'
        when true
          Chef::Log.debug("common_auth group[#{name}] " \
                          "converting default action true to nothing")
          group['action'] = 'nothing'
        end
      end
    end

    # Update common_auth_groups_state hashes from all sources
    # @since 0.3.0
    def load_common_auth_groups
      load_common_auth_groups_managed
      load_common_auth_groups_requested
      load_common_auth_groups_items
      load_common_auth_groups_actions
    end

    #
    # Users
    #

    # Cache of common_auth_user resource properties
    # @return [Hash] users that should be defined during the Chef run
    # @since 0.3.0
    def common_auth_users_state
      node.run_state[:common_auth_users_state] ||= {}
    end

    # Getter/Setter for a single user in common_auth_user_state
    # @param name [String] the name of the user
    # @param user [Hash,Nil] the optional user to merge with any previous
    #   data already defined
    # @param override [Bool] a boolean defining whether the supplied user
    #   should be used as the default or overrides when merging
    # @return [Hash] the resulting user properties hash
    # @since 0.3.0
    def common_auth_user_state(name, user = nil, override = true)
      original_user = common_auth_users_state.fetch(name, {})
      if user.nil? then original_user
      else
        items = override ? [original_user, user] : [user, original_user]
        common_auth_users_state[name] = Chef::Mixin::DeepMerge.merge(*items)
      end
    end

    # Update common_auth_users_state hashes with users which had been managed
    # during previous Chef runs. These users will have their actions default
    # to _false_ which is a special internal action used to delete users
    # which have been removed from future management.
    # @since 0.3.0
    def load_common_auth_users_managed
      node['common_auth']['users']['managed'].each do |name, bool|
        user = common_auth_user_state(name, {})

        if user['action'].nil?
          Chef::Log.debug("common_auth user[#{name}] " \
                          "loaded with default action false")
          user['action'] = false
        end
      end
    end

    # Update common_auth_users_state hashes with users which have been defined
    # as begin members included by existing groups. If all of the groups which
    # would add the user are to be deleted, then so should the user. If any
    # of the groups which would add the user would also be created, then the
    # user will be managed.
    # @since 0.3.0
    def load_common_auth_users_from_groups
      common_auth_groups_state.each do |group_name, group|
        next unless group['include_members']
        next if group['members'].empty?

        group['members'].each do |name|
          user = common_auth_user_state(name, {})

          unless user['action'] == String
            unless group['action'] == 'remove'
              Chef::Log.debug("common_auth user[#{name}] " \
                              "loaded from group membership with action true")
              user['action'] = true
            end

            if user['action'].nil?
              Chef::Log.debug("common_auth user[#{name}] " \
                              "loaded from group membership " \
                              "with default action false")
              user['action'] = false
            end
          end
        end
      end
    end

    # Update common_auth_users_state hashes with users who's data_bag_items
    # contain a _memberships_ array field, containing a group which would be
    # created on this server. 
    # @since 0.3.0
    def load_common_auth_users_from_memberships
      return unless node['common_auth']['users']['search_user_memberships']
      return unless common_auth_groups_state.keys.any?

      groups = common_auth_groups_state
        .select { |_,group| group['action'] == 'create' }
        .keys

      query = "memberships:(#{groups.join(' OR ')})"
      config = {
        filter_result: {
          id: ['id'],
          name: ['name']
        }
      }

      search(node['common_auth']['users']['data_bag'], query, **config)
        .each do |item|
          name = item['name'] || item['id']
          user = common_auth_user_state(name, {})

          if [nil, false].include?(user['action'])
            Chef::Log.debug("common_auth user[#{name}] " \
                            "loaded from user membership " \
                            "with default action true")
            user['action'] = true
          end
        end
    end

    # Update common_auth_users_state hashes with users which have been 
    # defined in node attributes with optional overrides. If no action is
    # defined in the optioal overrides, they will default to _true_ which is a
    # special internal action used to create users.
    # @since 0.3.0
    def load_common_auth_users_requested
      node['common_auth']['users']['config'].each do |name, override|
        user = common_auth_user_state(name, override)
        case user['action']
        when String
          Chef::Log.debug("common_auth user[#{name}] " \
                          "loaded override with action #{user['action']}")
        when nil, false
          user['action'] = true
          Chef::Log.debug("common_auth user[#{name}] " \
                          "loaded override with default action true")
        end
      end
    end

    # Update common_auth_users_state hashes with data from data_bag_items. The
    # users which will be loaded are those that have been defined either in
    # _managed or _requested and the values will be used as defaults.
    # @since 0.3.0
    def load_common_auth_users_items
      return unless common_auth_users_state.keys.any?

      query = [
        "id:(#{common_auth_users_state.keys.join(' OR ')})",
        "name:(#{common_auth_users_state.keys.join(' OR ')})",
      ].join(' OR ')

      search(node['common_auth']['users']['data_bag'], query).each do |item|
        item = SecureDataBag::Item.from_item(item)
        data = item.to_common_namespace
        name = data['name'] || item.id
        user = common_auth_user_state(name, data, false)
        if data['action'] == String and not user['action'] == String
          Chef::Log.debug("common_auth user[#{name}] " \
                          "loaded with item action #{data['action']}")
          user['action'] = data['action']
        end
      end
    end

    # Update common_auth_users_state hashes to ensure that we convert any
    # default or missing actions to their respective values.
    # @since 0.3.0
    def load_common_auth_users_actions
      common_auth_users_state.each do |name, user|
        case user['action']
        when nil
          Chef::Log.debug("common_auth user[#{name}] " \
                          "converting missing action to remove")
          user['action'] = 'remove'
        when false
          Chef::Log.debug("common_auth user[#{name}] " \
                          "converting default action false to remove")
          user['action'] = 'remove'
        when true
          Chef::Log.debug("common_auth user[#{name}] " \
                          "converting default action true to create")
          user['action'] = 'create'
        end
      end
    end

    # Update common_auth_users_state hashes from all sources
    # @since 0.3.0
    def load_common_auth_users
      load_common_auth_users_managed
      load_common_auth_users_from_groups
      load_common_auth_users_from_memberships
      load_common_auth_users_requested
      load_common_auth_users_items
      load_common_auth_users_actions
    end

    #
    # Shared
    #
    def common_auth_clear_cache
      %w(
        common_auth_groups_state
        common_auth_users_state
      ).each { |k| node.run_state.delete(k.to_sym) }
    end
  end
end
