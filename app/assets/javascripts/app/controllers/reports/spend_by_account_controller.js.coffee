@app.controller 'SpendByAccountController',
  ['$scope', 'SpendByAccount', 'zError', '$window', '$httpParamSerializer', 'Field', '$q', 'TimeDimension', '$timeout', ($scope, SpendByAccount, zError, $window, $httpParamSerializer, Field, $q, TimeDimension, $timeout) ->
    $scope.scrollCallback = -> $timeout -> $scope.$emit 'lazy:scroll'
    appliedFilter = {}
    $scope.category = []
    $scope.type = [
      {id: 10, name: "Advertiser"},
      {id: 11, name: "Agency"}
    ]
    $scope.categories = []
    $scope.segments = []
    $scope.regions = []
    $scope.months = []
    $scope.accountData = []
    $scope.timeDimensions = []
    $scope.page = 1
    $scope.allClientsLoaded = false
    $scope.isLoading = false
    $scope.per = 10

    getMonths = (startDate, endDate) ->
      start = moment startDate
      end = moment endDate
      months = []
      index = 0
      while end > start
        months.push
          label: start.format('MMM YY')
          date: start.format('YYYY-MM')
          id: index++
          totalRevenue: 0
        start.add 1, 'month'
      months

    $scope.onFilterApply = (query) ->
      $scope.page = 1
      appliedFilter = query
      getReport query, $scope.scrollCallback

    getReport = (query, callback) ->
      $scope.months = getMonths(query.start_date, query.end_date)
      if !query.start_date || !query.end_date
        if !query.start_date
          zError '#start-date-field', 'Add a Start Date'
        if !query.end_date
          zError '#end-date-field', 'Add an End Date'
        return
        
      getAccounts(query, callback)


    $scope.loadMoreClients = ->
      if !_.isEmpty appliedFilter
        if !$scope.allClientsLoaded then getReport(appliedFilter)


    getAccounts = (query, callback) ->
      $scope.isLoading = true
      query.page = $scope.page

      SpendByAccount.SpendByAccountReport(query).then (data) ->
        $scope.accountData.push data
        calculateTotalByMonth(_.flatten($scope.accountData))
        $scope.allClientsLoaded = !data || data.length < $scope.per

        if $scope.page++ > 1
          $scope.spend_by_account = $scope.spend_by_account.concat(data)
        else
          $scope.spend_by_account = data
        $scope.isLoading = false
        callback() if _.isFunction callback

    calculateTotalByMonth = (data) ->
      _.each data, (item) ->
        _.each item.month_revenues, (revenue, month) ->
          _.each $scope.months, (itemMonth) ->
            if moment(itemMonth.date).format('YYYY-MM') == moment(month).format('YYYY-MM')
              itemMonth.totalRevenue += revenue

    $scope.export = ->
      if !appliedFilter.start_date || !appliedFilter.end_date
        return zError '#time-period-field', 'Select a Time Period and Run Report to Export'
      url = '/api/revenue/report_by_account.csv'
      
      delete appliedFilter.page
      appliedFilter.utc_oset = moment().utcOffset()
      $window.open url + '?' + $httpParamSerializer appliedFilter
      return

    Field.defaults({}, 'Client').then (clients) ->
      for client in clients
        if client.name is 'Category'
          for category in client.options
            $scope.categories.push category

        if client.name is 'Segment'
          for segment in client.options
            $scope.segments.push segment
            
        if client.name is 'Region'
          for region in client.options
            $scope.regions.push region

    $q.all(
      timeDimensions: TimeDimension.revenue_fact_dimension_months()
    ).then (data) ->
      $scope.timeDimensions = data.timeDimensions
]