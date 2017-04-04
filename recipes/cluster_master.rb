
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Recipe:: cluster_master
#
# Install a Splunk Cluster Master.

raise 'Cluster Master installation not currently supported on windows' if platform_family?('windows')

## Attributes
instance_exec :cluster_master, &CernerSplunk::NODE_TYPE

## Recipes
include_recipe 'cerner_splunk::_install_server'

execute 'apply-cluster-bundle' do # ~FC009
  command(lazy { "#{node['splunk']['cmd']} apply cluster-bundle --answer-yes -auth admin:#{node.run_state['cerner_splunk']['admin-password']}" })
  environment 'HOME' => node['splunk']['home']
  sensitive true
  action :nothing
end

cluster_bag = CernerSplunk::DataBag.load(CernerSplunk.my_cluster_data(node)['apps'], pick_context: ['master-apps']) || {}

bag_bag = CernerSplunk::DataBag.load(cluster_bag['bag']) || {}

apps = CernerSplunk::SplunkApp.merge_hashes(bag_bag, cluster_bag)

apps.each do |app_name, app_data|
  download_data = app_data['download'] || {}

  splunk_app_package app_name do
    action app_data['remove'] ? :uninstall : :install
    source_url download_data['url']
    version download_data['version']
    app_root :master_apps

    # TODO: I don't think these exist yet...
    files CernerSplunk::SplunkApp.proc_files(app_path, files: app_data['files'])
    metadata CernerSplunk::SplunkApp.proc_metadata(app_data['permissions'])
    notifies :run, 'execute[apply-cluster-bundle]'
  end
end

include_recipe 'cerner_splunk::_configure_indexes'
include_recipe 'cerner_splunk::_start'
