@app.controller 'NavbarController',
['$scope', '$window', '$document', '$location', '$timeout', '$routeParams', 'Search', 
( $scope,   $window,   $document,   $location,   $timeout,   $routeParams,   Search) ->
    $scope.query = if $location.path() == '/search' then $location.search().query else ''
    $scope.searchResults = []
    searchTimeout = null

    $scope.isActive = (viewLocation) ->
      $location.path().indexOf(viewLocation) == 0

    $scope.search = (keyCode, query) ->
      if query.length == 0
        $scope.searchResults = []
      else if keyCode == 13
        $scope.searchResults = []
        $scope.query = query
        $location.url('/search?query=' + encodeURIComponent(query))
      else
        if searchTimeout then $timeout.cancel(searchTimeout)
        searchTimeout = $timeout(() ->
          return if query != $scope.query
          Search.all(query: query, limit: 10, order: 'rank').then (results) ->
            $scope.searchResults = results
        , 250)

    $scope.displayType = (res) ->
      switch res.searchable_type
        when 'Client' 
          'Account'
        when 'Contact'
          'Contact'
        when 'Io'
          'IO'
        when 'Deal'
          'Deal'

    $scope.showDetail = (res) ->
      url = switch res.searchable_type
        when 'Client' 
          'accounts/' + res.details.id
        when 'Contact'
          'contacts/' + res.details.id
        when 'Io'
          'revenue/ios/' + res.details.id
        when 'Deal'
          'deals/' + res.details.id
      $location.url(url)

    $scope.clearSearch = () ->
      $timeout () -> 
        $scope.searchResults = []
      , 200

    $scope.navbar = [
        {name: 'HOME PAGE', url: '/dashboard'}
        {name: 'DEALS', url: '/deals'}
        {name: 'FORECAST', url: '/forecast'}
        {name: 'REVENUE', url: '/revenue'}
        {name: 'ACCOUNTS', url: '/accounts'}
        {name: 'PUBLISHERS', url: '/publishers'} if _isPublisherEnabled
        {name: 'CONTACTS', url: '/contacts'}
        {name: 'INFLUENCERS', url: '/influencers'} if _isCompanyInfluencerEnabled
        {name: 'LEADS', url: '/leads'} if _isLeadsEnabled
        {name: 'BOTTOMS UP', url: '/bps'}
        {name: 'CONTRACTS', url: '/contracts'}
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
            {name: 'Quota Attainment', url: '/reports/quota_attainment'} if _isExec || _isAdmin
            {name: 'Publishers', url: '/reports/publishers'} if _isPublisherEnabled
        ]}
        {name: 'ANALYTICS', url: '/analytics'} if _isLogiEnabled
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

    windowEl = $($window)
    header = $('#header')
    headerOffset = 70

    updateFixedHeaderHeight = -> window._fixedHeaderHeight = header.outerHeight() - headerOffset
    $timeout -> updateFixedHeaderHeight()

    $scope.scrollTop = ->
        windowEl.scrollTop(0)
        return

    scroll = ->
        if windowEl.scrollTop() > headerOffset
            header.addClass 'fixed-header'
            header.css 'top', windowEl.scrollTop() - headerOffset
            $scope.$apply () ->
              $scope.searchResults = []
        else
            header.removeClass 'fixed-header'
            header.css 'top', 0

    $document.on 'scroll', scroll
    windowEl.on 'resize', updateFixedHeaderHeight
    $scope.$on '$destroy', ->
        $document.off 'scroll', scroll
        windowEl.off 'resize', updateFixedHeaderHeight

]
