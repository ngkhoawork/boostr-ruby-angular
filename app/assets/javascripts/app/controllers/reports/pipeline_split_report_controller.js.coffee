@app.controller 'PipelineSplitReportController',
    ['$scope', '$window', '$location', '$httpParamSerializer', '$routeParams', 'Report', 'Team', 'Seller', 'Stage'
    ( $scope,   $window,   $location,   $httpParamSerializer,   $routeParams,   Report,   Team,   Seller,   Stage ) ->

            $scope.deals = []
            $scope.teams = []
            $scope.sellers = []
            $scope.stages = []
            $scope.statuses = [
                {id: 'all', name: 'All'}
                {id: 'open', name: 'Open'},
                {id: 'closed', name: 'Closed'},
            ]
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

            emptyFilter = {id: null, name: 'All'}

            defaultFilter =
                team: emptyFilter
                seller: emptyFilter
                stages: []
                status: $scope.statuses[1]

            $scope.filter = angular.copy defaultFilter
            appliedFilter = null

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
                appliedFilter = angular.copy $scope.filter
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
                query.status = f.status.id if f.status.id
                query


            getReport = (query) ->
                Report.split_adjusted(query).$promise.then (data) ->
                    $scope.deals = data
                    calcTotals(data)

            calcTotals = (deals) ->
                t = $scope.totals
                _.each t, (val, key) -> t[key] = 0 #reset values
                _.each deals, (deal) ->
                    budget = parseInt(deal.split_budget) || 0
                    t.pipelineUnweighted += budget
                    t.pipelineWeighted += budget * deal.stage.probability / 100
                t.pipelineRatio = (Math.round(t.pipelineWeighted / t.pipelineUnweighted * 100) / 100) || 0
                t.deals = deals.length
                t.aveDealSize = t.pipelineUnweighted / deals.length

            $scope.getPipelineUnweighted = ->
                _.reduce($scope.deals, (res, deal) ->
                    res += parseInt(deal.split_budget) || 0
                , 0)

            $scope.getPipelineWeighted = ->
                _.reduce($scope.deals, (res, deal) ->
                    res += parseInt(deal.split_budget * (deal.stage.probability / 100)) || 0
                , 0)

            $scope.$watch 'filter.team', (team, prevTeam) ->
                if team.id then $scope.filter.seller = emptyFilter
                Seller.query({id: team.id || 'all'}).$promise.then (sellers) ->
                    $scope.sellers = _.sortBy sellers, 'name'
                    $scope.sellers.unshift(emptyFilter)

            Team.all(all_teams: true).then (teams) ->
                $scope.teams = teams
                $scope.teams.unshift emptyFilter

#            Seller.query({id: 'all'}).$promise.then (sellers) ->
#                $scope.sellers = sellers
#                $scope.sellers.unshift emptyFilter


            Stage.query().$promise.then (stages) ->
                $scope.stages = _.filter stages, (stage) -> stage.active
                $scope.stages.unshift emptyFilter

            $scope.export = ->
                url = '/api/reports/split_adjusted.csv'
                $window.open url + '?' + $httpParamSerializer getQuery()
                return

    ]