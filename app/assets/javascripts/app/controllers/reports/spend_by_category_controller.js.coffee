@app.controller 'SpendByCategoryController',
    ['$rootScope', '$scope', '$window', '$q', 'TimePeriod', 'Field', 'Revenue', 'zError', 'TimeDimension', '$httpParamSerializer'
    ( $rootScope,   $scope,   $window,   $q,   TimePeriod,   Field,   Revenue,   zError,   TimeDimension,   $httpParamSerializer) ->

      $scope.selectedQuery = {}
      $scope.isNumber = _.isFinite
      $scope.offset = 12
      $scope.month_names = [
        'Jan', 'Feb', 'Mar',
        'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep',
        'Oct', 'Nov', 'Dec'
      ]

      $scope.timeDimensions = []
      $scope.spend_months = []
      $scope.timePeriods = []
      $scope.categories = []
      $scope.segments = []
      $scope.regions = []
      $scope.spends = []

      $q.all(
        client_base_options: Field.client_base_options()
        timePeriods: TimePeriod.all()
        timeDimensions: TimeDimension.revenue_fact_dimension_months()
      ).then (data) ->
        $scope.categories = data.client_base_options.categories
        $scope.segments = data.client_base_options.segments
        $scope.regions = data.client_base_options.regions
        $scope.timePeriods = data.timePeriods.filter (period) ->
          period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
        $scope.timeDimensions = data.timeDimensions

      $scope.onFilterApply = (query) ->
        if !query['category_ids[]']
          query['category_ids[]'] = $scope.categories.map((item) -> item.id)
        getData(query)

      $scope.export = ->
        if !$scope.selectedQuery['category_ids[]']
          $scope.selectedQuery['category_ids[]'] = $scope.categories.map((item) -> item.id)

        if !$scope.selectedQuery.start_date || !$scope.selectedQuery.end_date
          if !$scope.selectedQuery.start_date
            zError '#start-date-field', 'Add a Start Date'
          if !$scope.selectedQuery.end_date
            zError '#end-date-field', 'Add an End Date'
          return

        url = '/api/revenue/report_by_category.csv'
        $window.open url + '?' + $httpParamSerializer $scope.selectedQuery
        return

      getData = (query) ->
        if !query.start_date || !query.end_date
          if !query.start_date
            zError '#start-date-field', 'Add a Start Date'
          if !query.end_date
            zError '#end-date-field', 'Add an End Date'
          return

        Revenue.report_by_category(query).$promise.then (data) ->
          setMonthNames(data)
          $scope.spends = data

      setMonthNames = (data) ->
        return if data.length is 0
        revenues1 = data[0].revenues
        month_nums = Object.keys(revenues1)

        if data[1] && data[1].revenues
          revenues2 = data[1].revenues
          month_nums = _.uniq(month_nums.concat Object.keys(revenues2))

        nums = month_nums.map( (item) ->
          parseInt(item, 10)
        )

        nums = _.sortBy(nums)
        months  = nums.map( (num) ->
          { id: num, month: $scope.month_names[num - 1] }
        )
        $scope.spend_months = months

      applyMonth = (num) ->
        $scope.spend_months.push $scope.month_names[num - 1]
    ]
