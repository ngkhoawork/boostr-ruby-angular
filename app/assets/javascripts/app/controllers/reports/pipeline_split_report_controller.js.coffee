@app.controller 'PipelineSplitReportController',
    ['$scope', '$window', '$location', '$httpParamSerializer', '$routeParams', 'Report', 'Team', 'Seller', 'Stage'
    ( $scope,   $window,   $location,   $httpParamSerializer,   $routeParams,   Report,   Team,   Seller,   Stage ) ->

            $scope.data = []
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
                team: emptyFilter
                seller: emptyFilter
                stages: []
                status: $scope.statuses[1]

            $scope.setFilter = (key, val, init) ->
                if key == 'stages'
                    $scope.filter[key] = if val.id then _.union $scope.filter[key], [val] else []
                else
                    $scope.filter[key] = val
                applyFilter() if !init

            $scope.removeFilter = (key, item) ->
                $scope.filter[key] = _.reject $scope.filter[key], (row) -> row.id == item.id
                applyFilter()

            applyFilter = ->
                query = getQuery()
#                $location.search(query)
                getReport query

            $scope.resetFilter = ->
                $scope.filter.team = emptyFilter
                $scope.filter.seller = emptyFilter
                $scope.filter.stages = []
                $scope.filter.status = $scope.statuses[1]
                applyFilter()

            $scope.isNumber = _.isNumber

            getQuery = ->
                f = $scope.filter
                query = {}
                query.team_id = f.team.id if f.team.id
                query.seller_id = f.seller.id if f.seller.id
                query['stage_ids[]'] = _.map f.stages, (stage) -> stage.id if f.stages.length
                query.status = f.status.id if f.status.id
                query

            getReport = (query) ->
                Report.split_adjusted(query).$promise.then (data) ->
                    $scope.data = data
            getReport getQuery()

            $scope.$watch 'filter.team', (team, prevTeam) ->
                if team.id then $scope.filter.seller = emptyFilter
                Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
                    $scope.sellers = sellers
                    $scope.sellers.unshift(emptyFilter)
                applyFilter() if prevTeam != team

            Team.all(all_teams: true).then (teams) ->
                $scope.teams = teams
                $scope.teams.unshift emptyFilter

            Seller.query({id: 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
                $scope.sellers.unshift emptyFilter

            Stage.query().$promise.then (stages) ->
                $scope.stages = stages
                $scope.stages.unshift emptyFilter

            $scope.export = ->
                url = '/api/reports/split_adjusted.csv'
                $window.open url + '?' + $httpParamSerializer getQuery()
                return

    ]