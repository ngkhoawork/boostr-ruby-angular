@app.controller "ContactsEditController",
['$scope', '$modal', '$modalInstance', '$filter', 'Contact', 'Client', 'CountriesList', 'contact', 'ContactCfName'
($scope, $modal, $modalInstance, $filter, Contact, Client, CountriesList, contact, ContactCfName) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.contact = contact || Contact.get()
  $scope.query = ""
  $scope.countries = []
  $scope.contactCfNames = []
  $scope.showAddressFields = Boolean($scope.contact.address and
          ($scope.contact.address.country or
              $scope.contact.address.street1 or
              $scope.contact.address.city or
              $scope.contact.address.state or
              $scope.contact.address.zip))

  CountriesList.get (data) ->
    $scope.countries = data.countries

  Client.search_clients().$promise.then (clients) ->
    $scope.clients = clients

  ContactCfName.all().then (contactCfNames) ->
    $scope.contactCfNames = contactCfNames

  if $scope.contact && $scope.contact.address
    $scope.contact.address.phone = $filter('tel')($scope.contact.address.phone)
    $scope.contact.address.mobile = $filter('tel')($scope.contact.address.mobile)

  $scope.submitForm = () ->
    emailRegExp = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)

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
          if !field || !field.email then return $scope.errors.email = 'Email is required'
          if !emailRegExp.test(field.email) then return $scope.errors.email = 'Email is not valid'

    $scope.contactCfNames.forEach (item) ->
      if item.show_on_modal == true && item.is_required == true && (!$scope.contact.contact_cf || !$scope.contact.contact_cf[item.field_type + item.field_index])
        $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

    if Object.keys($scope.errors).length > 0 then return
    $scope.buttonDisabled = true
    $scope.contact.set_primary_client = true
    Contact._update(id: $scope.contact.id, contact: $scope.contact).then(
      (contact) ->
        $modalInstance.close(contact)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.getClients = (query = '') ->
    $scope.isLoading = true
    params = { name: query.trim() }

    Client.search_clients(params).$promise.then (clients) ->
      $scope.clients = clients
      $scope.isLoading = false

  $scope.showNewAccountModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: -> {}

  # Prevent multiple extraneous calls to the server as user inputs search term
  searchTimeout = null;
  $scope.searchClients = (query) ->
    $scope.page = 1
    $scope.query = query
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.getClients(query)
      250
    )

  $scope.cancel = ->
    $modalInstance.close()
]
