@app.controller 'SettingsController',
    ['$scope'
    ( $scope ) ->

        $scope.options = [
            {title: 'General Settings',   url: '/settings/general',            icon: 'gear',                description: 'Manage snapshots, validations & permissions'}
            {title: 'Smart Insights',     url: '/settings/smart_insights',     icon: 'area-chart',          description: 'Manage settings for various Smart Insights dashboards'}
            {title: 'Products',           url: '/settings/products',           icon: 'star',                description: 'Manage products'}
            {title: 'Teams',              url: '/settings/teams',              icon: 'sitemap',             description: 'Manage teams and hierarchies'}
            {title: 'Users',              url: '/settings/users',              icon: 'user',                description: 'Manage boostr users'}
            {title: 'Custom Fields',      url: '/settings/custom_fields',      icon: 'wrench',              description: 'Manage custom fields'}
            {title: 'Currencies',         url: '/settings/currencies',         icon: 'dollar',              description: 'Manage Currencies and Exchange Rates'}
            {title: 'Custom Values',      url: '/settings/custom_values',      icon: 'tags',                description: 'Manage drop down field values'}
            {title: 'Time Periods',       url: '/settings/time_periods',       icon: 'calendar',            description: 'Manage time periods'}
            {title: 'Data Import/Export', url: '/settings/data_import',        icon: 'arrow-circle-o-down', description: 'Import and Export data'}
            {title: 'Quotas',             url: '/settings/quotas',             icon: 'gamepad',             description: 'Setup quotas for users per time period'}
            {title: 'Stages',             url: '/settings/stages',             icon: 'bullseye',            description: 'Manage sales stages and %\'s'}
            {title: 'Bottoms Up',         url: '/settings/bps',                icon: 'book',                description: 'Manage Bottoms Up'}
            {title: 'Integrations',       url: '/settings/api_configurations', icon: 'paper-plane-o',       description: 'Manage integration settings for external systems '}
            {title: 'Integration Logs',   url: '/settings/integration_logs',   icon: 'arrows-h',            description: 'View integration activities and error details'}
            {title: 'IO Feed Logs',       url: 'settings/io_feed_logs',        icon: 'arrows-v',            description: 'View DFP and Operative IO import jobs and error details'}
            {title: 'Notifications',      url: '/settings/notifications',      icon: 'envelope',            description: 'Setup simple email notifications'}
            {title: 'Initiatives',        url: '/settings/initiatives',        icon: 'list-ol',             description: 'Setup initiatives for tracking progress against goals'}
            {title: 'eAlerts',            url: '/settings/ealerts',            icon: 'envelope',            description: 'Manage eAlert HTML workflow emails'}
            {title: 'Tools',              url: '/settings/tools',              icon: 'asterisk',            description: 'Tools'} if $scope.currentUserRoles.isSuperAdmin()
            {title: 'Permissions',        url: '/settings/permissions',        icon: 'gear',                description: 'Manage permissions for data visibility or editibility on forecast and ios.'}
            {title: 'Validations',        url: '/settings/validations',        icon: 'check-square-o',      description: 'Configure required data for Accounts and Deals.'}
            {title: 'Activity Types',     url: '/settings/activity_types',     icon: 'users',               description: 'Create, edit and reorder Activity Types.'}
            {title: 'Egnyte',             url: '/settings/egnyte',             icon: 'gear',                description: 'Setup Egnyte'} if $scope.companyEgnyteEnabled
            {title: 'Leads',              url: '/settings/leads',              icon: 'flag-checkered',      description: 'Create and manage automatic assignments'}
            {title: 'Workflows',          url: '/settings/workflows',          icon: 'share-alt',           description: 'Configure Events and trigger integrations.', icon1: 'share-alt', icon2: 'reply-all', icon3: 'external-link-square', icon0: 'share'}
        ]
    ]

