@app.controller "SettingsEalertsController",
['$scope', '$routeParams', '$location', '$modal', 'DealCustomFieldName', 'DealProductCfName', 'Ealert', 'Stage', 'DataModel', '$q'
($scope,    $routeParams,   $location,   $modal,   DealCustomFieldName,   DealProductCfName,   Ealert,   Stage,   DataModel,   $q) ->
  $scope.recipients = []
  $scope.selectedFields = []
  $scope.availableFields = []
  $scope.data_mappings = []
  $scope.loadedDataMapping = false;

  $scope.init = () ->
    getEalert()

  getEalert = () ->
    $q.all({
      dealCustomFieldNames: DealCustomFieldName.all()
      dealProductCustomFieldNames: DealProductCfName.all()
      stages: Stage.query({active: true}).$promise
      ealert: Ealert.all()
    }).then (data) ->
      $scope.dealCustomFieldNames = data.dealCustomFieldNames
      $scope.dealProductCustomFieldNames = data.dealProductCustomFieldNames
      $scope.stages = data.stages
      $scope.ealert = data.ealert
      transformEalert()
      getDataMappings()

  getDataMappings = ->
    DataModel.get_mappings(object_name: 'Deal').then (mappings) ->
      $scope.data_mappings = mappings
      $scope.loadedDataMapping = true;

  getDealCustomFieldNames = () ->
    DealCustomFieldName.all().then (dealCustomFieldNames) ->
      $scope.dealCustomFieldNames = dealCustomFieldNames

  getDealProductCfNames = () ->
    DealProductCfName.all().then (dealProductCustomFieldNames) ->
      $scope.dealProductCustomFieldNames = dealProductCustomFieldNames

  $scope.submitEalert = (ealert) ->
    $scope.errors = {}

    if !ealert.subject
      $scope.errors['subject'] = 'Subject is required!'
    else if ealert.delay == null
      $scope.errors['delay'] = 'Auto send delay is required!'
    else if ealert.delay < 0
      $scope.errors['delay'] = 'Auto send delay can\'t be negative value!'
    else
      $scope.ealert.recipients = $scope.ealert.recipient_list.join()
      for i in [0...$scope.ealert.ealert_stages.length]
        $scope.ealert.ealert_stages[i].recipients = $scope.ealert.ealert_stages[i].recipient_list.join()
      Ealert.update(id: ealert.id, ealert: ealert).then (ealert) ->
        $scope.ealert = ealert
        transformEalert()

  $scope.removeRecipient = (stage_index, index) ->
    if stage_index == "all_recipients"
      $scope.ealert.recipient_list.splice(index, 1)
    else
      $scope.ealert.ealert_stages[stage_index].recipient_list.splice(index, 1)

  $scope.cancel = () ->
    getEalert()

  $scope.addField = (item) ->
    $scope.availableFields = _.reject $scope.availableFields, (field) ->
      if item.id
        return item.id == field.id
      else if item.subject && field.subject
        return item.subject.field_type == field.subject.field_type && item.subject.field_index == field.subject.field_index
    $scope.selectedFields.push(item)
    repositionFields()

  $scope.removeField = (item) ->
    $scope.selectedFields = _.reject $scope.selectedFields, (field) ->
      if item.id
        return item.id == field.id
      else if item.subject && field.subject
        return item.subject.field_type == field.subject.field_type && item.subject.field_index == field.subject.field_index
    $scope.availableFields.push(item)
    repositionFields()

  $scope.changeEalertEnabled = (index) ->
    $scope.ealert.ealert_stages[index].enabled = !$scope.ealert.ealert_stages[index].enabled
    all_disabled = true
    automatic_send = true
    for index in [0...$scope.ealert.ealert_stages.length]
      if $scope.ealert.ealert_stages[index].enabled == true
        all_disabled = false
      else
        automatic_send = false
    $scope.ealert.all_disabled = all_disabled
    $scope.ealert.automatic_send = automatic_send


  $scope.enableAllEalerts = () ->
    $scope.ealert.automatic_send = !$scope.ealert.automatic_send
    if $scope.ealert.automatic_send == true
      $scope.ealert.all_disabled = false
      for index in [0...$scope.ealert.ealert_stages.length]
        $scope.ealert.ealert_stages[index].enabled = true

  $scope.disableAllEalerts = () ->
    $scope.ealert.all_disabled = !$scope.ealert.all_disabled
    if $scope.ealert.all_disabled == true
      $scope.ealert.automatic_send = false
      for index in [0...$scope.ealert.ealert_stages.length]
        $scope.ealert.ealert_stages[index].enabled = false

  $scope.onKeypress = (e, stage_id) ->
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
          if stage_id == 'all_recipients'
            $scope.ealert.recipient_list.push(email)
          else
            stage_index = _.findIndex $scope.ealert.ealert_stages, (ealert_stage) ->
              return stage_id == ealert_stage.stage_id
            $scope.ealert.ealert_stages[stage_index].recipient_list.push(email)
      e.target.value = ''
      $scope.status.isopen[stage_id] = false

  # $scope.goDeal = () ->
  #   $location.path('/deals/')
  $scope.onMoved = (field, index) ->
    $scope.selectedFields.splice(index, 1)
    repositionFields()

  $scope.dealCustomFieldFilter = (item) ->
    return item.subject_type == 'DealCustomFieldName' || item.subject_type == 'Deal'

  $scope.dealProductCfFilter = (item) ->
    return item.subject_type == 'DealProductCfName'

  repositionFields = () ->
    $scope.selectedFields = _.map $scope.selectedFields, (item, index) ->
      item.position = index + 1
      setFieldPosition(item)
      return item
    $scope.availableFields = _.map $scope.availableFields, (item) ->
      item.position = 0
      setFieldPosition(item)
      return item

  setFieldPosition = (item) ->
    switch item.subject_type
      when 'Deal' then $scope.ealert[item.name] = item.position
      else
        index = _.findIndex $scope.ealert.ealert_custom_fields, (ealert_custom_field) ->
          return ealert_custom_field.subject_type == item.subject_type && ealert_custom_field.subject_id == item.subject_id && ealert_custom_field.subject.field_type == item.subject.field_type && ealert_custom_field.subject.field_index == item.subject.field_index
        if index > -1
          $scope.ealert.ealert_custom_fields[index].position = item.position
  
  validateEmail = (email) ->
    re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return re.test(email)
  $scope.init()

  titleCase = (str) ->  
    str = str.toLowerCase().split(' ');

    for i in [0...str.length]
      str[i] = str[i].split('');
      str[i][0] = str[i][0].toUpperCase(); 
      str[i] = str[i].join('');
    return str.join(' ');

  transformEalert = () ->
    allDisabled = true
    automaticSend = true
    _.forEach $scope.ealert.ealert_stages, (ealertStage) ->
      if ealertStage.enabled == true
        allDisabled = false
      else
        automaticSend = false
    $scope.ealert.all_disabled = allDisabled
    $scope.ealert.automatic_send = automaticSend

    $scope.ealert.recipient_list = []
    if $scope.ealert.recipients
      $scope.ealert.recipient_list = $scope.ealert.recipients.split(',')
    
    $scope.ealert.ealert_stages = _.reject $scope.ealert.ealert_stages, (item) ->
      item.stage.active == false
    _.forEach $scope.stages, (stage) ->
      found = _.find $scope.ealert.ealert_stages, (ealertStage) ->
        ealertStage.stage_id == stage.id
      if !found
        $scope.ealert.ealert_stages.push({
          company_id: $scope.ealert.company_id,
          stage_id: stage.id,
          stage: stage,
          ealert_id: $scope.ealert.id,
          recipients: $scope.ealert.recipients,
          enabled: false
        })
    $scope.ealert.ealert_stages = _.map $scope.ealert.ealert_stages, (ealertStage) ->
      ealertStage.recipient_list = []
      if ealertStage.recipients
        ealertStage.recipient_list = ealertStage.recipients.split(',')
      ealertStage
    $scope.ealert.ealert_stages = _.sortBy $scope.ealert.ealert_stages, (ealertStage) ->
      [ealertStage.stage.sales_process && ealertStage.stage.sales_process.name, ealertStage.stage.position]

    _.forEach $scope.dealCustomFieldNames, (dealCustomFieldName) ->
      found = _.find $scope.ealert.ealert_custom_fields, (ealertCustomField) ->
        ealertCustomField.subject_type == 'DealCustomFieldName' && ealertCustomField.subject_id == dealCustomFieldName.id
      if !found
        $scope.ealert.ealert_custom_fields.push({
          company_id: $scope.ealert.company_id,
          subject_type: 'DealCustomFieldName',
          subject_id: dealCustomFieldName.id,
          subject: dealCustomFieldName,
          ealert_id: $scope.ealert.id,
          position: 0
        })

    _.forEach $scope.dealProductCustomFieldNames, (dealProductCustomFieldName) ->
      found = _.find $scope.ealert.ealert_custom_fields, (ealertCustomField) ->
        ealertCustomField.subject_type == 'DealProductCfName' && ealertCustomField.subject_id == dealProductCustomFieldName.id
      if !found
        $scope.ealert.ealert_custom_fields.push({
          company_id: $scope.ealert.company_id,
          subject_type: 'DealProductCfName',
          subject_id: dealProductCustomFieldName.id,
          subject: dealProductCustomFieldName,
          ealert_id: $scope.ealert.id,
          position: 0
        })

    $scope.selectedFields = []
    $scope.availableFields = []

    positionFields = [
      {name: 'agency', label: 'Agency', value: 'Starcom - NY'},
      {name: 'deal_type', label: 'Deal Type', value: 'Renewal'},
      {name: 'source_type', label: 'Source Type', value: 'RPF from Client'},
      {name: 'next_steps', label: 'Next Steps', value: 'Follow up meeting request to review branded content submission'},
      {name: 'closed_reason', label: 'Closed Reason', value: 'Won'},
      {name: 'closed_reason_text', label: 'Closed Comments', value: 'Closed it because it is won'},
      {name: 'intiative', label: 'Initiative', value: 'Super Bowl'}
    ]
    _.forEach $scope.ealert, (value, index) ->
      positionField = _.find positionFields, (positionField) ->
        index == positionField.name
      if positionField
        fieldData = {
          name: positionField.name,
          subject_type: 'Deal',
          subject: {
            field_label: positionField.label
            field_value: positionField.value
          },
          id: index,
          position: value
        }
        if value && value > 0
          $scope.selectedFields.push(fieldData)
        else
          $scope.availableFields.push(fieldData)

    _.forEach $scope.ealert.ealert_custom_fields, (ealertCustomField) ->
      value = ''
      switch ealertCustomField.subject.field_type
        when 'currency' then value = '£100,000 GBP'
        when 'text' then value = 'some text'
        when 'note' then value = 'some notes'
        when 'datetime' then value = '07/05/2017'
        when 'number' then value = '75.80'
        when 'number_4_dec' then value = '76.4500'
        when 'integer' then value = '210'
        when 'boolean' then value = 'Yes'
        when 'percentage' then value = '80.76%'
        when 'dropdown' then value = 'option 1'
        when 'sum' then value = '20,000'
      ealertCustomField.subject.field_value = value
      if ealertCustomField.position > 0
        $scope.selectedFields.push(ealertCustomField)
      else
        $scope.availableFields.push(ealertCustomField)

    $scope.selectedFields = _.sortBy $scope.selectedFields, (field) ->
      field.position

]
