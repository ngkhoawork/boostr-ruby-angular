@app.controller "RequestsController",
['$scope', '$rootScope', 'Request'
($scope, $rootScope, Request) ->

  $scope.request_types = Request.request_types
  $scope.statuses = Request.statuses
  $scope.request_type_filter = $scope.request_types[0]
  $scope.status_filter = $scope.statuses[0]

  $scope.init = ->
    Request.all(request_type: $scope.request_type_filter, status: $scope.status_filter).then (requests) ->
      $scope.requests = requests

  $scope.typeFilter = (type) ->
    $scope.request_type_filter = type
    $scope.init()

  $scope.statusFilter = (status) ->
    $scope.status_filter = status
    $scope.init()

  $scope.init()
]
