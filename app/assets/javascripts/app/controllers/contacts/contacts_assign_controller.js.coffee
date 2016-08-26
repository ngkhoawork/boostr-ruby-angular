@app.controller "ContactsAssignController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client', 'contact', 'clients',
($scope, $modalInstance, $filter, Contact, Client, contact, clients) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  console.log($scope.contact)
#  Client.query(filter: 'all', per: 500).$promise.then (clients) ->
#    $scope.clients = clients
  $scope.clients = clients

  if $scope.contact && $scope.contact.address
    $scope.contact.address.phone = $filter('tel')($scope.contact.address.phone)
    $scope.contact.address.mobile = $filter('tel')($scope.contact.address.mobile)

  $scope.assignClient = (client) ->
    contact = angular.copy($scope.contact)
    contact.client_id = client.id
    Contact.update(id: $scope.contact.id, contact: contact).then (contact) ->
      $modalInstance.close(contact)

  $scope.cancel = ->
    $modalInstance.close()
]
