@app.controller "ContactsEditController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client',
($scope, $modalInstance, $filter, Contact, Client) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = Contact.get()
  Client.all(filter: 'all').then (clients) ->
    $scope.clients = clients

  if $scope.contact && $scope.contact.address
    $scope.contact.address.phone = $filter('tel')($scope.contact.address.phone)
    $scope.contact.address.mobile = $filter('tel')($scope.contact.address.mobile)

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Contact.update(id: $scope.contact.id, contact: $scope.contact).then (contact) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
