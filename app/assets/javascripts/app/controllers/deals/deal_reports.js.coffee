@app.controller 'DealReportsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Deal', 'Field', 'Seller', 'Team', 'TimePeriod', 'CurrentUser',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Deal, Field, Seller, Team, TimePeriod, CurrentUser) ->
      $scope.sortType     = 'name'
      $scope.sortReverse  = false
      $scope.filterOpen = false
      $scope.teams = []
      $scope.types = []
      $scope.sources = []
      $scope.timePeriods = []

      defaultSeller = {id: 'all', name: 'All', first_name: 'All'}
      $scope.filter =
        team: {id: null, name: 'All'}
        status: {id: 'open', name: 'Open'}
        type: {id: 'all', name: 'All'}
        source: {id: 'all', name: 'All'}
        seller: defaultSeller
        timePeriod: {id: 'all', name: 'All'}
      $scope.selectedTeam = $scope.filter.team
      $scope.statuses = [
        {id: 'all', name: 'All'}
        {id: 'open', name: 'Open'},
        {id: 'closed', name: 'Closed'},
      ]

      $scope.init = ->
        CurrentUser.get().$promise.then (user) ->
          if user.user_type is 1 || user.user_type is 2
            $scope.filter.seller = user
          getData()
          Field.defaults({}, 'Deal').then (fields) ->
            client_types = Field.findDealTypes(fields)
            $scope.types.push({name:'All', id:'all'})
            client_types.options.forEach (option) ->
              $scope.types.push(option)

            sources = Field.findSources(fields)
            $scope.sources.push({name:'All', id:'all'})
            sources.options.forEach (option) ->
              $scope.sources.push(option)

          Seller.query({id: 'all'}).$promise.then (sellers) ->
            $scope.sellers = sellers
            $scope.sellers.unshift(defaultSeller)

          TimePeriod.all().then (timePeriods) ->
            $scope.timePeriods = angular.copy timePeriods
            $scope.timePeriods.unshift({name:'All', id:'all'})

          Team.all(all_teams: true).then (teams) ->
  #          all_members = []
  #          all_leaders = []
  #          _.each teams, (team) ->
  #            all_members = all_members.concat(team.members)
  #            all_leaders = all_leaders.concat(team.leaders)
            #          $scope.teams = teams
            $scope.teams = teams
            $scope.teams.unshift {id: null, name: 'All'}

      $scope.init()

      $scope.$watch 'selectedTeam', (nextTeam, prevTeam) ->
        if nextTeam.id then $scope.filter.seller = defaultSeller
        $scope.setFilter('team', nextTeam)
        Seller.query({id: nextTeam.id || 'all'}).$promise.then (sellers) ->
          $scope.sellers = sellers
          $scope.sellers.unshift(defaultSeller)

      $scope.setFilter = (key, value) ->
        if $scope.filter[key]is value
          return
        $scope.filter[key] = value
        getData()

      $scope.resetFilter = ->
        $scope.filter =
          team: {id: null, name: 'All'}
          status: {id: 'open', name: 'Open'}
          type: {id: 'all', name: 'All'}
          source: {id: 'all', name: 'All'}
          seller: defaultSeller
          timePeriod: {id: 'all', name: 'All'}
        $scope.selectedTeam = $scope.filter.team
        getData()

      getData = () =>
        f = $scope.filter
        query =
          status: f.status.id
          type: f.type.id
          source: f.source.id
        if f.timePeriod.id != 'all' then query.time_period_id = f.timePeriod.id
        if $scope.filter.seller.id != defaultSeller.id
          query.filter = 'user'
          query.user_id = f.seller.id
        else
          query.filter = 'selected_team'
          query.team_id = f.team.id || 'all'


        Deal.pipeline_report(query).then (data) ->
          $scope.deals = data[0].deals
          $scope.productRange = data[0].range
          $scope.deals = _.map $scope.deals, (deal) ->
            products = []
            _.each $scope.productRange, (range) ->
              products.push($scope.findDealProductBudgetBudget(deal.deal_product_budgets, range))
            deal.products = products
            deal

      $scope.go = (path) ->
        $location.path(path)

      $scope.findDealProductBudgetBudget = (dealProductBudgets, productTime) ->
        result =  _.find dealProductBudgets, (dealProductBudget) ->
          if (dealProductBudget.start_date == productTime)
            return dealProductBudget
        if result then result.budget else 0

      $scope.changeFilter = (filterType) ->
        $scope.filterOpen = filterType

#      $scope.isOpen = (deal) ->
#        return deal.stage.open == $scope.filterOpen

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      $scope.getHtml = (html) ->
        $sce.trustAsHtml(html)

      $scope.exportReports = ->
        $window.open('/api/deals/pipeline_report.csv?team_id=' + $scope.filter.team.id || 'all' + '&status=' + $scope.filter.status.id)

  ]
