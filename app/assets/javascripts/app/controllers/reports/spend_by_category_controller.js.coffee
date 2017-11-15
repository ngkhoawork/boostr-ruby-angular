@app.controller 'SpendByCategoryController',
    ['$rootScope', '$scope', '$window', '$q', 'TimePeriod', 'Field', 'Revenue', 'zError'
    ( $rootScope,   $scope,   $window,   $q,   TimePeriod,   Field, Revenue, zError) ->

      # $scope.appliedFilter = {}
      $scope.month_names = [
        'Jan', 'Feb', 'Mar',
        'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep',
        'Oct', 'Nov', 'Dec'
      ]

      $scope.spend_months = []
      $scope.timePeriods  = []
      $scope.categories   = []
      $scope.segments     = []
      $scope.regions      = []
      $scope.spends       = []

      $q.all(
        client_base_options: Field.client_base_options()
        timePeriods: TimePeriod.all()
      ).then (data) ->
        $scope.categories = data.client_base_options.categories
        $scope.segments = data.client_base_options.segments
        $scope.regions = data.client_base_options.regions
        $scope.timePeriods = data.timePeriods.filter (period) ->
          period.visible and (period.period_type is 'quarter' or period.period_type is 'year')

      $scope.onFilterApply = (query) ->
        # $scope.appliedFilter = query
        # query.id = 'all' if !query.id
        # query.user_id = 'all' if !query.user_id
        getData(query)

      getData = (query) ->
        if !query.start_date || !query.end_date
          zError '#time-period-field', 'Select a Time Period to Run Report'
          return
        if !query['category_ids[]']
          zError '#category-field', 'Select a Category to Run Report'
          return

        Revenue.spend_by_product(query).$promise.then (data) ->
          _.each(data, setCategoryNames)
          setMonthNames(data)
          $scope.spends = data

      setCategoryNames = (item) ->
        category = _.findWhere($scope.categories, { id: item.category_id })
        item.name = category.name

      setMonthNames = (data) ->
        return if data.length is 0
        revenues1 = data[0].revenues
        revenues2 = data[1].revenues

        month_nums = Object.keys(revenues1)
        month_nums = _.uniq(month_nums.concat Object.keys(revenues2))
        month_nums = _.map(month_nums, parseInt)
        month_nums = _.sortBy(month_nums)
        debugger
        _.each(month_nums, applyMonth)
        $scope.spend_months

      applyMonth = (num) ->
        $scope.spend_months.push $scope.month_names[num]

      # init = ->
      #   console.log 'it works'
      # init()
    ]
