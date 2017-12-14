@app.controller 'AccountConnectionContactsNewController',
['$rootScope', '$scope', '$modal', '$modalInstance', '$q', '$location', 'ClientConnection', 'client', 'Contact', 'Field', 'Client'
($rootScope, $scope, $modal, $modalInstance, $q, $location, ClientConnection, client, Contact, Field, Client) ->
  $scope.init = ->
    $scope.formType = 'New'
    $scope.submitText = 'Assign'
    $scope.currentClient = client
    $scope.object = {}
    $scope.contact = null

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)
      if $scope.currentClient.client_type.option.name == 'Advertiser'
        $scope.subjectType = 'Agency'
      else if $scope.currentClient.client_type.option.name == 'Agency'
        $scope.subjectType = 'Advertiser'

    Client.connected_contacts({ id: $scope.currentClient.id, page: 1, per: 10 }).$promise.then (connected_contacts) ->
      $scope.contacts = connected_contacts

  searchTimeout = null;
  $scope.searchContacts = (query) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> searchObj(query)
      400
    )

  searchObj = (name) ->
    if name.trim() == ""
      Client.connected_contacts({ id: $scope.currentClient.id, page: 1, per: 10 }).$promise.then (connected_contacts) ->
        $scope.contacts = connected_contacts
    else
      Client.connected_contacts({ id: $scope.currentClient.id, page: 1, per: 10, name: name.trim() }).$promise.then (connected_contacts) ->
        $scope.contacts = connected_contacts

  $scope.setContact = (contact) ->
    $scope.contact = contact

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.assignContact = (contact) ->
    contact.client_id = $scope.currentClient.id
    Contact._update(id: contact.id, contact: contact).then(
      (contact) ->
        $modalInstance.close(contact)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )


  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
