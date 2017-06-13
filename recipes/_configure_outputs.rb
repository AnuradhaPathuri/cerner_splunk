
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Recipe:: _configure_outputs
#
# Configures the system outputs.conf file
output_stanzas = CernerSplunk::Outputs.configure_outputs(node)

splunk_conf 'system/outputs.conf' do
  config output_stanzas
  not_if { output_stanzas.empty? }
  action :configure
  notifies :desired_restart, "splunk_service[#{node['splunk']['package']['type']}]", :immediately
end
