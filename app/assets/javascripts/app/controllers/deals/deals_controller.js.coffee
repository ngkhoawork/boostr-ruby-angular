@app.controller 'DealsController',
['$scope', '$modal', '$filter', '$q', '$location', 'Deal', 'Stage',
($scope, $modal, $filter, $q, $location, Deal, Stage) ->

  $scope.init = ->
    $q.all({ deals: Deal.all(), stages: Stage.all() }).then (data) ->
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

  $scope.$on 'updated_deals', ->
    $scope.init()

  $scope.go = (path) ->
    $location.path(path)

  $scope.init()
]
