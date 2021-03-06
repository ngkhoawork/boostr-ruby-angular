@app.controller 'PmpsNewController',
  ['$scope', '$rootScope', '$modal', '$modalInstance', '$location', 'Field', 'Client', 'pmp', 'PMP', 'Currency'
  ($scope,    $rootScope,   $modal,   $modalInstance,   $location,   Field,   Client,   pmp,   PMP,   Currency) ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.pmp = {}
    $scope.advertisers = []
    $scope.agencies = []
    $scope.currencies = []

    init = () ->
      if !_.isEmpty(pmp)
        $scope.pmp.id = pmp.id
        $scope.pmp.name = pmp.name
        $scope.pmp.advertiser_id = pmp.advertiser && pmp.advertiser.id
        $scope.pmp.agency_id = pmp.agency && pmp.agency.id
        $scope.pmp.budget_loc = pmp.budget_loc
        $scope.pmp.start_date = pmp.start_date
        $scope.pmp.end_date = pmp.end_date
        $scope.advertisers.push pmp.advertiser
        $scope.agencies.push pmp.agency
        $scope.formType = 'Edit'
        $scope.submitText = 'Update'
      Field.defaults({}, 'Client').then (fields) ->
        client_types = Field.findClientTypes(fields)
        client_types.options.forEach (option) ->
          $scope[option.name] = option.id
      Currency.active_currencies().then (currencies) ->
        $scope.currencies = currencies
        user_currency = _.find(currencies, {curr_cd: $rootScope.currentUser.default_currency})
        $scope.pmp.curr_cd = user_currency.curr_cd if user_currency

    $scope.submitForm = () ->
      # validates empty fields
      $scope.errors = {}
      fields = ['name', 'advertiser_id', 'start_date', 'end_date']
      titles = ['Name', 'Advertiser', 'Start date', 'End date']
      fields.forEach (key) ->
        field = $scope.pmp[key]
        title = titles[_.indexOf(fields, key)]
        if !field then $scope.errors[key] = title + ' is required'
      if !_.isEmpty($scope.errors) then return

      if $scope.formType == 'New'
        createPmp()
      else
        updatePmp()

    createPmp = () ->
      PMP.create(pmp: $scope.pmp).then(
        (pmp) ->
          $modalInstance.close(pmp)
          $location.path('/revenue/pmps/' + pmp.id)
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

    updatePmp = () ->
      PMP.update(id: $scope.pmp.id, pmp: $scope.pmp).then(
        (pmp) ->
          $modalInstance.close(pmp)
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

    $scope.set = (key, val) ->
      $scope.pmp[key] = val

    $scope.addClient = () ->
      $scope.populateClient = true
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/client_form.html'
        size: 'md'
        controller: 'AccountsNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          client: -> {}
          options: -> {}
      # This will clear out the populateClient field if the form is dismissed
      $scope.modalInstance.result.then(
        null
        ->
          $scope.populateClient = false
      )

    $scope.$on 'newClient', (event, client) ->
      if $scope.populateClient
        client_type = Field.field(client, 'Client Type')
        switch client_type.option.name
          when 'Advertiser'
            $scope.advertisers.push client
            $scope.pmp['advertiser_id'] = client.id
          when 'Agency'
            $scope.agencies.push client
            $scope.pmp['agency_id'] = client.id
        $scope.populateClient = false

    loadClients = (query, type_id) ->
      Client.search_clients( name: query, client_type_id: type_id ).$promise.then (clients) ->
        if type_id == $scope.Advertiser
          $scope.advertisers = clients
        if type_id == $scope.Agency
          $scope.agencies = clients

    searchTimeout = null
    $scope.searchClients = (query, type_id) ->
      if searchTimeout
        clearTimeout(searchTimeout)
      searchTimeout = setTimeout(
        -> loadClients(query, type_id)
        400
      )

    $scope.closeModal = () ->
      $modalInstance.dismiss()

    init()
  ]
