@app.controller "ContactsNewController",
['$scope', 'Contact', 'Client', '$modalInstance'
($scope, Contact, Client, $modalInstance) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.contact = {}
  Client.all (clients) ->
      $scope.clients = clients
  $scope.submitForm = () ->
    Contact.create(contact: $scope.contact).then (contact) ->
      Contact.set(contact.id)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
