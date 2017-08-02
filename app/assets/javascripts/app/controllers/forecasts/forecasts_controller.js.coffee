@app.controller 'ForecastsController',
	['$scope', 'Forecast', 'Team', 'Seller', 'Product'
	( $scope,   Forecast,   Team,   Seller,   Product ) ->

		$scope.teams = []
		$scope.sellers = []
		$scope.products = []

		emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}
		defaultFilter =
			team: emptyFilter
			seller: emptyFilter
			product: emptyFilter
		$scope.filter = angular.copy defaultFilter

		$scope.setFilter = (key, val) ->
			$scope.filter[key] = val

		$scope.resetFilter = ->
			$scope.filter = angular.copy defaultFilter

		$scope.$watch 'filter.team', (team) ->
			if team.id then $scope.filter.seller = emptyFilter
			Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
				$scope.sellers = _.sortBy sellers, 'name'

		Team.all(all_teams: true).then (teams) ->
			$scope.teams = teams
			$scope.teams.unshift emptyFilter

		Product.all().then (products) ->
			$scope.products = products

		Forecast.query({ time_period_id: 146 }).$promise.then (forecast) ->
			console.log forecast

	]
