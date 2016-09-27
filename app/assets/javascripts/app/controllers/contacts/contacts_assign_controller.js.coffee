@app.controller "ContactsAssignController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client', 'contact', 'typeId'
($scope, $modalInstance, $filter, Contact, Client, contact, typeId) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  if typeId
    Client.query({client_type_id: typeId}).$promise.then (clients) ->
      $scope.clients = clients
  else
    Client.query(filter: 'all').$promise.then (clients) ->
      $scope.clients = clients

  $scope.searchObj = (name) ->
    if typeId
      if name == ""
        Client.query({client_type_id: typeId}).$promise.then (clients) ->
          $scope.clients = clients
      else
        Client.query({name: name, client_type_id: typeId}).$promise.then (clients) ->
          $scope.clients = clients
    else
      if name == ""
        Client.query(filter: 'all').$promise.then (clients) ->
          $scope.clients = clients
      else
        Client.query({name: name}).$promise.then (clients) ->
          $scope.clients = clients

  $scope.assignClient = (client) ->
    contact = angular.copy($scope.contact)
    contact.client_id = client.id
    Contact._update(id: $scope.contact.id, contact: contact).then (contact) ->
      $modalInstance.close(contact)

  $scope.cancel = ->
    $modalInstance.close()
]
