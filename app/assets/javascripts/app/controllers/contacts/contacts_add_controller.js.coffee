@app.controller "ContactsAddController",
['$scope', '$modalInstance', '$routeParams', '$filter', 'Contact', 'Deal', 'deal',
($scope, $modalInstance, $routeParams, $filter, Contact, Deal, deal) ->
  $scope.curentDealContacts = angular.copy deal.contacts

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
      Contact.query({name: name}).$promise.then (contacts) ->
        $scope.contacts = contacts

  $scope.checkContact = (contact) ->
    fliteredContact = $scope.curentDealContacts.filter (dealContact) ->
      contact.id == dealContact.id
    fliteredContact.length == 0;

  $scope.addContact = (contact) ->
    $scope.curentDealContacts.push id: contact.id, address: contact.address, name: contact.name

    putData = $scope.curentDealContacts.map (contact) ->
      contact.id

    Deal.updateContacts $routeParams.id, {deal: deal, contacts: putData}
      .then (contacts) ->
        console.info 'PUT contacts: ', contacts
      , (e) ->
        console.error 'Error:', e

  $scope.cancel = ->
    $modalInstance.close($scope.curentDealContacts)
]
