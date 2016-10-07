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
node.default['splunk']['home'] = CernerSplunk.splunk_home(node['platform_family'], node['kernel']['machine'], nsp['base_name'])
node.default['splunk']['cmd'] = CernerSplunk.splunk_command(node)

node.default['splunk']['package']['type'] =
  case nsp['base_name']
  when 'splunk'
    'splunk'
  when 'splunkforwarder'
    'universal_forwarder'
  end

include_recipe 'cerner_splunk::_restart_prep'

splunk_install 'splunk' do
  package node['splunk']['package']['type'].to_sym
  version node['splunk']['package']['version']
  build node['splunk']['package']['build']
  user node['splunk']['user']
  base_url node['splunk']['package']['base_url']
end

include_recipe 'cerner_splunk::_configure_secret'

# splunk_service node['splunk']['package']['type'] do # renamed because splunk_restart resource name has to match with that of splunk_match
#   package node['splunk']['package']['type'].to_sym
#   user node['splunk']['user']
#   supports ensure: true, check: true, clear: true
#   action :nothing
# end


splunk_service node['splunk']['package']['type'] do # renamed because splunk_restart resource name has to match with that of splunk_match
  package node['splunk']['package']['type'].to_sym
  user node['splunk']['user']
  ulimit node['splunk']['limits']['open_files'].to_i unless node['platform_family'] == 'windows'
  action :init
  notifies :run, 'ruby_block[read splunk.secret]', :immediately
end

splunk_restart node['splunk']['package']['type'] do
  package node['splunk']['package']['type'].to_sym # I think Chefspec is not playing nice with symbols
  supports ensure: true, check: true, clear: true
  action :nothing
end

# execute 'splunk-first-run' do
#   command "#{node['splunk']['cmd']} help commands --accept-license --answer-yes --no-prompt"
#   user node['splunk']['user']
#   group node['splunk']['group']
#   only_if { ::File.exist? "#{node['splunk']['home']}/ftr" }
#   action :nothing
# end

ruby_block 'read splunk.secret' do
  block do
    node.run_state['cerner_splunk'] ||= {}
    node.run_state['cerner_splunk']['splunk.secret'] = ::File.open(::File.join(node['splunk']['home'], 'etc/auth/splunk.secret'), 'r') { |file| file.readline.chomp }
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
