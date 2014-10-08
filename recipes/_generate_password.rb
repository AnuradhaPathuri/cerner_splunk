# coding: UTF-8
#
# Cookbook Name:: cerner_splunk
# Recipe:: _generate_password
#
# Generates and sets a random password for the admin splunk account.
# This recipe must be run while Splunk is running.

return if node[:splunk][:free_license] && node[:splunk][:node_type] != :forwarder

require 'securerandom'

password_file = File.join node[:splunk][:external_config_directory], 'password'

old_password = File.exist?(password_file) ? File.read(password_file) : 'changeme'
new_password = SecureRandom.hex(36)

execute 'change-admin-password' do
  command "#{node[:splunk][:cmd]} edit user admin -password #{new_password} -roles admin -auth admin:#{old_password}"
end

file password_file do
  backup false
  owner 'root'
  group 'root'
  mode '0600'
  content new_password
end
