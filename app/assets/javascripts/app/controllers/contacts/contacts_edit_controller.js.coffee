@app.controller "ContactsEditController",
['$scope', '$modalInstance', '$filter', 'Contact', 'Client',
($scope, $modalInstance, $filter, Contact, Client) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = Contact.get()

  console.log($scope.contact)
  $scope.query = ""
  Client.query(filter: 'all').$promise.then (clients) ->
    $scope.clients = clients


  if $scope.contact && $scope.contact.address
    $scope.contact.address.phone = $filter('tel')($scope.contact.address.phone)
    $scope.contact.address.mobile = $filter('tel')($scope.contact.address.mobile)

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.contact.set_primary_client = true
    Contact._update(id: $scope.contact.id, contact: $scope.contact).then (contact) ->
      $modalInstance.close()

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
    $modalInstance.close()
]
