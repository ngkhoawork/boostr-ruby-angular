@app.controller "ContactsAssignController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client', 'contact',
($scope, $modalInstance, $filter, Contact, Client, contact) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  Client.query(filter: 'all').$promise.then (clients) ->
    $scope.clients = clients

  $scope.searchObj = (name) ->
    if name == ""
      Client.query(filter: 'all').$promise.then (clients) ->
        $scope.clients = clients
    else
      Client.query({name: name}).$promise.then (clients) ->
        $scope.clients = clients
  $scope.assignClient = (client) ->
    contact = angular.copy($scope.contact)
    contact.client_id = client.id
    Contact.update(id: $scope.contact.id, contact: contact).then (contact) ->
      $modalInstance.close(contact)

  $scope.cancel = ->
    $modalInstance.close()
]
