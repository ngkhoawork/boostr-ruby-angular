@app.controller 'PipelineChangeReportController', [
	'$scope', '$window', '$document', '$httpParamSerializer', '$location', 'PipelineChangeReportService', 'zError'
	($scope,   $window,   $document,   $httpParamSerializer,   $location,   PipelineChangeReportService,   zError) ->

		$scope.report_data_items = []
		$scope.changeTypes = [
			'New Deals'
			'Won Deals'
			'Lost Deals'
			'Budget Changed'
			'Stage Changed'
			'Start Date Changed'
			'Member Added'
			'Member Removed'
			'Share Changed'
		]

		appliedFilter = {}

		$scope.onFilterApply = (query) ->
			appliedFilter = query
			getReport query

		getReport = (query) ->
			if !query.start_date || !query.end_date
				return zError '#time-period-field', 'You should select time period to run the report'
			PipelineChangeReportService.get(query).$promise.then (data)->
				$scope.report_data_items = data.report_data

		$scope.export = ->
			if !appliedFilter.start_date || !appliedFilter.end_date
				return zError '#time-period-field', 'You should select time period and run the report to export it'
			url = '/api/deal_reports.csv'
			appliedFilter.utc_oset = moment().utcOffset()
			$window.open url + '?' + $httpParamSerializer appliedFilter
			return
]
