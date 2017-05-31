@app.controller "RequestController",
['$scope', '$rootScope', 'Request', 'CurrentUser', '$filter', '$modal', '$routeParams'
($scope, $rootScope, Request, CurrentUser, $filter,  $modal, $routeParams) ->

  $scope.requests = []

  $scope.init = ->
    Request.get($routeParams.id).then (request) ->
      $scope.requests = [request]

  CurrentUser.get().$promise.then (user) ->
    $scope.current_user = user

  $scope.assignRequest = (request, event) ->
    event.stopPropagation()

    request.assignee = $scope.current_user
    request.assignee_id = $scope.current_user.id

    Request.update(request: request, id: request.id).then(
      (data) ->
        $scope.init()
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

  $scope.$on 'newRequest', (event, request) ->
    $scope.init()

  $scope.init()
]
