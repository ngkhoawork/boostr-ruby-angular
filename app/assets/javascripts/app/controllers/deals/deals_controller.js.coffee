@app.controller 'DealsController',
['$rootScope', '$scope', '$modal', '$filter', '$routeParams', '$q', '$location', '$window', 'Deal', 'Stage',
($rootScope, $scope, $modal, $filter, $routeParams, $q, $location, $window, Deal, Stage) ->

  $scope.dealFilters = [
    { name: 'My Deals', param: '' }
    { name: 'My Team\'s Deals', param: 'team' }
    { name: 'All Deals', param: 'company' }
  ]

  $scope.sort =
    column: "name"
    direction: "asc"
    reset: ->
      @column = "name"
      @direction = "asc"
      @execute()

  if $routeParams.filter
    _.each $scope.dealFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.dealFilter = filter
        $rootScope.dealFilter = $scope.dealFilter
  else
    if $rootScope.dealFilter != undefined
      $scope.dealFilter = $rootScope.dealFilter
    else
      $scope.dealFilter = $scope.dealFilters[0]

  $scope.init = ->
    $q.all({ deals: Deal.all({filter: $scope.dealFilter.param}), stages: Stage.all() }).then (data) ->
      $scope.deals = data.deals
      $scope.stages = data.stages
      $scope.showStage('open')

  $scope.showModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'lg'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          {}

  $scope.showStage = (stage) ->
    if stage == 'open'
      $scope.getOpenStages()
      $scope.currentStage = 'open'
      $scope.filteredDeals = $scope.openStages
    else
      $scope.currentStage = stage.id
      $scope.filteredDeals = $filter('filter') $scope.deals, { stage_id: stage.id }
    $scope.sort.reset()

  $scope.getOpenStages = ->
    $scope.openStages = $filter('openDeals') $scope.deals, $scope.stages
    $scope.openStagesCount = $scope.openStages.length

  $scope.countDealsForStage = (stage) ->
    $filter('filter')($scope.deals, { stage_id: stage.id }).length

  $scope.delete = (deal) ->
    if confirm('Are you sure you want to delete "' +  deal.name + '"?')
      Deal.delete deal, ->
        $location.path('/deals')

  $scope.go = (path) ->
    $location.path(path)

  $scope.exportDeals = ->
    $window.open('/api/deals.zip')
    return true

  $scope.filterDeals = (filter) ->
    $scope.dealFilter = filter
    $rootScope.dealFilter = $scope.dealFilter
    $scope.init()

  $scope.$on 'updated_deals', ->
    $scope.init()

  $scope.sort.toggle = (field) ->
    direction = "asc"
    direction = "desc" if $scope.sort.column == field and $scope.sort.direction == "asc"
    $scope.sort.column = field
    $scope.sort.direction = direction
    $scope.sort.execute()

  $scope.sort.execute = ->
    $scope.filteredDeals.sort (a, b) ->
      switch $scope.sort.column
        when "advertiser"
          comparison = a.advertiser.name.localeCompare(b.advertiser.name)
        when "name"
          comparison = a.name.localeCompare(b.name)
        when "stage"
          comparison = a.stage.name.localeCompare(b.stage.name)
        when "start_date"
          comparison = a.start_date.localeCompare(b.start_date)
        else
          comparison = a.budget - b.budget
    $scope.filteredDeals.reverse() if $scope.sort.direction == "desc"

  $scope.init()
]
