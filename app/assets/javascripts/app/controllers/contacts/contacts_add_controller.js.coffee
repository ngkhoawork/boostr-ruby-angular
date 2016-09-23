@app.controller "ContactsAddController",
['$scope', '$modalInstance', '$routeParams', '$filter', 'Contact', 'Deal', 'deal',
($scope, $modalInstance, $routeParams, $filter, Contact, Deal, deal) ->
  $scope.curentDealContacts = angular.copy deal.contacts

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  Deal.dealContacts $routeParams.id
    .then (contacts) ->
      $scope.contacts = contacts
      console.log 'contacts', $scope.contacts

  $scope.searchObj = (name) ->
    if name == ""
      Deal.dealContacts $routeParams.id
        .then (contacts) ->
          $scope.contacts = contacts
    else
      Deal.dealContacts $routeParams.id, name
        .then (contacts) ->
          $scope.contacts = contacts

  $scope.checkContact = (contact) ->
    fliteredContact = $scope.curentDealContacts.filter (dealContact) ->
      contact.id == dealContact.id
    fliteredContact.length == 0;

  $scope.addContact = (contact) ->
    $scope.curentDealContacts.push contact

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
