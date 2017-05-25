@app.controller 'DealsEalertController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal', 'DealCustomFieldName', 'DealProductCfName', 'Currency', 'CurrentUser', 'Ealert'
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal, DealCustomFieldName, DealProductCfName, Currency, CurrentUser, Ealert) ->
  $scope.init = ->
    $scope.deal = deal
    $scope.comment = ''

    getDealCustomFieldNames()

    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames
      DealProductCfName.all().then (dealProductCustomFieldNames) ->
        $scope.dealProductCustomFieldNames = dealProductCustomFieldNames
        Ealert.all().then (ealert) ->
          $scope.ealert = ealert
          transformEalert()

  validateEmail = (email) ->
    re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return re.test(email)

  $scope.removeRecipient = (index) ->
    $scope.recipient_list.splice(index, 1)

  $scope.onKeypress = (e) ->
    email = e.target.value
    if e.which == 13
      if email
        if validateEmail(email) == false
          e.target.className = 'form-control recipient-field error'
          return
        else
          e.target.className = 'form-control recipient-field'

        index = _.find $scope.ealert.recipient_list, (recipient) ->
          return recipient == email
        if index == undefined
          $scope.recipient_list.push(email)
      e.target.value = ''

  $scope.dealCustomFieldFilter = (item) ->
    return item.subject_type == 'DealCustomFieldName' || item.subject_type == 'Deal'

  $scope.dealProductCfFilter = (item) ->
    return item.subject_type == 'DealProductCfName'

  $scope.getDealFieldValue = (field) ->
    if field.subject_type == 'Deal'
      return field.subject.field_value
    customField = _.find $scope.dealCustomFieldNames, (item) ->
      return item.id == field.subject_id
    if customField != undefined
      fieldName = customField.field_type + customField.field_index
      return $scope.deal.deal_custom_field[fieldName]
    return ''

  $scope.getDealProductFieldValue = (deal_product, field) ->
    customField = _.find $scope.dealProductCustomFieldNames, (item) ->
      return item.id == field.subject_id
    if customField != undefined
      fieldName = customField.field_type + customField.field_index
      return deal_product.deal_product_cf[fieldName]
    return ''

  transformEalert = () ->
    $scope.recipient_list = []
    if $scope.ealert.recipients && $scope.ealert.same_all_stages
      $scope.recipient_list = $scope.ealert.recipients.split(',')
    else
      ealert_stage = _.find $scope.ealert.ealert_stages, (item) ->
        return item.stage_id == $scope.deal.stage_id
      if ealert_stage != undefined && ealert_stage.recipients
        $scope.recipient_list = ealert_stage.recipients.split(',')


    $scope.ealert.ealert_stages = _.map $scope.ealert.ealert_stages, (ealert_stage) ->
      ealert_stage.recipient_list = []
      if ealert_stage.recipients
        ealert_stage.recipient_list = ealert_stage.recipients.split(',')
      return ealert_stage
    $scope.ealert.ealert_stages = _.sortBy $scope.ealert.ealert_stages, (ealert_stage) ->
      return ealert_stage.stage.probability

    $scope.selected_fields = []
    $scope.available_fields = []

    position_fields = [
      {
        name: 'agency',
        label: 'Agency',
        value: (if deal.agency then deal.agency.name else '')
      },
      {
        name: 'deal_type',
        label: 'Deal Type',
        value: (if deal.deal_type && deal.deal_type.option then deal.deal_type.option.name else '')
      },
      {
        name: 'source_type',
        label: 'Source Type',
        value: (if deal.source_type && deal.source_type.option then deal.source_type.option.name else '')
      },
      {
        name: 'next_steps',
        label: 'Next Steps',
        value: deal.next_steps
      },
      {
        name: 'closed_reason',
        label: 'Closed Reason',
        value: deal.closed_reason_text
      },
      {
        name: 'intiative',
        label: 'Initiative',
        value: (if deal.initiative then deal.initiative.name else '')
      }
    ]
    _.each $scope.ealert, (value, index) ->
      position_index = _.findIndex position_fields, (position_field) ->
        return index == position_field.name
      if position_index > -1
        position_field = position_fields[position_index]
        field_data = {
          name: position_field.name,
          subject_type: 'Deal',
          subject: {
            field_label: position_field.label
            field_value: position_field.value
          },
          id: index,
          position: value
        }
        if value && value > 0
          $scope.selected_fields.push(field_data)
        else
          $scope.available_fields.push(field_data)
    _.each $scope.ealert.ealert_custom_fields, (ealert_custom_field) ->
      # value = ''
      # switch ealert_custom_field.subject.field_type
      #   when 'currency' then value = '$100,000'
      #   when 'text' then value = 'some text'
      #   when 'note' then value = 'some notes'
      #   when 'datetime' then value = '07/05/2017'
      #   when 'number' then value = '75.80'
      #   when 'number_4_dec' then value = '76.4500'
      #   when 'integer' then value = '210'
      #   when 'boolean' then value = 'Yes'
      #   when 'percentage' then value = '80.76%'
      #   when 'dropdown' then value = 'option 1'
      #   when 'sum' then value = '20,000'
      # ealert_custom_field.subject.field_value = value
      if ealert_custom_field.position > 0
        $scope.selected_fields.push(ealert_custom_field)
      else
        $scope.available_fields.push(ealert_custom_field)
    $scope.selected_fields = _.sortBy $scope.selected_fields, (field) ->
      return field.position
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
