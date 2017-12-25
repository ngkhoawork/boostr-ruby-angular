@app.controller 'PipelineSplitReportController', [
    '$scope', '$window', '$httpParamSerializer', 'Report', 'Team', 'Seller', 'Stage'
    ($scope,   $window,   $httpParamSerializer,   Report,   Team,   Seller,   Stage) ->

        $scope.teams = []
        $scope.sellers = []
        $scope.stages = []
        $scope.statuses = [
            {id: 'open', name: 'Open'},
            {id: 'closed', name: 'Closed'},
        ]
        $scope.totals =
            pipelineUnweighted: 0
            pipelineWeighted: 0
            pipelineRatio: 0
            deals: 0
            aveDealSize: 0

        appliedFilter = null

        $scope.isNumber = _.isNumber

        $scope.onFilterApply = (query) ->
            query.status = query.status || 'all'
            appliedFilter = query
            getReport query

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
            deals = _.uniq deals, 'deal_id'
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

        Team.all(all_teams: true).then (teams) ->
            $scope.teams = teams

        ($scope.updateSellers = (team) ->
            Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
        )()

        Stage.query().$promise.then (stages) ->
            $scope.stages = _.filter stages, (stage) -> stage.active

        $scope.export = ->
            url = '/api/reports/split_adjusted.csv'
            $window.open url + '?' + $httpParamSerializer appliedFilter
            return
]