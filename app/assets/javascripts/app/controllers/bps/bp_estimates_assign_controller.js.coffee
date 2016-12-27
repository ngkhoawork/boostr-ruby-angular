@app.controller "BpEstimatesAssignController",
['$scope', '$modalInstance', '$filter', 'BpEstimate', 'Client', 'bpEstimate'
($scope, $modalInstance, $filter, BpEstimate, Client, bpEstimate) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.bpEstimate = bpEstimate
  $scope.searchText = ""
  Client.sellers(id: bpEstimate.client_id).$promise.then (sellers) ->
    $scope.sellers = sellers

  $scope.assignUser = (user) ->
    bpEstimate = angular.copy($scope.bpEstimate)
    bpEstimate.user_id = user.id
    BpEstimate.update(id: bpEstimate.id, bp_id: bpEstimate.bp_id, bp_estimate: bpEstimate).then (bpEstimate) ->
      $modalInstance.close(bpEstimate)

  $scope.searchObj = (name) ->
    if name == ""
      Client.sellers(id: bpEstimate.client_id).$promise.then (sellers) ->
        $scope.sellers = sellers
    else
      Client.sellers(id: bpEstimate.client_id, name: name).$promise.then (sellers) ->
        $scope.sellers = sellers
  $scope.cancel = ->
    $modalInstance.close()
]
