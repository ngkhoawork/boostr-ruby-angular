@app.controller "SettingsDealCustomFieldNamesNewController",
['$scope', '$modalInstance', '$q', '$filter', 'CustomFieldNames', 'DealCustomFieldName', 'DealProductCfName', 'AccountCfName', 'ContactCfName', 'PublisherCustomFieldName', 'User', 'TimePeriod', 'customFieldName',
($scope, $modalInstance, $q, $filter, CustomFieldNames, DealCustomFieldName, DealProductCfName, AccountCfName, ContactCfName, PublisherCustomFieldName, User, TimePeriod, customFieldName) ->

  $scope.init = () ->
    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.customFieldName = customFieldName
    $scope.customFieldName.field_object = 'deal'
    $scope.customFieldObjectTypes = [
      { name: 'Deal', value: 'deal' }
      { name: 'Deal Product', value: 'deal_product' }
      { name: 'Account', value: 'account' }
      { name: 'Contact', value: 'contact' }
      { name: 'Publisher', value: 'publisher' }
      { name: 'Activity', value: 'activity' }
      { name: 'IO Content Fee', value: 'content_fee' }
    ]

    $scope.customFieldOptions = [ {id: null, value: ""} ]
    $scope.errors = {}
    $scope.responseErrors = {}
    $scope.requiredChoices = [
      {name: "Yes", value: true},
      {name: "No", value: false}
    ]

  $scope.addCustomFieldOption = () ->
    $scope.customFieldOptions.push({id: null, value: ""})

  $scope.removeCustomFieldOption = (index) ->
    $scope.customFieldOptions.splice(index, 1)

  $scope.getfieldTypes = (field_object) ->
    if field_object == 'deal'
      DealCustomFieldName.field_type_list
    else if field_object == 'deal_product'
      DealProductCfName.field_type_list
    else if field_object == 'contact'
      ContactCfName.field_type_list
    else if field_object == 'account'
      AccountCfName.field_type_list
    else if field_object == 'publisher'
      PublisherCustomFieldName.field_type_list
    else
      CustomFieldNames.field_type_list

  onRequestSuccess = (customFieldName) ->
    $modalInstance.close()

  onRequestFail = (resp) ->
    $scope.responseErrors = resp.data.errors
    $scope.buttonDisabled = false

  $scope.submitForm = () ->
    $scope.errors = {}

    fields = ['field_type', 'field_label', 'position']

    fields.forEach (key) ->
      field = $scope.customFieldName[key]
      switch key
        when 'field_type'
          if !field then return $scope.errors[key] = 'Field Type is required'
        when 'field_label'
          if !field then return $scope.errors[key] = 'Field Label is required'
        when 'position'
          if !field then return $scope.errors[key] = 'Position is required'

    if Object.keys($scope.errors).length > 0 then return

    $scope.customFieldName.customFieldOptions = []
    $scope.customFieldOptions.forEach (item) ->
      if (item['value'].trim() != "")
        $scope.customFieldName.customFieldOptions.push(item)


    $scope.buttonDisabled = true

    switch $scope.customFieldName.field_object
      when 'deal'
        DealCustomFieldName.create(deal_custom_field_name: $scope.customFieldName).then(
          onRequestSuccess
          onRequestFail
        )
      when 'deal_product'
        DealProductCfName.create(deal_product_cf_name: $scope.customFieldName).then(
          onRequestSuccess
          onRequestFail
        )
      when 'account'
        AccountCfName.create(account_cf_name: $scope.customFieldName).then(
          onRequestSuccess
          onRequestFail
        )
      when 'contact'
        ContactCfName.create(contact_cf_name: $scope.customFieldName).then(
          onRequestSuccess
          onRequestFail
        )
      when 'publisher'
        PublisherCustomFieldName.create(publisher_custom_field_name: $scope.customFieldName).then(
          onRequestSuccess
          onRequestFail
        )
      else
        CustomFieldNames.create(subject_type: $scope.customFieldName.field_object, custom_field_name: $scope.customFieldName).then(
          onRequestSuccess
          onRequestFail
        )

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
