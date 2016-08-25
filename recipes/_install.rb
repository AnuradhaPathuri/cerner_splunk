# coding: UTF-8
#
# Cookbook Name:: cerner_splunk
# Recipe:: _install
#
# Performs the installation of the Splunk software via package.

include_recipe 'chef-vault::default'

include_recipe 'cerner_splunk::_cleanup_aeon'

# Interpolation Alias
def nsp
  node['splunk']['package']
end

# Attributes
node.default['splunk']['package']['name'] = "#{nsp['base_name']}-#{nsp['version']}-#{nsp['build']}"
node.default['splunk']['package']['file_name'] = "#{nsp['name']}#{nsp['file_suffix']}"
node.default['splunk']['package']['url'] =
  "#{nsp['base_url']}/#{nsp['download_group']}/releases/#{nsp['version']}/#{nsp['platform']}/#{nsp['file_name']}"
node.default['splunk']['home'] = CernerSplunk.splunk_home(node['platform_family'], node['kernel']['machine'], nsp['base_name'])
node.default['splunk']['cmd'] = CernerSplunk.splunk_command(node)

service = CernerSplunk.splunk_service_name(node['platform_family'], nsp['base_name'])

manifest_missing = proc { ::Dir.glob("#{node['splunk']['home']}/#{node['splunk']['package']['name']}-*").empty? }

include_recipe 'cerner_splunk::_restart_marker'

# Actions
# This service definition is used for ensuring splunk is started during the run and to stop splunk service
service 'splunk' do
  service_name service
  action :nothing
  supports status: true, start: true, stop: true
  notifies :delete, 'file[splunk-marker]', :immediately
end

# This service definition is used for restarting splunk when the run is over
service 'splunk-restart' do
  service_name service
  action :nothing
  supports status: true, restart: true
  only_if { ::File.exist? CernerSplunk.restart_marker_file }
  notifies :delete, 'file[splunk-marker]', :immediately
end

ruby_block 'splunk-delayed-restart' do
  block { true }
  notifies :restart, 'service[splunk-restart]'
end

splunk_file = "#{Chef::Config[:file_cache_path]}/#{node['splunk']['package']['file_name']}"


splunk_install 'splunk' do
  package node['splunk']['package']['type']
  version node['splunk']['package']['version']
  build node['splunk']['package']['build']
  user node['splunk']['user']
  base_url node['splunk']['package']['base_url']
end

include_recipe 'cerner_splunk::_configure_secret'

splunk_service 'splunk service' do
  package node['splunk']['package']['type']
  user node['splunk']['user']
  ulimit node['splunk']['limits']['open_files'].to_i
  action :init
end

ruby_block 'read splunk.secret' do
  block do
    node.run_state['cerner_splunk'] ||= {}
    node.run_state['cerner_splunk']['splunk.secret'] = ::File.open(::File.join(node['splunk']['home'], 'etc/auth/splunk.secret'), 'r') { |file| file.readline.chomp }
  end
end

ruby_block 'delayed restart' do
  block do
    CernerSplunk::Restart.ensure_restart
  end
  action :nothing
end

directory node['splunk']['external_config_directory'] do
  owner node['splunk']['user']
  group node['splunk']['group']
  mode '0700'
end

# SPL-89640 On upgrades, the permissions of this directory is too restrictive
# preventing proper operation of Platform Instrumentation features.
directory "#{node['splunk']['home']}/var/log/introspection" do
  owner node['splunk']['user']
  group node['splunk']['group']
  mode '0700'
end

include_recipe 'cerner_splunk::_user_management'

# This gets rid of the change password prompt on first login
file "#{node['splunk']['home']}/etc/.ui_login" do
  action :touch
  not_if { ::File.exist? "#{node['splunk']['home']}/etc/.ui_login" }
end

# System file changes should be done after first run, but before we start the server
include_recipe 'cerner_splunk::_configure'
