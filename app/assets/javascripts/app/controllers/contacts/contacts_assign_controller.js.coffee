@app.controller "ContactsAssignController",
['$scope', '$rootScope', '$modalInstance', '$filter', 'Contact', 'Client', 'contact', 'Field'
($scope, $rootScope, $modalInstance, $filter, Contact, Client, contact, Field) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  Client.search_clients().$promise.then (clients) ->
    $scope.clients = clients

  $scope.searchObj = (name) ->
    Client.search_clients(name: name).$promise.then (clients) ->
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
