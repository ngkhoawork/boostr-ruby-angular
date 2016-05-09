@app.controller 'DealsController',
['$rootScope', '$scope', '$modal', '$filter', '$routeParams', '$q', '$location', '$window', 'Deal', 'Stage',
($rootScope, $scope, $modal, $filter, $routeParams, $q, $location, $window, Deal, Stage) ->

  $scope.dealFilters = [
    { name: 'My Deals', param: '' }
    { name: 'My Team\'s Deals', param: 'team' }
    { name: 'All Deals', param: 'company' }
  ]

  $scope.activeSort = {}

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
      $scope.activeSort = {}

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
    $scope.activeSort = {}

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

  $scope.sort = (field) ->
    if field == 'Name'
      $scope.filteredDeals.sort (a, b) ->
        a.name.localeCompare(b.name)
    else if field == 'Advertiser'
      $scope.filteredDeals.sort (a, b) ->
        a.advertiser.name.localeCompare(b.advertiser.name)
    else if field == 'Stage'
      $scope.filteredDeals.sort (a, b) ->
        a.stage.name.localeCompare(b.stage.name)
    else if field == 'Start Date'
      $scope.filteredDeals.sort (a, b) ->
        a.start_date.localeCompare(b.start_date)
    else if field == 'Budget'
      $scope.filteredDeals.sort (a, b) ->
        a.budget < b.budget
    $scope.activeSort = field

  $scope.init()
]
