
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Recipe:: shc_captain
#

raise 'Captain installation not currently supported on windows' if platform_family?('windows')

search_heads = CernerSplunk.my_cluster_data(node)['shc_members']

raise 'Search Heads are not configured for sh clustering in the cluster databag' if search_heads.nil? || search_heads.empty?

## Attributes
instance_exec :shc_captain, &CernerSplunk::NODE_TYPE

## Recipes
include_recipe 'cerner_splunk::_install_server'
include_recipe 'cerner_splunk::_start'

sh_cluster 'Captain assignment' do
  search_heads search_heads
  admin_password(lazy { node.run_state['cerner_splunk']['admin_password'] })
  action :initialize
  sensitive true
end
