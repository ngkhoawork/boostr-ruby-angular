@app.controller 'DealsEditController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal', 'DealCustomFieldName', 'Currency', 'CurrentUser', 'Validation', 'SalesProcess'
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal, DealCustomFieldName, Currency, CurrentUser, Validation, SalesProcess) ->
  $scope.init = ->
    $scope.formType = 'Edit'
    $scope.submitText = 'Update'
    $scope.advertisers = []
    $scope.agencies = []

    getDealCustomFieldNames()

    $q.all({
      deal: Deal.get(deal.id),
      user: CurrentUser.get().$promise,
      currencies: Currency.active_currencies(),
      base_fields_validations: Validation.deal_base_fields().$promise
    }).then (data) ->
      $scope.currentUser = data.user
      $scope.currencies = data.currencies
      $scope.base_fields_validations = data.base_fields_validations
      $scope.deal = data.deal
      $scope.setDefaultCurrency()

      Field.defaults($scope.deal, 'Deal').then ->
        $scope.deal.deal_type = Field.field($scope.deal, 'Deal Type')
        $scope.deal.source_type = Field.field($scope.deal, 'Deal Source')
        $scope.deal.sales_process_id = $scope.deal.stage.sales_process_id

      # get user team and team stages
      if data.user.teams && data.user.teams[0]
        $scope.team = data.user.teams[0]
      else if data.user.team
        $scope.team = data.user.team
      else
        SalesProcess.all({active: true}).then (salesProcesses) ->
          $scope.salesProcesses = salesProcesses

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

      if deal.advertiser_id
        $scope.loadClients(deal.advertiser.name, $scope.Advertiser)
      if deal.agency_id
        $scope.loadClients(deal.agency.name, $scope.Agency)

    Stage.query({active: true, open: true, sales_process_id: deal.stage.sales_process_id}).$promise.then (stages) ->
      $scope.stages = stages

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
    Client.search_clients( name: query, client_type_id: type_id ).$promise.then (clients) ->
      if type_id == $scope.Advertiser
        $scope.advertisers = clients
      if type_id == $scope.Agency
        $scope.agencies = clients

  $scope.submitForm = () ->
    $scope.errors = {}

    fields = ['name', 'stage_id', 'advertiser_id', 'agency_id', 'deal_type', 'source_type']
    fields.push('sales_process_id') unless $scope.team

    fields.forEach (key) ->
      field = $scope.deal[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
        when 'stage_id'
          if !field then return $scope.errors[key] = 'Stage is required'
        when 'advertiser_id'
          if !field then return $scope.errors[key] = 'Advertiser is required'
        when 'sales_process_id'
          if !field then return $scope.errors[key] = 'Sales process is required'
          
    $scope.dealCustomFieldNames.forEach (item) ->
      if !item.disabled && item.show_on_modal && item.is_required && (!$scope.deal.deal_custom_field || !$scope.deal.deal_custom_field[item.field_type + item.field_index])
        $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

    ($scope.base_fields_validations || []).forEach (validation) ->
      if $scope.deal && (!$scope.deal[validation.factor] && !validationValueFactorExists($scope.deal, validation.factor))
        $scope.errors[validation.factor] = validation.name + ' is required'

    if Object.keys($scope.errors).length > 0 then return

    Deal.update(id: $scope.deal.id, deal: $scope.deal).then(
      (deal) ->
        if deal.info_messages.length
          $scope.infoModalInstance = $modal.open
            templateUrl: 'modals/info_modal.html'
            size: 'md'
            controller: 'AgreementInfoController'
            backdrop: 'static'
            keyboard: false
            resolve:
              options: ->
                  messages: deal.info_messages
                  typeOfExcluded: 'agreement'
                  typeOfUpdate: 'deal'
              
        $modalInstance.close(deal)
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.close()

  $scope.baseFieldRequired = (factor) ->
    if $scope.deal
      validation = _.findWhere($scope.base_fields_validations, factor: factor)
      return validation?

  validationValueFactorExists = (deal, factor) ->
    if factor == 'deal_type_value'
      deal.deal_type && deal.deal_type.option_id
    else if factor == 'deal_source_value'
      deal.source_type && deal.source_type.option_id
    else if factor == 'agency'
      deal && deal.agency_id

  $scope.createNewClientModal = (option, target) ->
    $scope.populateClient = true
    $scope.populateClientTarget = target
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_form.html'
      size: 'md'
      controller: 'AccountsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        client: ->
          {
            client_type: {
              option: option
            }
          }
        options: -> {}
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

  $scope.onChangeSalesProcess = (sales_process_id) ->
    Stage.query({active: true, open: true, sales_process_id: sales_process_id}).$promise.then (stages) ->
      $scope.stages = stages
      $scope.deal.stage_id = null

  $scope.removeAccount = (e, type) ->
    e.stopPropagation()
    $scope.deal[type + '_id'] = null
    $scope.deal[type] = null

  $scope.init()
]
