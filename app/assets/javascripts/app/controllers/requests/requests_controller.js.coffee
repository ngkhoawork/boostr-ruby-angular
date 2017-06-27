@app.controller "RequestsController",
['$scope', '$rootScope', 'Request', 'CurrentUser', '$filter', '$modal'
($scope, $rootScope, Request, CurrentUser, $filter,  $modal) ->

  $scope.request_types = Request.request_types
  $scope.statuses = Request.statuses
  $scope.requestUrl = "api/requests"
  $scope.requestUrlParams = {
    request_type: $scope.request_types[0],
    status: $scope.statuses[0]
  }

  CurrentUser.get().$promise.then (user) ->
    $scope.current_user = user

  $scope.typeFilter = (type) ->
    $scope.requestUrlParams.request_type = type

  $scope.statusFilter = (status) ->
    $scope.requestUrlParams.status = status

  $scope.assignRequest = (request, event) ->
    event.stopPropagation()

    request.assignee = $scope.current_user
    request.assignee_id = $scope.current_user.id

    Request.update(request: request, id: request.id).then(
      (data) ->
        $scope.$broadcast 'pagination:reload'
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
    )

  $scope.showEditRequestModal = (request) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/request_form.html'
      size: 'md'
      controller: 'RequestsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        request: ->
          request

]
