@app.controller 'PipelineSummaryReportController',
	['$scope', '$window', '$location', '$httpParamSerializer', '$httpParamSerializerJQLike', '$routeParams', 'Report', 'Team', 'Seller', 'Stage', 'Field', 'DealCustomFieldName'
	( $scope,   $window,   $location,   $httpParamSerializer,   $httpParamSerializerJQLike,   $routeParams,   Report,   Team,   Seller,   Stage,   Field,   DealCustomFieldName ) ->

		$scope.teams = []
		$scope.sellers = []
		$scope.stages = []
		$scope.types = []
		$scope.sources = []
		$scope.dealCustomFieldNames = []
		$scope.totals =
			pipelineUnweighted: 0
			pipelineWeighted: 0
			pipelineRatio: 0
			deals: 0
			aveDealSize: 0

		$scope.sorting =
			key: null
			reverse: false
			set: (key) ->
				this.reverse = if this.key == key then !this.reverse else false
				this.key = key

		appliedFilter = null

		$scope.onFilterApply = (query) ->
			appliedFilter = query
			getReport query

		getReport = (query) ->
			Report.pipeline_summary(query).$promise.then (data) ->
				$scope.deals = data
				calcTotals(data)

		calcTotals = (deals) ->
			t = $scope.totals
			_.each t, (val, key) -> t[key] = 0 #reset values
			_.each deals, (deal) ->
				budget = parseInt(deal.budget) || 0
				t.pipelineUnweighted += budget
				t.pipelineWeighted += budget * deal.stage.probability / 100
			t.pipelineRatio = (Math.round(t.pipelineWeighted / t.pipelineUnweighted * 100) / 100) || 0
			t.deals = deals.length
			t.aveDealSize = (t.pipelineUnweighted / deals.length) || 0

		($scope.updateSellers = (team) ->
			Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
				$scope.sellers = sellers
		)()

		Team.all(all_teams: true).then (teams) ->
			$scope.teams = teams

		Stage.query().$promise.then (stages) ->
			$scope.stages = _.filter stages, (stage) -> stage.active

		Field.defaults({}, 'Deal').then (fields) ->
			client_types = Field.findDealTypes(fields)
			client_types.options.forEach (option) ->
				$scope.types.push(option)

			sources = Field.findSources(fields)
			sources.options.forEach (option) ->
				$scope.sources.push(option)

		DealCustomFieldName.all().then (dealCustomFieldNames) ->
			$scope.dealCustomFieldNames = dealCustomFieldNames

		$scope.export = ->
			url = '/api/reports/pipeline_summary.csv'
			$window.open url + '?' + $httpParamSerializer appliedFilter
			return

	]