@app.controller 'PipelineChangeReportController', [
	'$scope', '$window', '$document', '$httpParamSerializer', '$location', 'PipelineChangeReportService', 'zError'
	($scope,   $window,   $document,   $httpParamSerializer,   $location,   PipelineChangeReportService,   zError) ->

		$scope.changeTypes = [
			{id: 1, name: 'New Deals'}
			{id: 2, name: 'Won Deals'}
			{id: 3, name: 'Lost Deals'}
			{id: 4, name: 'Budget Changed'}
			{id: 5, name: 'Stage Changed'}
			{id: 6, name: 'Start Date Changed'}
			{id: 7, name: 'Member Added'}
			{id: 8, name: 'Member Removed'}
			{id: 9, name: 'Share Changed'}
		]

		appliedFilter = {}

		$scope.onFilterApply = (query) ->
			appliedFilter = query
			getReport query

		getReport = (query) ->
			if !query.start_date || !query.end_date
				return zError '#time-period-field', 'Select a Time Period to Run Report'
			PipelineChangeReportService.get(query).$promise.then (data)->
				$scope.report_data_items = data.report_data

		$scope.export = ->
			if !appliedFilter.start_date || !appliedFilter.end_date
				return zError '#time-period-field', 'Select a Time Period and Run Report to Export'
			url = '/api/deal_reports.csv'
			appliedFilter.utc_oset = moment().utcOffset()
			$window.open url + '?' + $httpParamSerializer appliedFilter
			return
]
