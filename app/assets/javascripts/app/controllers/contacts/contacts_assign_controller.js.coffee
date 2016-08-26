@app.controller "ContactsAssignController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client', 'contact',
($scope, $modalInstance, $filter, Contact, Client, contact) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  console.log($scope.contact)
  Client.query(filter: 'all').$promise.then (clients) ->
    $scope.clients = clients

  if $scope.contact && $scope.contact.address
    $scope.contact.address.phone = $filter('tel')($scope.contact.address.phone)
    $scope.contact.address.mobile = $filter('tel')($scope.contact.address.mobile)

  $scope.searchObj = (name) ->
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
