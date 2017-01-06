@app.controller "ContactsAddController",
['$scope', '$modal', '$modalInstance', '$filter', 'Contact', 'Deal', 'DealContact', 'deal',
($scope, $modal, $modalInstance, $filter, Contact, Deal, DealContact, deal) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  DealContact.query({deal_id: deal.id}, (contacts) ->
    $scope.contacts = contacts
  )

  searchTimeout = null;
  $scope.searchObj = (name) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.searchContacts(name)
      350
    )

  $scope.searchContacts = (name) ->
    DealContact.query({deal_id: deal.id, name: name}, (contacts) ->
      $scope.contacts = contacts
    )

  $scope.checkContact = (contact) ->
    fliteredContact = deal.contacts.filter (dealContact) ->
      contact.id == dealContact.id
    fliteredContact.length == 0;

  $scope.addContact = (contact) ->
    DealContact.save({ deal_id: deal.id, deal_contact: { contact_id: contact.id } }, ->
      deal.contacts.push contact
    )

  $scope.cancel = ->
    $modalInstance.close()
    
  $scope.createContact = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_form.html'
      size: 'md'
      controller: 'ContactsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {}
]
