@app.controller 'SpendByAccountController',
  ['$scope', 'SpendByAccount', 'zError', '$window', '$httpParamSerializer', 'Field', ($scope, SpendByAccount, zError, $window, $httpParamSerializer, Field) ->
    appliedFilter = {}
    $scope.spend_by_account = []
    $scope.category = []
    $scope.type = [
      {id: 10, name: "Advertiser"},
      {id: 11, name: "Agency"}
    ]
    $scope.categories = []
    $scope.segments = []
    $scope.regions = []
    $scope.months = []

    getMonths = (startDate, endDate) ->
      start = moment startDate
      end = moment endDate
      months = []
      while end > start
        months.push
          label: start.format('MMM YY')
          date: start.format('YYYY-MM')
        start.add 1, 'month'
      months

    $scope.onFilterApply = (query) ->
      appliedFilter = query
      getReport query

    getReport = (query) ->
      $scope.months = getMonths(query.start_date, query.end_date)
      if !query.start_date || !query.end_date
        return zError '#time-period-field', 'Select a Time Period to Run Report'
      SpendByAccount.SpendByAccountReport(query).then (data) ->
        $scope.spend_by_account = data

    $scope.export = ->
      if !appliedFilter.start_date || !appliedFilter.end_date
        return zError '#time-period-field', 'Select a Time Period and Run Report to Export'
      url = '/api/revenue/report_by_account.csv'
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
]