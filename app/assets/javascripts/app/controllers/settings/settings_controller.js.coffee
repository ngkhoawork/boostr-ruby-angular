@app.controller 'SettingsController',
    ['$scope', 'CurrentUser'
    ( $scope,   CurrentUser ) ->

        $scope.options = [
            {icon: 'gamepad',title: 'General Settings', url: '/settings/general', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'anchor',title: 'Smart Insights', url: '/settings/smart_insights', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'archive',title: 'Products', url: '/settings/products', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'area-chart',title: 'Teams', url: '/settings/teams', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'asterisk',title: 'Users', url: '/settings/users', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'automobile',title: 'Custom Fields', url: '/settings/custom_fields', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'balance-scale',title: 'Currencies', url: '/settings/currencies', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'bank',title: 'Custom Values', url: '/settings/custom_values', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'envelope',title: 'Time Periods', url: '/settings/time_periods', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'bed',title: 'Data Import/Export', url: '/settings/data_import', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'beer',title: 'Quotas', url: '/settings/quotas', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'bicycle',title: 'Stages', url: '/settings/stages', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'birthday-cake',title: 'Business Plans', url: '/settings/bps', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'book',title: 'Integrations', url: '/settings/api_configurations', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'bomb',title: 'Integration Logs', url: '/settings/integration_logs', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'bug',title: 'IO Feed Logs', url: 'settings/io_feed_logs', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'camera',title: 'Notifications', url: '/settings/notifications', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'cog',title: 'Initiatives', url: '/settings/initiatives', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {icon: 'cutlery',title: 'eAlerts', url: '/settings/ealerts', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
        ]


        CurrentUser.get().$promise.then (user) ->
            if _.contains user.roles, 'super_admin'
                $scope.options.push {icon: 'asterisk', title: 'Tools', url: '/settings/tools', description: 'Tools'}

    ]