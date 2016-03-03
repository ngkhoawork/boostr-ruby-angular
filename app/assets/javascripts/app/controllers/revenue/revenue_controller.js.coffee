@app.controller 'RevenueController',
['$scope', '$modal', '$filter', '$routeParams', '$q', 'Revenue',
($scope, $modal, $filter, $routeParams, $q, Revenue) ->

  $scope.revenueFilters = [
    { name: 'All Revenues', param: '' }
    { name: 'Revenue Upside', param: 'upside' }
    { name: 'Revenue at Risk', param: 'risk' }
  ]

  if $routeParams.filter
    _.each $scope.revenueFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.revenueFilter = filter
  else
    $scope.revenueFilter = $scope.revenueFilters[0]

  $scope.init = ->
    Revenue.all({filter: $scope.revenueFilter.param}).then (revenue) ->
      $scope.revenue = revenue

  $scope.showUploadModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/revenue_upload.html'
      size: 'lg'
      controller: 'RevenueUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.filterRevenues = (filter) ->
    $scope.revenueFilter = filter
    $scope.init()

  $scope.$on 'updated_revenues', ->
    $scope.init()

  $scope.init()
]