# Attributes

In depth look at all attributes available for this cookbook.

## Required

- `node['splunk']['config']['clusters']` - Array of strings "data\_bag/data\_bag\_item" identifying the [databags](databags.md) containing cluster information to connect to.

## Configurable (with defaults)

- `node['splunk']['exclude_groups']` - Array of local groups to which the splunk user should not belong. (`['root','wheel','admin']`)
- `node['splunk']['groups']` - Array of local groups to which splunk user should be a member in addition to `node['splunk']['group']`. (\[] - no additional groups)
- `node['splunk']['main_project_index']` - Index to send all configured monitors to by default (nil - no default)
- `node['splunk']['monitors']` - Array of Hashes, to setup Monitoring stanzas (empty - no monitors)
  - `node['splunk']['monitors'][]['path']` - Path to monitor !!Required!!
  - `node['splunk']['monitors'][]['sourcetype']` - Sourcetype to set on events from this stanza !!Required!!
  - `node['splunk']['monitors'][]['index']` - Index to send events from this monitor to (`node['splunk']['main_project_index']`).
  - `node['splunk']['monitors'][]['type']` - Type of stanza (`monitor`). See [inputs.conf][] for stanzas.
  - `node['splunk']['monitors'][][???]` - Other attributes for an inputs.conf stanza. See [inputs.conf][]
- `node['splunk']['cleanup']` - Determines whether the recipe should attempt to clean up the old forwarder install (`true`)
- `node['splunk']['package']['version']` - Major version to install (`6.6.2`)
- `node['splunk']['package']['build']` - Corresponding build number (`4b804538c686`)
- `node['splunk']['package']['base_url']` - Base download path (`https://download.splunk.com/products`)
- `node['splunk']['package']['base_name']` - Name of the package to install (`splunkforwarder`/`splunk`)
- `node['splunk']['config']['alerts']` - Data bag item used to configure alerts (`nil` - alerts not managed by chef)
- `node['splunk']['config']['authentication']` - Data bag item used to configure authentication (`nil` - authentication not managed by chef)
- `node['splunk']['config']['host']` - Hostname to configure the Splunk instance to report as. (EC2 Instance ID or Fully Qualified Domain Name)
- `node['splunk']['config']['roles']` - Data bag item used to configure roles (`nil` - roles not managed by chef)
- `node['splunk']['config']['secrets']` - Cluster hash containing Coordinate String (see [data bags documentation][data_bags]), pointing to a key within a Chef Vault encrypted data bag item used to configure the splunk.secret file. (`nil` - secrets not managed by chef).  Note: this is currently not supported on windows.
- `node['splunk']['config']['password_secrets']` - Cluster hash containing Coordinate Strings (see [data bags documentation][data_bags]), pointing to a key within a Chef Vault encrypted data bag item used to configure the admin password. This property is required for search head clusters. (`nil` - do not refer to the vault).
- `node['splunk']['config']['licenses']` - Data bag item that the license server recipe uses as the source of truth for the license data.
- `node['splunk']['config']['license-pool']` - Data bag item used to configure license pools.
- `node['splunk']['config']['ui_prefs']` - Hash of stanzas used to configure [ui-prefs.conf][] on the search head in a clustered configuration or a standalone instance.
- `node['splunk']['config']['assumed_index']` - Name of the index to which data is forwarded to by default, when the index is not configured for the input.(`main`)
- `node['splunk']['bootstrap_shc_member']` - Set this attribute to `true` to bootstrap a member to the Search Head Cluster (SHC). (`false`)
- `node['splunk']['mgmt_host']` - The host other SHC members use when connecting to the current node. You probably want a wrapper cookbook to override this. (`node['ipaddress']`)
- `node['splunk']['heavy_forwarder']['use_license_uri']` - Set this attribute to `true` to point the Heavy Forwarder to the license master. (`false`)
- `node['splunk']['apps']` - An [apps hash](databags.md#apps-hash) of apps to configure locally. (Does not support downloading apps ... yet...)

## Non-configurable (defaults)

DO NOT override these attributes. [Funky Putin shows scientists what for](http://vimeo.com/68930177) every time you think of overriding these attributes. So don't do it.

- `node['splunk']['node_type']` - The type of node (name of the installation recipe)
- `node['splunk']['user']` - The user to run as (`splunk`)
- `node['splunk']['group']` - The group to run as (`splunk`)
- `node['splunk']['home']` - Splunk Install path (`/opt/#{node['splunk']['package']['base_name']}`)
- `node['splunk']['cmd']` - `splunk` executable (`/opt/#{node['splunk']['package']['base_name']}/bin/splunk`)
- `node['splunk']['external_config_directory']` - directory to place configuration related to this chef run of Splunk ('/etc/splunk')

# Docs Navigation

- [Docs Readme](README.md)
- [Repository Readme](../README.md)

[data_bags]: databags.md#contextual-hashes

[inputs.conf]: http://docs.splunk.com/Documentation/Splunk/6.0.1/admin/Inputsconf

[ui-prefs.conf]: http://docs.splunk.com/Documentation/Splunk/6.0.1/Admin/Ui-prefsconf
