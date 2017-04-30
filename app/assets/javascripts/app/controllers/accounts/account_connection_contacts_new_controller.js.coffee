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

#    ClientConnection.all({client_id: $scope.currentClient.id}).then (client_connections) ->
#      $scope.clients = _.map client_connections, (item) ->
#        if $scope.currentClient.id == item.advertiser_id
#          return item.agency
#        else
#          return item.advertiser


    Client.connected_contacts({id: $scope.currentClient.id}).$promise.then (connected_contacts) ->
      $scope.contacts = connected_contacts

  searchTimeout = null;
  $scope.searchClients = (query) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.loadClients(query)
      400
    )

  $scope.loadClients = (query) ->
    if $scope.currentClient.client_type.option.name == 'Advertiser'
      type_id = $scope.Advertiser
    else if $scope.currentClient.client_type.option.name == 'Agency'
      type_id = $scope.Agency
    Client.query({ filter: 'all', name: query, per: 10, client_type_id: type_id }).$promise.then (clients) ->
      $scope.clients = clients

  $scope.searchObj = (name) ->
    if name.trim() == ""
      Client.all1({ page: 1, per: 10, filter: "all" }).then (contacts) ->
        $scope.contacts = contacts
    else
      Contact.all1({ page: 1, per: 10, filter: "all", name: name.trim() }).then (contacts) ->
        $scope.contacts = contacts

  $scope.setContact = (contact) ->
    $scope.contact = contact

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.submitForm = () ->
    $scope.errors = {}

    if !$scope.object.client_id
      $scope.errors['client'] = 'Client is required'

    if !$scope.object.contact_id
      $scope.errors['contact'] = 'Contact is required'

    if Object.keys($scope.errors).length > 0 then return

    $scope.contact.client_id = $scope.object.client_id
    Contact._update(id: $scope.contact.id, contact: $scope.contact).then(
      (contact) ->
        clientConnection = {agency_id: contact.primary_client_json.id, advertiser_id: contact.client_id, primary: false, active: true}
        ClientConnection.create(client_connection: clientConnection).then(
          (client_connection) ->
            $modalInstance.close(contact)
          (resp) ->
            for key, error of resp.data.errors
              $scope.errors[key] = error && error[0]
            $scope.buttonDisabled = false
        )
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )


  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()
]
