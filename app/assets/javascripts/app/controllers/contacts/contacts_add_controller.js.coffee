@app.controller "ContactsAddController",
['$scope', '$modal', '$modalInstance', '$filter', 'Contact', 'Deal', 'DealContact', 'deal', 'publisher', 'PublisherContact', '$rootScope',
($scope, $modal, $modalInstance, $filter, Contact, Deal, DealContact, deal, publisher, PublisherContact, $rootScope) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.searchText = ""
  Contact.all1({ per: 10 }).then (contacts) ->
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
    Contact.all1({ q: name, per: 10 }).then (contacts) ->
      $scope.contacts = contacts

  $scope.checkContact = (contact) ->
    _.findWhere(deal.deal_contacts, contact_id: contact.id)

  $scope.addContact = (contact) ->
    if !_.isEmpty(deal)
      DealContact.create(deal_id: deal.id, deal_contact: { contact_id: contact.id }).then(
        (deal_contact) ->
          deal.deal_contacts.push deal_contact
        (resp) ->
          false
      )
    else
      PublisherContact.addContact(id: contact.id, publisher_id: publisher.id).then (res) ->
        $rootScope.$broadcast 'updated_publisher_detail'


  $scope.cancel = ->
    $modalInstance.close()

  $scope.$on 'newContact', (e, contact) ->
    if !_.isEmpty(deal)
      DealContact.all(deal_id: deal.id).then (contacts) ->
        $scope.contacts = contacts
    else
      Contact.all1({ per: 10 }).then (contacts) ->
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
