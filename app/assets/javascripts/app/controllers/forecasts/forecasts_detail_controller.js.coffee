@app.controller 'ForecastsDetailController',
    ['$scope', 'Team', 'Seller', 'TimePeriod', 'CurrentUser'
    ( $scope,   Team,   Seller,   TimePeriod,   CurrentUser) ->
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

        CurrentUser.get().$promise.then (user) ->
            if user.user_type is 1 || user.user_type is 2
                currentUser = user
                $scope.filter.seller = user
            getData()
            Seller.query({id: 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
                $scope.sellers.unshift(defaultUser)

            TimePeriod.all().then (timePeriods) ->
                $scope.timePeriods = angular.copy timePeriods
                $scope.timePeriods.unshift({name:'All', id:'all'})

            Team.all(all_teams: true).then (teams) ->
                $scope.teams = teams
                $scope.teams.unshift {id: null, name: 'All'}

        getData = ->
            f = $scope.filter
            query = {}
            if f.timePeriod.id != 'all' then query.time_period_id = f.timePeriod.id
            if $scope.filter.seller.id != defaultUser.id
                query.filter = 'user'
                query.user_id = f.seller.id
            else
                query.filter = 'selected_team'
                query.team_id = f.team.id || 'all'

    ]