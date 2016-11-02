@app.controller 'RevenueController',
['$scope', '$modal', '$filter', '$routeParams', '$location', '$q', 'IO',
($scope, $modal, $filter, $routeParams, $location, $q, IO) ->

  $scope.revenueFilters = [
    { name: 'IOs', param: '' }
    { name: 'Programmatic', param: 'programmatic' }
    { name: 'Upside Revenues', param: 'upside' }
    { name: 'At Risk Revenues', param: 'risk' }
  ]

  if $routeParams.filter
    _.each $scope.revenueFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.revenueFilter = filter
  else
    $scope.revenueFilter = $scope.revenueFilters[0]

  $scope.searchText = ''

  $scope.init = ->
    IO.all({filter: $scope.revenueFilter.param}).then (ios) ->
      $scope.revenue = ios

  $scope.filterRevenues = (filter) ->
    $scope.revenueFilter = filter
    $scope.init()

  $scope.go = (path) ->
    $location.path(path)

  $scope.init()
]
