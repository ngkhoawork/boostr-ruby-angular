@app.controller "ContactsAddController",
['$scope', '$modal', '$modalInstance', '$filter', 'Contact', 'Deal', 'DealContact', 'deal',
($scope, $modal, $modalInstance, $filter, Contact, Deal, DealContact, deal) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact
  $scope.searchText = ""
  DealContact.all(deal_id: deal.id).then (contacts) ->
    $scope.contacts = contacts

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
    DealContact.all(deal_id: deal.id, name: name).then (contacts) ->
      $scope.contacts = contacts

  $scope.checkContact = (contact) ->
    _.findWhere(deal.deal_contacts, contact_id: contact.id)

  $scope.addContact = (contact) ->
    DealContact.create(deal_id: deal.id, deal_contact: { contact_id: contact.id }).then(
      (deal_contact) ->
        deal.deal_contacts.push deal_contact
      (resp) ->
        false
    )

  $scope.cancel = ->
    $modalInstance.close()

  $scope.$on 'newContact', (e, contact) ->
    DealContact.all(deal_id: deal.id).then (contacts) ->
      $scope.contacts = contacts

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
