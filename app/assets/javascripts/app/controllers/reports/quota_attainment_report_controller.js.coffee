@app.controller 'QuotaAttainmentReportController',
	['$scope', '$window', '$httpParamSerializer', 'Report', 'TimePeriod', 'zError'
	( $scope,   $window,   $httpParamSerializer,   Report,   TimePeriod,   zError ) ->
		$scope.userStatus = [{id: 'active', name: 'Active'}, {id: 'inactive', name: 'Inactive'}] 
		$scope.timePeriods = []
		$scope.totals = {}
		$scope.members = []
		appliedFilter = {}

		$scope.onFilterApply = (query) ->
			query.user_id = 'all'
			query.product_id = 'all'
			appliedFilter = query
			getData query
			
		getData = (query) ->
			if !query.time_period_id
				return zError '#time-period-field', 'Select a Time Period to Run Report'
			Report.quota_attainment(query).$promise.then (data) ->
				$scope.members = data

		$scope.export = ->
			if !appliedFilter.time_period_id
				return zError '#time-period-field', 'Select a Time Period to Run Report'
			url = '/api/reports/quota_attainment.csv'
			$window.open url + '?' + $httpParamSerializer appliedFilter
			return

		init = ->
			timePeriods: TimePeriod.all().then (data) ->
				$scope.timePeriods = data.filter (period) ->
					period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
				
		init()
	]
