@app.controller 'RevenueController',
['$scope', '$modal', '$filter', '$routeParams', '$location', '$q', 'IO',
($scope, $modal, $filter, $routeParams, $location, $q, IO) ->

  $scope.activeTab = 'ios'

  $scope.searchText = ''

  $scope.init = ->
    IO.all({}).then (ios) ->
      $scope.revenue = ios

  $scope.setActiveTab = (type) ->
    $scope.activeTab = type

  $scope.isActiveTab = (type) ->
    return $scope.activeTab == type

  $scope.go = (path) ->
    $location.path(path)

  $scope.init()
]
