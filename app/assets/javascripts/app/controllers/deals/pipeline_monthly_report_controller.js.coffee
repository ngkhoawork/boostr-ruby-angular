@app.controller 'PipelineMonthlyReportController', [
    '$scope', '$modal', '$window', '$sce', 'Deal', 'Field', 'Product', 'Seller', 'Team', 'TimePeriod', 'DealCustomFieldName', 'Stage', '$httpParamSerializer'
    ($scope,   $modal,   $window,   $sce,   Deal,   Field,   Product,   Seller,   Team,   TimePeriod,   DealCustomFieldName,   Stage,   $httpParamSerializer) ->
      $scope.page = 1
      $scope.teams = []
      $scope.types = []
      $scope.stages = []
      $scope.sources = []
      $scope.products = []
      $scope.timePeriods = []
      $scope.totals =
        pipelineUnweighted: 0
        pipelineWeighted: 0
        pipelineRatio: 0
        deals: 0
        aveDealSize: 0

      appliedFilter = null

      DealCustomFieldName.all().then (dealCustomFieldNames) ->
        $scope.dealCustomFieldNames = dealCustomFieldNames
      Product.all().then (products) ->
        $scope.products = products

      Field.defaults({}, 'Deal').then (fields) ->
        client_types = Field.findDealTypes(fields)
        client_types.options.forEach (option) ->
          $scope.types.push(option)

        sources = Field.findSources(fields)
        sources.options.forEach (option) ->
          $scope.sources.push(option)

      ($scope.updateSellers = (team) ->
        Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
          $scope.sellers = sellers
      )()

      Stage.query().$promise.then (stages) ->
          $scope.stages = _.filter stages, (stage) -> stage.active

      TimePeriod.all().then (timePeriods) ->
        $scope.timePeriods = angular.copy timePeriods

      Team.all(all_teams: true).then (teams) ->
        $scope.teams = teams

      $scope.isLoading = false
      $scope.loadMoreData = ->
        if appliedFilter && !$scope.isLoading && $scope.deals && $scope.deals.length < Deal.pipeline_report_count()
          $scope.page = $scope.page + 1
          getData(appliedFilter)

      $scope.onFilterApply = (query) ->
        $scope.page = 1
        query.per = 100
        if query.user_id
          query.filter = 'user'
        else
          query.filter = 'selected_team'
          query.team_id = query.team_id || 'all'
        appliedFilter = query
        getTotals(query)
        getData(query)

      getData = (query) ->
        $scope.isLoading = true
        query.page = $scope.page

        Deal.pipeline_report(query).then (data) ->
          if $scope.page > 1
            $scope.deals = $scope.deals.concat(data[0].deals)
          else
            $scope.deals = data[0].deals
            $scope.productRange = data[0].range

          $scope.isLoading = false

      getTotals = (query) ->
        Deal.pipeline_report_totals(query).then (data) ->
          t = $scope.totals
          t.pipelineUnweighted = data.totals.pipeline_unweighted
          t.pipelineWeighted = data.totals.pipeline_weighted
          t.deals = data.totals.total_deals
          t.pipelineRatio = data.totals.ratio
          t.aveDealSize = data.totals.average_deal_size

      $scope.findDealProductBudgetBudget = (dealProductBudgets, productTime) ->
        productTimeDate = new Date(productTime)
        result =  _.find dealProductBudgets, (dealProductBudget) ->
          dpbDate = new Date(dealProductBudget.start_date)
          if dpbDate.getFullYear() == productTimeDate.getFullYear() && dpbDate.getMonth() == productTimeDate.getMonth()
            return dealProductBudget
        if result then result.budget else 0

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      $scope.export = ->
        url = '/api/deals/pipeline_report.csv'
        $window.open url + '?' + $httpParamSerializer appliedFilter
        return
]
