# coding: UTF-8

name 'splunk_server'

description 'Environment for the Splunk 6 Cluster'

default_attributes(
  splunk: {
    config: {
      clusters: [
        'cerner_splunk/cluster-vagrant'
      ],
      roles: 'cerner_splunk/authnz-vagrant:roles',
      authentication: 'cerner_splunk/authnz-vagrant:authn',
      alerts: 'cerner_splunk/alerts-vagrant:alerts'
    }
  }
)
