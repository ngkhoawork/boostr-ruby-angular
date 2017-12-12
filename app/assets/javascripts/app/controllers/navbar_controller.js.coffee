@app.controller 'NavbarController',
['$scope', '$location'
( $scope,   $location ) ->

    $scope.isActive = (viewLocation) ->
      $location.path().indexOf(viewLocation) == 0

    $scope.navbar = [
        {name: 'HOME PAGE', url: '/dashboard'}
        {name: 'DEALS', url: '/deals'}
        {name: 'FORECAST', url: '/forecast'}
        {name: 'REVENUE', url: '/revenue'}
        {name: 'ACCOUNTS', url: '/accounts'}
        {name: 'CONTACTS', url: '/contacts'}
        {name: 'INFLUENCERS', url: '/influencers'} if _isCompanyInfluencerEnabled
        {name: 'BUSINESS PLANS', url: '/bps'}
        {name: 'FINANCE', url: '/finance', dropdown: [
            {name: 'Billing', url: '/finance/billing'}
        ]}
        {name: 'REPORTS', url: '/reports', dropdown: [
            {name: 'Pipeline Monthly Summary', url: '/reports/pipeline_monthly_report'}
            {name: 'Activity Detail', url: '/reports/activity_detail_reports'}
            {name: 'Activity Summary', url: '/reports/activity_summary'}
            {name: 'Forecast Detail', url: '/reports/forecasts'}
            {name: 'Forecast Detail by Product', url: '/reports/product_forecasts'}
            {name: 'Pipeline Changes', url: '/reports/pipeline_changes_report'}
            {name: 'Pipeline Split Adjusted', url: '/reports/pipeline_split_report'}
            {name: 'Pipeline Summary', url: '/reports/pipeline_summary_report'}
            {name: 'Influencer Budget Detail', url: '/reports/influencer_budget_detail'}
            {name: 'Product Monthly Summary', url: '/reports/product_monthly_summary'}
            {name: 'Spend by Account', url: '/reports/spend_by_account'}
            {name: 'Spend by Category', url: '/reports/spend_by_category'}
        ]}
        {name: 'SMART INSIGHTS', url: '/smart_reports', dropdown: [
            {name: 'Sales Execution Dashboard', url: '/smart_reports/sales_execution_dashboard'}
            {name: 'Monthly Forecast', url: '/smart_reports/monthly_forecasts'}
            {name: 'Where to Pitch', url: '/smart_reports/where_to_pitch'}
            {name: 'KPI Analytics', url: '/smart_reports/kpi_analytics'}
            {name: 'Inactives', url: '/smart_reports/inactives'}
            {name: 'Initiatives', url: '/smart_reports/initiatives'}
            {name: 'Pacing Dashboard', url: '/smart_reports/pacing_dashboard'}
            {name: 'Agency 360', url: '/smart_reports/agency360'}
        ]}
        {name: 'REQUESTS', url: '/requests'} if _isRequestsVisible
        {name: 'SETTINGS', url: '/settings'} if $scope.currentUserRoles.isAdmin() || $scope.currentUserRoles.isSuperAdmin()
    ]

]