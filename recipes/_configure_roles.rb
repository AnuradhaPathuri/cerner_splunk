
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Recipe:: _configure_roles
#
# Configures the roles available on the system

hash = CernerSplunk::DataBag.load node['splunk']['config']['roles'], pick_context: CernerSplunk.keys(node)

unless hash
  Chef::Log.info 'Roles not configured for this node.'
  return
end

# TODO: Let's avoid this pattern in the future
authorize, user_prefs = CernerSplunk::Roles.configure_roles(hash)

splunk_conf 'system/authorize.conf' do
  config authorize
  action :configure # Only configure option for now # TODO: What does this mean
  notifies :desired_restart, "splunk_service[#{node['splunk']['package']['type']}]", :immediately
end

directory "#{node['splunk']['home']}/etc/apps/user-prefs/local" do
  user node['splunk']['user']
  group node['splunk']['group']
  mode '0700'
end

splunk_conf 'apps/user-prefs/user-prefs.conf' do
  config user_prefs
  action :configure # Only configure option for now
  notifies :desired_restart, "splunk_service[#{node['splunk']['package']['type']}]", :immediately
end
