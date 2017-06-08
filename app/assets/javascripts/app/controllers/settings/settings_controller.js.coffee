@app.controller 'SettingsController',
    ['$scope', 'CurrentUser'
    ( $scope,   CurrentUser ) ->

        $scope.options = [
            {title: 'General Settings',   url: '/settings/general',            icon: 'gamepad',       description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Smart Insights',     url: '/settings/smart_insights',     icon: 'anchor',        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Products',           url: '/settings/products',           icon: 'archive',       description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Teams',              url: '/settings/teams',              icon: 'area-chart',    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Users',              url: '/settings/users',              icon: 'asterisk',      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Custom Fields',      url: '/settings/custom_fields',      icon: 'automobile',    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Currencies',         url: '/settings/currencies',         icon: 'balance-scale', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Custom Values',      url: '/settings/custom_values',      icon: 'bank',          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Time Periods',       url: '/settings/time_periods',       icon: 'envelope',      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Data Import/Export', url: '/settings/data_import',        icon: 'bed',           description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Quotas',             url: '/settings/quotas',             icon: 'beer',          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Stages',             url: '/settings/stages',             icon: 'bicycle',       description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Business Plans',     url: '/settings/bps',                icon: 'birthday-cake', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Integrations',       url: '/settings/api_configurations', icon: 'book',          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Integration Logs',   url: '/settings/integration_logs',   icon: 'bomb',          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'IO Feed Logs',       url: 'settings/io_feed_logs',        icon: 'bug',           description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Notifications',      url: '/settings/notifications',      icon: 'camera',        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'Initiatives',        url: '/settings/initiatives',        icon: 'cog',           description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
            {title: 'eAlerts',            url: '/settings/ealerts',            icon: 'cutlery',       description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at posuere tellus. Nulla vulputate erat.'}
        ]


        CurrentUser.get().$promise.then (user) ->
            if _.contains user.roles, 'super_admin'
                $scope.options.push {icon: 'asterisk', title: 'Tools', url: '/settings/tools', description: 'Tools'}

    ]