@app.controller "ContactsAddController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client',
($scope, $modalInstance, $filter, Contact, Client) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  Contact.query(filter: 'all').$promise.then (contacts) ->
    $scope.contacts = contacts

  $scope.searchObj = (name) ->
    if name == ""
      Contact.query(filter: 'all').$promise.then (contacts) ->
        $scope.contacts = contacts
    else
      Contact.query({name: name}).$promise.then (clients) ->
        $scope.clients = clients
  $scope.addContact = (client) ->
    ###*
     * @TODO add contacts in array,
     *       send on backend id`s
     *       update on frontend, when close
    ###
    # contact = angular.copy($scope.contact)
    # contact.client_id = client.id
    # Contact._update(id: $scope.contact.id, contact: contact).then (contact) ->
    #   $modalInstance.close(contact)

  $scope.cancel = ->
    $modalInstance.close()
]
