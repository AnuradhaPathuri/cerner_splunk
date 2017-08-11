
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Recipe:: heavy_forwarder
#
# Installs the Enterprise Splunk artifact to be used as a heavy forwarder.

## Attributes
instance_exec :forwarder, &CernerSplunk::NODE_TYPE

node.default['splunk']['package']['base_name'] = 'splunk'

node.run_state['cerner_splunk'] ||= {}

splunk_installed = CernerSplunk.separate_splunk_installed?(node)

## Recipes
include_recipe 'cerner_splunk::_migrate_forwarder' if splunk_installed
include_recipe 'cerner_splunk::_install'

ruby_block 'initialize-splunk-backup-artifacts' do
  block do
    package_type = CernerSplunk.package_type(node['splunk']['package']['base_name']).to_sym
    splunk_home = CernerSplunk::PathHelpers.default_install_dirs.dig(package_type, node['os'].to_sym)
    FileUtils.cp_r(::File.join(Chef::Config[:file_cache_path], 'fishbucket'), ::File.join(splunk_home, '/var/lib/splunk'))
    FileUtils.cp(::File.join(Chef::Config[:file_cache_path], 'passwd'), ::File.join(splunk_home, '/etc/passwd'))
    FileUtils.rm_r(::File.join(Chef::Config[:file_cache_path], 'fishbucket'))
    FileUtils.rm(::File.join(Chef::Config[:file_cache_path], 'passwd'))
    unless platform_family?('windows')
      FileUtils.chown_R(node['splunk']['user'], node['splunk']['group'], ::File.join(splunk_home, '/var/lib/splunk/fishbucket'))
      FileUtils.chown(node['splunk']['user'], node['splunk']['group'], ::File.join(splunk_home, '/etc/passwd'))
    end
  end
  only_if { node.run_state['cerner_splunk']['splunk_forwarder_migrate'] }
end

include_recipe 'cerner_splunk::_start'
