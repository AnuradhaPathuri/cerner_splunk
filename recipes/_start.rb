
# frozen_string_literal: true

#
# Cookbook Name:: cerner_splunk
# Recipe:: _start
#
# Ensures the splunk instance is running, and performs post-start tasks.

ruby_block 'start-splunk' do
  block { true }
  notifies :start, "splunk_service[#{node['splunk']['package']['type']}]", :immediately
end

include_recipe 'cerner_splunk::_generate_password'
