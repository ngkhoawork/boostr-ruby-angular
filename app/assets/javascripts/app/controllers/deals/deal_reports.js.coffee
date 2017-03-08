@app.controller 'DealReportsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Deal', 'Field', 'Product', 'Seller', 'Team', 'TimePeriod', 'CurrentUser', 'DealCustomFieldName',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Deal, Field, Product, Seller, Team, TimePeriod, CurrentUser, DealCustomFieldName) ->
      $scope.sortType     = 'name'
      $scope.sortReverse  = false
      $scope.filterOpen = false
      $scope.teams = []
      $scope.types = []
      $scope.sources = []
      $scope.products = []
      $scope.timePeriods = []

      defaultUser = {id: 'all', name: 'All', first_name: 'All'}
      currentUser = null
      $scope.filter =
        team: {id: null, name: 'All'}
        status: {id: 'open', name: 'Open'}
        type: {id: 'all', name: 'All'}
        source: {id: 'all', name: 'All'}
        product: {id: 'all', name: 'All'}
        seller: defaultUser
        timePeriod: {id: 'all', name: 'All'}
      $scope.selectedTeam = $scope.filter.team
      $scope.statuses = [
        {id: 'all', name: 'All'}
        {id: 'open', name: 'Open'},
        {id: 'closed', name: 'Closed'},
      ]

      $scope.init = ->
        getDealCustomFieldNames()
        CurrentUser.get().$promise.then (user) ->
          if user.user_type is 1 || user.user_type is 2
            currentUser = user
            $scope.filter.seller = user
          getData()
          Product.all().then (products) ->
            $scope.products = products
            $scope.products.unshift({name:'All', id:'all'})

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
            $scope.sellers.unshift(defaultUser)

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
          product: {id: 'all', name: 'All'}
          seller: currentUser || defaultUser
          timePeriod: {id: 'all', name: 'All'}
        $scope.selectedTeam = $scope.filter.team
        getData()

      query = null
      getData = () =>
        f = $scope.filter
        query =
          status: f.status.id
          type: f.type.id
          source: f.source.id
          'product_id': f.product.id
        if f.timePeriod.id != 'all' then query.time_period_id = f.timePeriod.id
        if $scope.filter.seller.id != defaultUser.id
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
        productTimeDate = new Date(productTime)
        result =  _.find dealProductBudgets, (dealProductBudget) ->
          dpbDate = new Date(dealProductBudget.start_date)
          if dpbDate.getFullYear() == productTimeDate.getFullYear() && dpbDate.getMonth() == productTimeDate.getMonth()
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
        qs = for key, value of query
          key + '=' + value
        qs = qs.join('&')
        $window.open('/api/deals/pipeline_report.csv?' + qs)
        true

  ]
