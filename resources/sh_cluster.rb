
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Resource:: sh_cluster
#

resource_name :sh_cluster
provides :cerner_splunk_sh_cluster

property :search_heads, Array
property :admin_password, String, sensitive: true

default_action :add

action :initialize do
  execute 'Captain assignment' do # ~FC009
    command "#{node['splunk']['cmd']} bootstrap shcluster-captain -servers_list '#{search_heads.join(',')}' -auth admin:#{admin_password}"
    environment 'HOME' => node['splunk']['home']
    # execute only if there isn't a captain in the cluster
    not_if "#{node['splunk']['cmd']} list shcluster-members -auth admin:#{admin_password} | grep is_captain:1"
    sensitive true
  end
end

action :add do
  execute 'add search head' do # ~FC009
    command "#{node['splunk']['cmd']} add shcluster-member -current_member_uri #{search_heads.first} -auth admin:#{admin_password}"
    environment 'HOME' => node['splunk']['home']
    # execute only if this SH is not an existing member of the SHC
    not_if "#{node['splunk']['cmd']} list shcluster-members -auth admin:#{admin_password} | grep #{node['ipaddress']}"
    ignore_failure true
    sensitive true
  end
end

action :remove do
  execute 'remove search head' do # ~FC009
    command "#{node['splunk']['cmd']} remove shcluster-member -auth admin:#{admin_password}"
    environment 'HOME' => node['splunk']['home']
    # execute only if this SH is an existing member of the SHC
    only_if "#{node['splunk']['cmd']} list shcluster-members -auth admin:#{admin_password} | grep #{node['ipaddress']}"
    sensitive true
  end
end
