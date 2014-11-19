# coding: UTF-8
#
# Cookbook Name:: cerner_splunk
# Recipe:: cluster_master
#
# Install a Splunk Cluster Master.

fail 'Cluster Master installation not currently supported on windows' if platform_family?('windows')

## Attributes
instance_exec :cluster_master, &CernerSplunk::NODE_TYPE

## Recipes
include_recipe 'cerner_splunk::_install_server'

password_file = File.join node[:splunk][:external_config_directory], 'password'

execute 'apply-cluster-bundle' do
  command "cat #{password_file} | xargs #{node[:splunk][:cmd]} apply cluster-bundle --answer-yes -auth admin:"
  action :nothing
end

cluster_bag = CernerSplunk::DataBag.load(CernerSplunk.my_cluster_data(node)['apps'], pick_context['master-apps']) || {}

bag_bag = CernerSplunk::DataBag.load(cluster_bag['bag']) || {}

apps = CernerSplunk::SplunkApp.merge_hashes(bag_bag, cluster_bag)

apps.each do |app_name, app_data|
  splunk_app app_name do
    apps_dir "#{node[:splunk][:home]}/etc/master-apps"
    action app_data['remove'] ? :remove : :create
    local app_data['local']
    files app_data['files']
    permissions app_data['permissions']
    notifies :execute, 'execute[apply-cluster-bundle]'
  end
end

include_recipe 'cerner_splunk::_configure_indexes'
include_recipe 'cerner_splunk::_start'
