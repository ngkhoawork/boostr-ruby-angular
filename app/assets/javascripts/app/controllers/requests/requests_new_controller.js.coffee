@app.controller "RequestsNewController",
['$scope', '$rootScope', '$modalInstance', 'Request', 'requestable', 'requestable_type', 'deal_id'
($scope, $rootScope, $modalInstance, Request, requestable, requestable_type, deal_id) ->

  $scope.formType = "New"
  $scope.request = {
    requestable_type: $scope.requestable_type,
    requestable_id: requestable.id,
    deal_id: deal_id
  }

  $scope.createRequest = () ->
    Request.create(request: $scope.request).then(
      (request) ->
        $rootScope.$broadcast 'newRequest', request
        $modalInstance.close()
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
