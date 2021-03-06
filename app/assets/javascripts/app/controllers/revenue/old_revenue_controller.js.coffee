@app.controller 'OldRevenueController',
['$scope', '$modal', '$filter', '$routeParams', '$q', 'Revenue',
($scope, $modal, $filter, $routeParams, $q, Revenue) ->

  $scope.revenueFilters = [
    { name: 'My Revenues', param: '' }
    { name: 'My Team\'s Revenues', param: 'team' }
    { name: 'All Revenues', param: 'all' }
    { name: 'Upside Revenues', param: 'upside' }
    { name: 'At Risk Revenues', param: 'risk' }
  ]

  if $routeParams.filter
    _.each $scope.revenueFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.revenueFilter = filter
  else
    $scope.revenueFilter = $scope.revenueFilters[0]

  $scope.init = ->
    Revenue.query({filter: $scope.revenueFilter.param}).$promise.then (revenue) ->
      $scope.revenue = revenue

  $scope.showUploadModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/revenue_upload.html'
      size: 'lg'
      controller: 'OldRevenueUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.filterRevenues = (filter) ->
    $scope.revenueFilter = filter
    $scope.init()

  $scope.$on 'updated_revenues', ->
    $scope.init()

  $scope.init()
]
