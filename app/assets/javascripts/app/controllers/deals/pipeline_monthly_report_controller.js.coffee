@app.controller 'PipelineMonthlyReportController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Deal', 'Field', 'Product', 'Seller', 'Team', 'TimePeriod', 'CurrentUser', 'DealCustomFieldName', 'Stage', '$httpParamSerializer'
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Deal, Field, Product, Seller, Team, TimePeriod, CurrentUser, DealCustomFieldName, Stage, $httpParamSerializer) ->
      $scope.sortType     = 'name'
      $scope.sortReverse  = false
      $scope.filterOpen = false
      $scope.page = 1
      $scope.deals = []
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

      defaultUser = {id: 'all', name: 'All', first_name: 'All'}
      currentUser = null

      $scope.defaultFilter =
        team: {id: null, name: 'All'}
        type: {id: 'all', name: 'All'}
        source: {id: 'all', name: 'All'}
        product: {id: 'all', name: 'All'}
        seller: defaultUser
        timePeriod: {id: 'all', name: 'All'}
        stages: []
      $scope.filter = angular.copy $scope.defaultFilter
      $scope.selectedTeam = $scope.filter.team

      $scope.init = ->
        getDealCustomFieldNames()
        CurrentUser.get().$promise.then (user) ->
          if user.user_type is 1 || user.user_type is 2
            currentUser = user
            $scope.filter.seller = user
          Product.all().then (products) ->
            $scope.products = products
            $scope.products = _.sortBy $scope.products, 'name'
            $scope.products.unshift({name:'All', id:'all'})

          Field.defaults({}, 'Deal').then (fields) ->
            client_types = Field.findDealTypes(fields)
            client_types.options.forEach (option) ->
              $scope.types.push(option)
            $scope.types = _.sortBy $scope.types, 'name'
            $scope.types.unshift({name:'All', id:'all'})

            sources = Field.findSources(fields)
            sources.options.forEach (option) ->
              $scope.sources.push(option)
            $scope.sources = _.sortBy $scope.sources, 'name'
            $scope.sources.unshift({name:'All', id:'all'})

          Seller.query({id: 'all'}).$promise.then (sellers) ->
            $scope.sellers = sellers
            $scope.sellers = _.sortBy $scope.sellers, 'name'
            $scope.sellers.unshift(defaultUser)

          Stage.query().$promise.then (stages) ->
              $scope.stages = _.filter stages, (stage) -> stage.active

          TimePeriod.all().then (timePeriods) ->
            $scope.timePeriods = angular.copy timePeriods
            $scope.timePeriods = _.sortBy $scope.timePeriods, 'start_date'
            $scope.timePeriods.unshift({name:'All', id:'all'})

          Team.all(all_teams: true).then (teams) ->
            $scope.teams = teams
            $scope.teams.unshift {id: null, name: 'All'}

      getDealCustomFieldNames = () ->
        DealCustomFieldName.all().then (dealCustomFieldNames) ->
          $scope.dealCustomFieldNames = dealCustomFieldNames
      $scope.init()

      $scope.$watch 'selectedTeam', (nextTeam, prevTeam) ->
        if nextTeam.id then $scope.filter.seller = defaultUser
        $scope.setFilter('team', nextTeam)
        Seller.query({id: nextTeam.id || 'all'}).$promise.then (sellers) ->
          $scope.sellers = sellers
          $scope.sellers.unshift(defaultUser)

      $scope.setFilter = (key, value) ->
        if key == 'stages'
          $scope.filter[key] = if value.id then _.union $scope.filter[key], [value] else []
        else
          if $scope.filter[key] is value
            return
          $scope.filter[key] = value

      $scope.removeFilter = (key, item) ->
        $scope.filter[key] = _.reject $scope.filter[key], (row) -> row.id == item.id

      $scope.resetFilter = ->
        $scope.filter = angular.copy $scope.defaultFilter
        $scope.selectedTeam = $scope.filter.team
        if currentUser.user_type is 1 || currentUser.user_type is 2
          $scope.filter.seller = currentUser

      $scope.isLoading = false
      $scope.loadMoreData = ->
        if $scope.saved_query && !$scope.isLoading && $scope.deals && $scope.deals.length < Deal.pipeline_report_count()
          $scope.page = $scope.page + 1

          getData($scope.saved_query)

      $scope.applyFilter = ->
        $scope.page = 1
        $scope.saved_query = constructQuery()

#        if $scope.saved_query['stage_ids[]'].length == 0
#          alert("Please specify a stage.");
#          return

        getTotals($scope.saved_query)
        getData($scope.saved_query)

      query = null

      constructQuery = () =>
        f = $scope.filter
        query =
          per: 100
          type: f.type.id
          source: f.source.id
          'product_id': f.product.id
          'stage_ids[]': _.map f.stages, (stage) -> stage.id if f.stages.length
        if f.timePeriod.id != 'all' then query.time_period_id = f.timePeriod.id
        if $scope.filter.seller.id != defaultUser.id
          query.filter = 'user'
          query.user_id = f.seller.id
        else
          query.filter = 'selected_team'
          query.team_id = f.team.id || 'all'

        query

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
        query = constructQuery()

        Deal.pipeline_report_totals(query).then (data) ->
          t = $scope.totals
          t.pipelineUnweighted = data.totals.pipeline_unweighted
          t.pipelineWeighted = data.totals.pipeline_weighted
          t.deals = data.totals.total_deals
          t.pipelineRatio = data.totals.ratio
          t.aveDealSize = data.totals.average_deal_size

      $scope.go = (path) ->
        $location.path(path)

      $scope.findDealProductBudgetBudget = (dealProductBudgets, productTime) ->
        productTimeDate = new Date(productTime)
        result =  _.find dealProductBudgets, (dealProductBudget) ->
          dpbDate = new Date(dealProductBudget.start_date)
          if dpbDate.getFullYear() == productTimeDate.getFullYear() && dpbDate.getMonth() == productTimeDate.getMonth()
            return dealProductBudget
        if result then result.budget else 0

      $scope.changeFilter = (filterType) ->
        $scope.filterOpen = filterType

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      $scope.getHtml = (html) ->
        $sce.trustAsHtml(html)

      $scope.exportReports = ->
        query = $httpParamSerializer(constructQuery())
        $window.open('/api/deals/pipeline_report.csv?' + query)
        true

      $scope.showEmailsModal = (activity) ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/activity_emails.html'
          size: 'lg'
          controller: 'ActivityEmailsController'
          backdrop: 'static'
          keyboard: false
          resolve:
            activity: ->
              activity
  ]
