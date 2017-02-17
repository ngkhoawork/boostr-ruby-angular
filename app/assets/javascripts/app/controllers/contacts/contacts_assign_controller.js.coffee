@app.controller "ContactsAssignController",
['$scope', '$rootScope', '$modalInstance', '$filter', 'Contact', 'Client', 'contact', 'typeId', 'Field'
($scope, $rootScope, $modalInstance, $filter, Contact, Client, contact, typeId, Field) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  if typeId
    Client.query(filter: 'all', client_type_id: typeId).$promise.then (clients) ->
      $scope.clients = clients
  else
    Client.query(filter: 'all').$promise.then (clients) ->
      $scope.clients = clients

  $scope.searchObj = (name) ->
    if typeId
      if name == ""
        Client.query(filter: 'all', client_type_id: typeId).$promise.then (clients) ->
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

  Field.defaults({}, 'Client').then (fields) ->
    client_types = Field.findClientTypes(fields)
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.openAccountModal = ->
    $rootScope.$broadcast 'dashboard.openAccountModal'
]
