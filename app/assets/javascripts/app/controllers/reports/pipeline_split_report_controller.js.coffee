@app.controller 'PipelineSplitReportController',
    ['$scope', '$window', '$location', '$httpParamSerializer', '$routeParams', 'Team', 'Seller', 'Stage'
    ( $scope,   $window,   $location,   $httpParamSerializer,   $routeParams,   Team,   Seller,   Stage ) ->

            $scope.teams = []
            $scope.sellers = []
            $scope.stages = []
            $scope.statuses = [
                {id: 'all', name: 'All'}
                {id: 'open', name: 'Open'},
                {id: 'closed', name: 'Closed'},
            ]

            $scope.sorting =
                key: null
                reverse: false
                set: (key) ->
                    this.reverse = if this.key == key then !this.reverse else false
                    this.key = key

            emptyFilter = {id: null, name: 'All', first_name: 'All'}

            $scope.filter =
                team: $routeParams.team || emptyFilter
                seller: $routeParams.seller || emptyFilter
                stage: $routeParams.stage || emptyFilter
                status: $routeParams.status || $scope.statuses[1]

            $scope.setFilter = (key, val) ->
                $scope.filter[key] = val
                $scope.applyFilter()

            $scope.applyFilter = ->
                query = getQuery()
#                $location.search(query)
#                getActivities(query)

            $scope.resetFilter = ->
                $scope.filter.team = emptyFilter
                $scope.filter.seller = emptyFilter
                $scope.filter.stage = emptyFilter
                $scope.filter.status = $scope.statuses[1]
                $scope.applyFilter()

            $scope.isNumber = _.isNumber

            $scope.$watch 'filter.team', (team) ->
                if team.id then $scope.filter.seller = emptyFilter
                Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
                    $scope.sellers = sellers
                    $scope.sellers.unshift(emptyFilter)

            Team.all(all_teams: true).then (teams) ->
                $scope.teams = teams
                $scope.teams.unshift emptyFilter

            Seller.query({id: 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
                $scope.sellers.unshift emptyFilter

            Stage.query().$promise.then (stages) ->
                $scope.stages = stages
                $scope.stages.unshift emptyFilter

            getQuery = ->
                f = $scope.filter
                query = {}
                if f.status != $scope.statuses[0]
                    query.status = f.status
                query

            $scope.export = ->
#                url = '/api/reports/summary_by_account.csv'
#                $window.open url + '?' + $httpParamSerializer getQuery()
#                return

    ]