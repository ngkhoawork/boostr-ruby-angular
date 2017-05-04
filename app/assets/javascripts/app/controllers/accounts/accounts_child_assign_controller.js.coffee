@app.controller "AccountsChildAssignController",
['$scope', '$modal', '$modalInstance', '$filter', 'Client', 'parentClient'
($scope, $modal, $modalInstance, $filter, Client, parentClient) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.parentClient = parentClient
  $scope.searchText = ""
  Client.query({filter: 'all', page: 1, client_type_id: $scope.parentClient.client_type.option_id}).$promise.then (clients) ->
    $scope.clients = clients

  $scope.searchObj = (search) ->
    if search == ""
      Client.query({filter: 'all', page: 1, client_type_id: $scope.parentClient.client_type.option_id}).$promise.then (clients) ->
        $scope.clients = clients
    else
      Client.query({filter: 'all', search: search, page: 1, client_type_id: $scope.parentClient.client_type.option_id}).$promise.then (clients) ->
        $scope.clients = clients

  $scope.showClientNewModal = ->
    newClient = {}
    newClient.client_type = $scope.parentClient.client_type
    newClient.client_type_id = $scope.parentClient.client_type_id
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          newClient
    .result.then (created_client) ->
      if (created_client)
        $scope.assignClient(created_client)

  $scope.assignClient = (client) ->
    client.parent_client_id = $scope.parentClient.id
    client.client_type = $scope.parentClient.client_type
    client.$update(
      (data) ->
        $modalInstance.close(data)
        $scope.$parent.$broadcast 'updated_current_client',
    )

  $scope.cancel = ->
    $modalInstance.close()
]