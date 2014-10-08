# coding: UTF-8
#
# Cookbook Name:: cerner_splunk
# Recipe:: _install
#
# Performs the installation of the Splunk software via package.

chef_gem 'chef-vault'

include_recipe 'cerner_splunk::_cleanup_aeon'

# Interpolation Alias
def nsp
  node[:splunk][:package]
end

# Attributes
node.default[:splunk][:package][:name] = "#{nsp[:base_name]}-#{nsp[:version]}-#{nsp[:build]}"
node.default[:splunk][:package][:file_name] = "#{nsp[:name]}#{nsp[:file_suffix]}"
node.default[:splunk][:package][:url] =
  "#{nsp[:base_url]}/#{nsp[:version]}/#{nsp[:download_group]}/#{nsp[:platform]}/#{nsp[:file_name]}"

node.default[:splunk][:home] = "/opt/#{nsp[:base_name]}"
node.default[:splunk][:cmd] = "#{node[:splunk][:home]}/bin/splunk"

manifest_missing = proc { ::Dir.glob("#{node[:splunk][:home]}/#{node[:splunk][:package][:name]}-*").empty? }

# Actions
service 'splunk' do
  action :nothing
  supports status: true, start: true, stop: true, restart: true
end

splunk_file = "#{Chef::Config[:file_cache_path]}/#{node[:splunk][:package][:file_name]}"

remote_file splunk_file do
  source node[:splunk][:package][:url]
  action :create
  only_if(&manifest_missing)
end

package node[:splunk][:package][:name] do
  source splunk_file
  provider node[:splunk][:package][:provider]
  only_if(&manifest_missing)
  notifies :run, 'execute[splunk-first-run]', :immediately
end

file 'splunk_package' do
  path splunk_file
  backup false
  not_if(&manifest_missing)
  action :delete
end

include_recipe 'cerner_splunk::_user_management'

execute 'splunk-first-run' do
  command "#{node[:splunk][:cmd]} help --accept-license --answer-yes --no-prompt"
  user node[:splunk][:user]
  group node[:splunk][:group]
  action :nothing
end

# This gets rid of the change password prompt on first login
file "#{node[:splunk][:home]}/etc/.ui_login" do
  action :nothing
  subscribes :touch, 'execute[splunk-first-run]', :immediately
end

# System file changes should be done after first run, but before we start the server
include_recipe 'cerner_splunk::_configure'
