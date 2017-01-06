@app.controller "ContactsNewController",
['$scope', '$rootScope', '$modalInstance', 'Contact', 'Client', 'contact',
($scope, $rootScope, $modalInstance, Contact, Client, contact) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.contact = contact || {}
  $scope.query = ""
  Client.query({filter: 'all'}).$promise.then (clients) ->
    $scope.clients = clients

  $scope.submitForm = () ->
    console.log($scope.contact)
    $scope.errors = {}

    fields = ['name', 'client_id', 'address']

    fields.forEach (key) ->
      field = $scope.contact[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
        when 'client_id'
          if !field  then return $scope.errors[key] = 'Primary Account is required'
        when 'address'
          if !field  then return $scope.errors[key] = 'Primary Account is required'

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    Contact.create(contact: $scope.contact).then(
      (contact) ->
        Contact.set(contact.id)
        $rootScope.$broadcast 'newContact', contact
        $modalInstance.close()
      (resp) ->
        $scope.responseErrors = resp.data.errors
        $scope.buttonDisabled = false
    )
  $scope.getClients = (query) ->
    $scope.isLoading = true
    params = {
      page: $scope.page
      filter: "all"
    }
    if $scope.query.trim().length
      params.name = $scope.query.trim()
    Client.query(params).$promise.then (clients) ->
      if $scope.page > 1
        $scope.clients = $scope.clients.concat(clients)
      else
        $scope.clients = clients
      $scope.isLoading = false

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchClients = (query) ->
    $scope.page = 1
    $scope.query = query
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients()
      250
    )

  $scope.cancel = ->
    $modalInstance.dismiss()
]
