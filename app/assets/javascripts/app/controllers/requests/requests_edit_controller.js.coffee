@app.controller "RequestsEditController",
['$scope', '$rootScope', '$modalInstance', 'Request', 'request'
($scope, $rootScope, $modalInstance, Request, request) ->

  $scope.formType = "Edit"
  $scope.statuses = Request.statuses
  $scope.request = request

  $scope.name = $scope.request.requestable.name

  $scope.saveRequest = () ->
    Request.update(request: $scope.request, id: $scope.request.id).then(
      (request) ->
        $modalInstance.close()
        $rootScope.$broadcast 'pagination:reload'
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
    )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
