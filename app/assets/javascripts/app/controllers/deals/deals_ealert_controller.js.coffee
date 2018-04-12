@app.controller 'DealsEalertController',
['$scope', '$modal', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Stage', 'Field', 'deal', 'DealCustomFieldName', 'DealProductCfName', 'Currency', 'CurrentUser', 'Ealert'
($scope, $modal, $modalInstance, $q, $location, Deal, Client, Stage, Field, deal, DealCustomFieldName, DealProductCfName, Currency, CurrentUser, Ealert) ->
  $scope.init = ->
    $scope.deal = deal
    $scope.comment = ''
    $scope.errors = {}

    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames
      DealProductCfName.all().then (dealProductCustomFieldNames) ->
        $scope.dealProductCustomFieldNames = dealProductCustomFieldNames
        Ealert.all().then (ealert) ->
          $scope.ealert = ealert
          transformEalert()

    dealMembers = _.map $scope.deal.members, (dealMember) ->
      return dealMember.name + ' (' + dealMember.share + '%)'
    $scope.salesTeam = dealMembers.join(', ')
    $scope.buttonDisabled = !$scope.deal.validDeal

  validateEmail = (email) ->
    email = email.trim()
    re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    re.test(email)

  $scope.removeRecipient = (index) ->
    $scope.recipient_list.splice(index, 1)

  $scope.onKeypress = (e) ->
    if $scope.errors && $scope.errors['recipient']
      delete $scope.errors['recipient']
    
    if e.which == 13
      input = angular.element(e.target)
      $scope.addRecipient(input)

  $scope.addRecipient = (input) ->
    if input.length > 0 and input.val()
      $scope.notValid = false
      emails = input.val().split(',')

      emails.forEach (email) ->
        if not validateEmail email
          $scope.notValid = true
          return
      
      if $scope.notValid
        input.addClass('error')
        input.focus()
        return
      else
        input.removeClass('error')
        emails.forEach (email) ->
          index = _.find $scope.recipient_list, (recipient) ->
            return recipient == email
          if index == undefined
            $scope.recipient_list.push(email)
        
        input.val('')
        return

  $scope.dealCustomFieldFilter = (item) ->
    return item.subject_type == 'DealCustomFieldName' || item.subject_type == 'Deal'

  $scope.dealProductCfFilter = (item) ->
    return item.subject_type == 'DealProductCfName'

  $scope.getDealFieldValue = (field) ->
    if field.subject_type == 'Deal'
      return field.subject.field_value
    customField = _.find $scope.dealCustomFieldNames, (item) ->
      return item.id == field.subject_id
    if customField != undefined && $scope.deal.deal_custom_field
      fieldName = customField.field_type + customField.field_index
      return $scope.deal.deal_custom_field[fieldName]
    return ''

  $scope.getDealProductFieldValue = (deal_product, field) ->
    customField = _.find $scope.dealProductCustomFieldNames, (item) ->
      return item.id == field.subject_id
    if customField != undefined && deal_product.deal_product_cf
      fieldName = customField.field_type + customField.field_index
      return deal_product.deal_product_cf[fieldName]
    return ''

  transformEalert = () ->
    $scope.recipient_list = []
    if $scope.ealert.recipients && $scope.ealert.same_all_stages
      $scope.recipient_list = $scope.ealert.recipients.split(',')
    else if $scope.ealert.same_all_stages == false
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
      if ealert_custom_field.position > 0
        $scope.selected_fields.push(ealert_custom_field)
      else
        $scope.available_fields.push(ealert_custom_field)
    $scope.selected_fields = _.sortBy $scope.selected_fields, (field) ->
      return field.position

  $scope.onBlur = (event) ->
    input = angular.element(event.target)
    $scope.addRecipient(input)

  $scope.submitForm = () ->
    $scope.errors = {}

    if $scope.recipient_list.length == 0
      $scope.errors['recipient'] = 'Recipient is required'
  
    if Object.keys($scope.errors).length > 0 || $scope.notValid then return

    data = {
      recipients: $scope.recipient_list.join(),
      comment: $scope.comment,
      deal_id: $scope.deal.id
    }
    if ($scope.deal.validDeal == true)
      $scope.buttonDisabled = true
      Ealert.send_ealert(id: $scope.ealert.id, data: data).then(
        (response) ->
          # console.log(response)
          $modalInstance.close(true)
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
