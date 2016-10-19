@app.controller 'DealReportsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', '$q', '$sce', 'Deal', 'Team',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, $q, $sce, Deal, Team) ->
      $scope.sortType     = 'name'
      $scope.sortReverse  = false
      $scope.filterOpen = true
      $scope.init = ->
        Team.all(all_teams: true).then (teams) ->
          all_members = []
          all_leaders = []
          _.each teams, (team) ->
            all_members = all_members.concat(team.members)
            all_leaders = all_leaders.concat(team.leaders)
          #          $scope.teams = teams
          $scope.teams = [{
            id: 0,
            name:'All Deals',
            children: teams,
            members: all_members,
            leaders: all_leaders,
            members_count: all_members.length
          }]
          $scope.selectedTeam = $scope.teams[0]
          $scope.selectedTeamId = $scope.selectedTeam.id

      $scope.init()

      $scope.$watch('selectedTeam', () =>
        if ($scope.selectedTeam)
          $scope.selectedTeamId = $scope.selectedTeam.id
          $scope.selectedMember = null
          $scope.selectedMemberId = null
          $scope.selectedMemberList = _.map $scope.selectedTeam.members, (item) =>
            return item.id
          $scope.selectedLeaderList = _.map $scope.selectedTeam.leaders, (item) =>
            return item.id
          fetchData()
      , true);

      fetchData = () =>
        $q.all({ dealData: Deal.pipeline_report({filter: 'selected_team', team_id: $scope.selectedTeamId}) }).then (data) ->
          $scope.deals = data.dealData[0].deals
          $scope.productRange = data.dealData[0].range
          $scope.deals = _.map $scope.deals, (deal) ->
            products = []
            _.each $scope.productRange, (range) ->
              products.push($scope.findDealProductBudgetBudget(deal.deal_product_budgets, range) / 100)
            deal.products = products
            return deal

      $scope.go = (path) ->
        $location.path(path)

      $scope.findDealProductBudgetBudget = (dealProductBudgets, productTime) ->
        result =  _.find dealProductBudgets, (dealProductBudget) ->
          if (dealProductBudget.start_date == productTime)
            return dealProductBudget

        if result
          return result.budget
        else
          return 0

      $scope.changeFilter = (filterType) ->
        $scope.filterOpen = filterType

      $scope.isOpen = (deal) ->
        return deal.stage.open == $scope.filterOpen

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      $scope.getHtml = (html) ->
        return $sce.trustAsHtml(html)

      $scope.exportReports = ->
        $window.open('/api/deals/pipeline_report.csv?team_id=' + $scope.selectedTeamId)
        return true

  ]
