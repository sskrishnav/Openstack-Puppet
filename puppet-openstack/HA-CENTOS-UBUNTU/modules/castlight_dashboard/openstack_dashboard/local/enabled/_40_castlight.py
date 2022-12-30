# The name of the dashboard to be added to HORIZON['dashboards']. Required.
DASHBOARD = 'castlight'

# If set to True, this dashboard will not be added to the settings.
DISABLED = False

ADD_INSTALLED_APPS = [
    'openstack_dashboard.dashboards.castlight',
]