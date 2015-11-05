@app.controller 'DealsController',
['$scope', '$modal', '$filter', '$routeParams', '$q', '$location', 'Deal', 'Stage',
($scope, $modal, $filter, $routeParams, $q, $location, Deal, Stage) ->

  $scope.dealFilters = [
    { name: 'My Deals', param: '' }
    { name: 'My Team\'s Deals', param: 'team' }
    { name: 'All Deals', param: 'company' }
  ]

  if $routeParams.filter
    _.each $scope.dealFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.dealFilter = filter
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

  $scope.filterDeals = (filter) ->
    $scope.dealFilter = filter
    $scope.init()

  $scope.$on 'updated_deals', ->
    $scope.init()

  $scope.init()
]
