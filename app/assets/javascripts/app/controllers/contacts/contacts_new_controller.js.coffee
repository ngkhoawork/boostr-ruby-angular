@app.controller "ContactsNewController",
['$scope', '$modalInstance', 'Contact', 'Client', 'contact',
($scope, $modalInstance, Contact, Client, contact) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.contact = contact || {}
  Client.all().then (clients) ->
    $scope.clients = clients

  $scope.submitForm = () ->
    Contact.create(contact: $scope.contact).then (contact) ->
      Contact.set(contact.id)
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
