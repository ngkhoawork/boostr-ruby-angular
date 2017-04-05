@app.controller 'ForecastsDetailController',
    ['$scope', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast'
    ( $scope,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast) ->
        $scope.teams = []
        $scope.sellers = []
        $scope.timePeriods = []
        defaultUser = {id: 'all', name: 'All', first_name: 'All'}
        currentUser = null
        $scope.filter =
            team: {id: null, name: 'All'}
            seller: defaultUser
            timePeriod: {id: 'all', name: 'All'}
        $scope.selectedTeam = $scope.filter.team
        $scope.switch =
            revenue: 1
            deals: 1
            set: (key, val) ->
                this[key] = val

        $scope.$watch 'selectedTeam', (nextTeam, prevTeam) ->
            if nextTeam.id then $scope.filter.seller = defaultUser
            $scope.setFilter('team', nextTeam)
            Seller.query({id: nextTeam.id || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
                $scope.sellers.unshift(defaultUser)

        $scope.setFilter = (key, value) ->
            if $scope.filter[key]is value
                return
            $scope.filter[key] = value
            getData()

        $q.all(
            user: CurrentUser.get().$promise
            teams: Team.all(all_teams: true)
            sellers: Seller.query({id: 'all'}).$promise
            timePeriods: TimePeriod.all()
        ).then (data) ->
            if data.user.user_type is 1 || data.user.user_type is 2
                currentUser = data.user
                $scope.filter.seller = data.user
            $scope.teams = data.teams
            $scope.teams.unshift {id: null, name: 'All'}
            $scope.sellers = data.sellers
            $scope.sellers.unshift(defaultUser)
            $scope.timePeriods = angular.copy data.timePeriods
            $scope.filter.timePeriod = _.first $scope.timePeriods
            getData()

        getData = ->
            query =
                id: $scope.filter.team.id || 'all'
                user_id: $scope.filter.seller.id || 'all'
                time_period_id: $scope.filter.timePeriod.id || 'all'
            Forecast.forecast_detail(query).$promise.then (data) ->
                console.log data[0]

    ]