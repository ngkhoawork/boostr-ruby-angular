@app.controller 'PipelineSummaryReportController',
	['$scope', '$window', '$location', '$httpParamSerializer', '$httpParamSerializerJQLike', '$routeParams', 'Report', 'Team', 'Seller', 'Stage', 'Field', 'DealCustomFieldName', 'localStorageService'
	( $scope,   $window,   $location,   $httpParamSerializer,   $httpParamSerializerJQLike,   $routeParams,   Report,   Team,   Seller,   Stage,   Field,   DealCustomFieldName,   LS  ) ->

		$scope.deals = []
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

		emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}
		reportName = _.last(window.location.pathname.split('/'))

		defaultFilter =
			team: emptyFilter
			seller: emptyFilter
			stages: []
			type: emptyFilter
			source: emptyFilter
			startDate:
				startDate: null
				endDate: null
			createdDate:
				startDate: null
				endDate: null
			closedDate:
				startDate: null
				endDate: null

		$scope.filter = angular.copy(defaultFilter)
		appliedFilter = null
		savedFilters = LS.get(reportName) || []
		console.log savedFilters

		$scope.datePicker =
			toString: (key) ->
				date = $scope.filter[key]
				if !date.startDate || !date.endDate then return false
				if !moment.isMoment(date.startDate) then date.startDate = moment(date.startDate)
				if !moment.isMoment(date.endDate) then date.endDate = moment(date.endDate)
				date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
#				apply: -> console.log arguments


		$scope.setFilter = (key, val) ->
			if key == 'stages'
				$scope.filter[key] = if val.id then _.union $scope.filter[key], [val] else []
			else
				$scope.filter[key] = val

		$scope.removeFilter = (key, item) ->
			$scope.filter[key] = _.reject $scope.filter[key], (row) -> row.id == item.id

		$scope.applyFilter = ->
			query = getQuery()
			appliedFilter = angular.copy $scope.filter
			filterString = filterStringify()
			savedFilters = _.without savedFilters, filterString
			savedFilters.unshift(filterString)
			if savedFilters.length > 5 then savedFilters.pop()
			LS.set(reportName, savedFilters)
			getReport query

		$scope.isFilterApplied = ->
			!angular.equals $scope.filter, appliedFilter

		$scope.resetFilter = ->
			$scope.filter = angular.copy defaultFilter

		$scope.isNumber = _.isNumber

		getQuery = ->
			f = $scope.filter
			query = {}
			query.team_id = f.team.id if f.team.id
			query.seller_id = f.seller.id if f.seller.id
			query['stage_ids[]'] = _.map f.stages, (stage) -> stage.id if f.stages.length
			query.type_id = f.type.id if f.type.id
			query.source_id = f.source.id if f.source.id
			if f.startDate.startDate && f.startDate.endDate
				query.start_date = f.startDate.startDate.format('YYYY-MM-DD')
				query.end_date = f.startDate.endDate.format('YYYY-MM-DD')
			if f.createdDate.startDate && f.createdDate.endDate
				query.created_date_start = f.createdDate.startDate.format('YYYY-MM-DD')
				query.created_date_end = f.createdDate.endDate.format('YYYY-MM-DD')
			if f.closedDate.startDate && f.closedDate.endDate
				query.closed_date_start = f.closedDate.startDate.format('YYYY-MM-DD')
				query.closed_date_end = f.closedDate.endDate.format('YYYY-MM-DD')
			query

		filterStringify = ->
			obj = _.mapObject $scope.filter, (val, key) ->
				switch key
					when 'stages'
						if key is 'stages'
							val = _.map val, (stage) ->
								_.pick stage, 'id', 'name', 'probability'
					when 'startDate', 'createdDate', 'closedDate'
						if !val.startDate || !val.endDate then return
					else
						if val.id
							val = _.pick val, 'id', 'name'
						else
							return
				val

			JSON.stringify(obj)

		loadSavedFilter = (str) ->
			if !str then return
			savedFilter = JSON.parse(str)
			_.each savedFilter, (val, key) ->
				$scope.filter[key] = savedFilter[key] || defaultFilter[key]

		loadSavedFilter(savedFilters[0])

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
			t.aveDealSize = t.pipelineUnweighted / deals.length

		$scope.$watch 'filter.team', (team) ->
			if team.id && _.keys(team).length > 2 then $scope.filter.seller = emptyFilter
			Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
				$scope.sellers = _.sortBy sellers, 'name'

		Team.all(all_teams: true).then (teams) ->
			$scope.teams = teams
			$scope.teams.unshift emptyFilter


		Stage.query().$promise.then (stages) ->
			$scope.stages = _.filter stages, (stage) -> stage.active
			$scope.stages.unshift emptyFilter

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
			$window.open url + '?' + $httpParamSerializer getQuery()
			return

	]