@app.controller "RequestsNewController",
['$scope', '$rootScope', '$modalInstance', 'Request', 'requestable', 'requestable_type', 'deal_id'
($scope, $rootScope, $modalInstance, Request, requestable, requestable_type, deal_id) ->

  $scope.formType = "New"
  $scope.statuses = [Request.statuses[0]]
  $scope.request = requestable.request || {
    requestable_type: requestable_type,
    requestable_id: requestable.id,
    deal_id: deal_id,
    request_type: 'Revenue',
    status: 'New'
  }

  $scope.name = switch requestable_type
    when "Io" then "IO #{requestable.id}"
    when "ContentFee" then "#{requestable.product.full_name}"
    when "DisplayLineItem" then "Line Number #{requestable.line_number}"
    else ''

  $scope.saveRequest = () ->
    if requestable.request
      Request.update(request: $scope.request, id: $scope.request.id).then(
        (request) ->
          requestable.request = request
          $modalInstance.close()
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
          $scope.buttonDisabled = false
      )
    else
      Request.create(request: $scope.request).then(
        (request) ->
          requestable.request = request
          $modalInstance.close()
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
          $scope.buttonDisabled = false
      )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
