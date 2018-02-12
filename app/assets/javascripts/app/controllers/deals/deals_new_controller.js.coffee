@app.controller 'DealsNewController',
['$scope', '$modal', '$modalInstance', '$q', '$filter', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal', 'options', 'DealCustomFieldName', 'Currency', 'CurrentUser', 'Validation'
($scope, $modal, $modalInstance, $q, $filter, $location, Deal, Client, Stage, Field, deal, options, DealCustomFieldName, Currency, CurrentUser, Validation) ->

  $scope.init = ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.advertisers = []
    $scope.agencies = []
    $scope.dealCustomFieldNames = []
    $scope.customFieldOptions = [ {id: null, value: ""} ]
    getDealCustomFieldNames()

    if deal.advertiser
      $scope.advertisers = [deal.advertiser]

    if deal.agency
      $scope.agencies = [deal.agency]

    if options.lead
      lead = options.lead
      nextSteps = ''
      if lead.budget?
        nextSteps += "Budget: #{$filter('currency')(lead.budget, undefined, 0)}; "
      if lead.notes
        nextSteps += lead.notes
      deal.next_steps = nextSteps

    $q.all({
      user: CurrentUser.get().$promise,
      currencies: Currency.active_currencies(),
      fields: Field.defaults(deal, 'Deal'),
      base_fields_validations: Validation.deal_base_fields().$promise
    }).then (data) ->
      $scope.currentUser = data.user
      $scope.currencies = data.currencies
      $scope.base_fields_validations = data.base_fields_validations

      deal.deal_type = Field.field(deal, 'Deal Type')
      deal.source_type = Field.field(deal, 'Deal Source')
      $scope.deal = deal
      $scope.setDefaultCurrency()

    Field.defaults({}, 'Client').then (fields) ->
      client_types = Field.findClientTypes(fields)
      $scope.setClientTypes(client_types)

    Stage.query().$promise.then (stages) ->
      $scope.stages = stages.filter (stage) ->
        !(stage.active is false or stage.open is false)

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

  $scope.setDefaultCurrency = ->
    curr_cd = 'USD'
    user_currency = _.find($scope.currencies, {curr_cd: $scope.currentUser.default_currency})
    curr_cd = user_currency.curr_cd if user_currency
    $scope.deal.curr_cd = curr_cd

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

    if moment(this.deal.start_date).isAfter(this.deal.end_date) then return $scope.errors['end_date'] = 'End Date can\'t be before Start Date';

    fields = ['name', 'stage_id', 'advertiser_id', 'agency_id', 'deal_type', 'source_type', 'start_date', 'end_date']

    fields.forEach (key) ->
      field = $scope.deal[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
        when 'stage_id'
          if !field then return $scope.errors[key] = 'Stage is required'
        when 'advertiser_id'
          if !field then return $scope.errors[key] = 'Advertiser is required'
        when 'start_date'
          if !field then return $scope.errors[key] = 'Start date is required'
        when 'end_date'
          if !field then return $scope.errors[key] = 'End date is required'

    $scope.dealCustomFieldNames.forEach (item) ->
      if item.show_on_modal == true && item.is_required == true && (!$scope.deal.deal_custom_field || !$scope.deal.deal_custom_field[item.field_type + item.field_index])
        $scope.errors[item.field_type + item.field_index] = item.field_label + ' is required'

    ($scope.base_fields_validations || []).forEach (validation) ->
      if $scope.deal && (!$scope.deal[validation.factor] && !valueExists($scope.deal, validation.factor))
        $scope.errors[validation.factor] = validation.name + ' is required'

    if Object.keys($scope.errors).length > 0 then return

    if options.lead
      $scope.deal.lead_id = options.lead.id
      $scope.deal.web_lead = true

    Deal.create(deal: $scope.deal).then(
      (deal) ->
        $modalInstance.close(deal)
        if options.type != 'gmail' && !options.lead
          $location.path('/deals' + '/' + deal.id)
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

  valueExists = (deal, factor) ->
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

  $scope.init()

]
