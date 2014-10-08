# coding: UTF-8

name 'splunk_standalone'

description 'Environment for the Splunk 6 Standalone server'

default_attributes(
  splunk: {
    config: {
      clusters: [
        'cerner_splunk/cluster-standalone',
        'cerner_splunk/cluster-vagrant'
      ],
      roles: 'cerner_splunk/authnz-vagrant:roles',
      authentication: 'cerner_splunk/authnz-vagrant:authn',
      alerts: 'cerner_splunk/alerts-vagrant:alerts'
    }
  }
)
