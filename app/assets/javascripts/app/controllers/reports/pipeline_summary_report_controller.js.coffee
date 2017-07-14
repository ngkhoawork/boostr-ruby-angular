@app.controller 'PipelineSummaryReportController',
	['$scope', '$window', '$location', '$httpParamSerializer', '$routeParams', 'Report', 'Team', 'Seller', 'Stage', 'Field', 'DealCustomFieldName'
	( $scope,   $window,   $location,   $httpParamSerializer,   $routeParams,   Report,   Team,   Seller,   Stage,   Field,   DealCustomFieldName ) ->

			$scope.data = []
			$scope.teams = []
			$scope.sellers = []
			$scope.stages = []
			$scope.types = []
			$scope.sources = []
			$scope.dealCustomFieldNames = []

			$scope.sorting =
				key: null
				reverse: false
				set: (key) ->
					this.reverse = if this.key == key then !this.reverse else false
					this.key = key

			emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}

			defaultFilter =
				team: emptyFilter
				seller: emptyFilter
				stages: []
				type: emptyFilter
				source: emptyFilter
				startDate:
					startDate: null
					endDate: null
				createdDate: null

			$scope.datePicker =
				toString: ->
					date = $scope.filter.startDate
					if !date.startDate || !date.endDate then return false
					date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
				apply: ->
					console.log arguments

			$scope.filter = angular.copy defaultFilter

			$scope.setFilter = (key, val) ->
				if key == 'stages'
					$scope.filter[key] = if val.id then _.union $scope.filter[key], [val] else []
				else
					$scope.filter[key] = val

			$scope.removeFilter = (key, item) ->
				$scope.filter[key] = _.reject $scope.filter[key], (row) -> row.id == item.id

			$scope.applyFilter = ->
				query = getQuery()
				#                $location.search(query)
				getReport query


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
				query.seller_id = f.seller.id if f.seller.id
				if f.date.startDate && f.date.endDate
					query.start_date = f.date.startDate.format('YYYY-MM-DD')
					query.end_date = f.date.endDate.format('YYYY-MM-DD')
				query


			getReport = (query) ->
				Report.split_adjusted(query).$promise.then (data) ->
					$scope.data = data

			$scope.$watch 'filter.team', (team, prevTeam) ->
				if team.id then $scope.filter.seller = emptyFilter
				Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
					$scope.sellers = _.sortBy sellers, 'name'

			Team.all(all_teams: true).then (teams) ->
				$scope.teams = teams
				$scope.teams.unshift emptyFilter

#            Seller.query({id: 'all'}).$promise.then (sellers) ->
#                $scope.sellers = sellers
#                $scope.sellers.unshift emptyFilter


			Stage.query().$promise.then (stages) ->
				$scope.stages = stages
				$scope.stages.unshift emptyFilter

			Field.defaults({}, 'Deal').then (fields) ->
				client_types = Field.findDealTypes(fields)
				client_types.options.forEach (option) ->
					$scope.types.push(option)

				sources = Field.findSources(fields)
				sources.options.forEach (option) ->
					$scope.sources.push(option)

			DealCustomFieldName.all().then (dealCustomFieldNames) ->
				console.log $scope.dealCustomFieldNames = dealCustomFieldNames

			$scope.export = ->
				url = '/api/reports/split_adjusted.csv'
				$window.open url + '?' + $httpParamSerializer getQuery()
				return

	]