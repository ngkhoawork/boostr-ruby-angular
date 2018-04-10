@app.controller "ContactsNewController",
['$scope', '$rootScope', '$modal', '$modalInstance', 'Contact', 'Client', 'contact', 'CountriesList', 'ContactCfName', 'options'
($scope, $rootScope, $modal, $modalInstance, Contact, Client, contact, CountriesList, ContactCfName, options) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.contact = contact || {}
  $scope.query = ""
  $scope.countries = []
  $scope.contactCfNames = []
  $scope.showAddressFields = Boolean(contact.address and
      (contact.address.country or
        contact.address.street1 or
        contact.address.city or
        contact.address.state or
        contact.address.zip))


  if options.lead
    contact = $scope.contact
    lead = options.lead 
    contact.name = lead.name
    if contact.address
      contact.address.email = lead.email
    else
      contact.address = email: lead.email
    if lead.client
      contact.client_id = lead.client.id
      contact.primary_client_json = lead.client
    contact.position = lead.title

  CountriesList.get (data) ->
    $scope.countries = data.countries
  
  Client.search_clients().$promise.then (clients) ->
    $scope.clients = clients
    if contact.primary_client
      $scope.clients = $scope.clients.concat([contact.primary_client])

  ContactCfName.all().then (contactCfNames) ->
    $scope.contactCfNames = contactCfNames

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

    $scope.contact.lead = options.lead if options.lead

    Contact.create(contact: $scope.contact).then(
      (contact) ->
        Contact.set(contact.id)
        $rootScope.$broadcast 'newContact', contact
        $modalInstance.close(contact)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )
  $scope.getClients = (query = '') ->
    $scope.isLoading = true
    params =
      page: $scope.page
      name: query.trim()

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
        options: -> options

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
    $modalInstance.dismiss()
]
