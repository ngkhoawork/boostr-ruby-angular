@app.controller 'DealsEditController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal', 'DealCustomFieldName', 'Currency', 'CurrentUser'
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal, DealCustomFieldName, Currency, CurrentUser) ->
  $scope.init = ->
    $scope.formType = 'Edit'
    $scope.submitText = 'Update'
    $scope.advertisers = []
    $scope.agencies = []
    $scope.deal = deal

    getDealCustomFieldNames()

    $q.all({
      user: CurrentUser.get().$promise,
      currencies: Currency.active_currencies()}
    ).then (data) ->
      $scope.currentUser = data.user
      $scope.currencies = data.currencies

      $scope.setDefaultCurrency()

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

      if deal.advertiser_id
        $scope.loadClients(deal.advertiser.name, $scope.Advertiser)
      if deal.agency_id
        $scope.loadClients(deal.agency.name, $scope.Agency)

    Stage.query().$promise.then (stages) ->
      $scope.stages = stages.filter (stage) ->
        !(stage.active is false or stage.open is false)

  $scope.setDefaultCurrency = ->
    if $scope.deal.curr_cd then return
    curr_cd = 'USD'
    user_currency = _.find($scope.currencies, {curr_cd: $scope.currentUser.default_currency})
    curr_cd = user_currency.curr_cd if user_currency
    $scope.deal.curr_cd = curr_cd

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

  $scope.setClientTypes = (client_types) ->
    client_types.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.advertiserSelected = (model) ->
    $scope.deal.advertiser_id = model

  $scope.agencySelected = (model) ->
    $scope.deal.agency_id = model

  searchTimeout = null;
  $scope.searchClients = (query, type_id) ->
    if searchTimeout
      clearTimeout(searchTimeout)
      searchTimeout = null
    searchTimeout = setTimeout(
      -> $scope.loadClients(query, type_id)
      400
    )

  $scope.loadClients = (query, type_id) ->
    Client.query({ filter: 'all', name: query, per: 10, client_type_id: type_id }).$promise.then (clients) ->
      if type_id == $scope.Advertiser
        $scope.advertisers = clients
      if type_id == $scope.Agency
        $scope.agencies = clients

  $scope.submitForm = () ->
    $scope.errors = {}

    fields = ['name', 'stage_id', 'advertiser_id', 'agency_id', 'deal_type', 'source_type']

    fields.forEach (key) ->
      field = $scope.deal[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
        when 'stage_id'
          if !field then return $scope.errors[key] = 'Stage is required'
        when 'advertiser_id'
          if !field then return $scope.errors[key] = 'Advertiser is required'

    $scope.dealCustomFieldNames.forEach (item) ->
      if item.show_on_modal == true && item.is_required == true && (!$scope.deal.deal_custom_field || !$scope.deal.deal_custom_field[item.field_type + item.field_index])
        $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

    if Object.keys($scope.errors).length > 0 then return

    Deal.update(id: $scope.deal.id, deal: $scope.deal).then(
      (deal) ->
        $modalInstance.close()
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )


  $scope.cancel = ->
    $modalInstance.close()

  $scope.createNewClientModal = (option, target) ->
    $scope.populateClient = true
    $scope.populateClientTarget = target
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'ClientsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {
            client_type: {
              option: option
            }
          }
    # This will clear out the populateClient field if the form is dismissed
    $scope.modalInstance.result.then(
      null
      ->
        $scope.populateClient = false
        $scope.populateClientTarget = false
    )

  $scope.$on 'newClient', (event, client) ->
    if $scope.populateClient and $scope.populateClientTarget
      Field.defaults(client, 'Client').then (fields) ->
        client.client_type = Field.field(client, 'Client Type')
        $scope.deal[$scope.populateClientTarget] = client.id
        $scope.populateClient = false
        $scope.populateClientTarget = false

  $scope.init()
]
