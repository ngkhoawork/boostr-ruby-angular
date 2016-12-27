@app.controller "BpEstimatesAssignController",
['$scope', '$modalInstance', '$filter', 'BpEstimate', 'User', 'bpEstimate'
($scope, $modalInstance, $filter, BpEstimate, User, bpEstimate) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.bpEstimate = bpEstimate
  $scope.searchText = ""
  User.query().$promise.then (sellers) ->
    $scope.sellers = sellers

  $scope.assignUser = (user) ->
    bpEstimate = angular.copy($scope.bpEstimate)
    bpEstimate.user_id = user.id
    BpEstimate.update(id: bpEstimate.id, bp_id: bpEstimate.bp_id, bp_estimate: bpEstimate).then (bpEstimate) ->
      $modalInstance.close(bpEstimate)

  $scope.cancel = ->
    $modalInstance.close()
]
