@app.controller "ContactsNewController",
['$scope', '$rootScope', '$modalInstance', 'Contact', 'Client', 'contact',
($scope, $rootScope, $modalInstance, Contact, Client, contact) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.contact = contact || {}
  Client.all({filter: 'all', per: 500}).then (clients) ->
    $scope.clients = clients

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Contact.create(contact: $scope.contact).then(
      (contact) ->
        Contact.set(contact.id)
        $rootScope.$broadcast 'newContact', contact
        $modalInstance.close()
      (resp) ->
        $scope.errors = resp.data.errors
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
