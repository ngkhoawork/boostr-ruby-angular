@app.controller "SettingsDealCustomFieldNamesEditController",
['$scope', '$modalInstance', '$q', '$filter', 'CustomFieldNames', 'DealCustomFieldName', 'DealProductCfName', 'AccountCfName', 'ContactCfName', 'PublisherCustomFieldName', 'User', 'TimePeriod', 'customFieldName', 'objectType',
($scope, $modalInstance, $q, $filter, CustomFieldNames, DealCustomFieldName, DealProductCfName, AccountCfName, ContactCfName, PublisherCustomFieldName, User, TimePeriod, customFieldName, objectType) ->

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"
    $scope.customFieldName = customFieldName
    $scope.customFieldName.field_object = objectType
    $scope.customFieldOptions = getFieldOptions()

    if !$scope.customFieldOptions || $scope.customFieldOptions.length == 0
      $scope.customFieldOptions = [ {id: null, value: ""} ]
    $scope.fieldTypes = DealCustomFieldName.field_type_list
    $scope.requiredChoices = [
      {name: "Yes", value: true},
      {name: "No", value: false}
    ]

  getFieldOptions = () ->
    switch $scope.customFieldName.field_object
      when 'deal' then $scope.customFieldName.deal_custom_field_options
      when 'deal_product' then $scope.customFieldName.deal_product_cf_options
      when 'account' then $scope.customFieldName.account_cf_options
      when 'contact' then $scope.customFieldName.contact_cf_options
      when 'publisher' then $scope.customFieldName.publisher_custom_field_options
      when 'activity' then $scope.customFieldName.customFieldOptions

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
    else if field_object == 'activity'
      CustomFieldNames.field_type_list

  $scope.submitForm = () ->
    $scope.buttonDisabled = true

    $scope.customFieldName.customFieldOptions = []
    $scope.customFieldOptions.forEach (item) ->
      if (item['value'].trim() != "")
        $scope.customFieldName.customFieldOptions.push(item)

    switch $scope.customFieldName.field_object
      when 'deal' then DealCustomFieldName.update(id: customFieldName.id, deal_custom_field_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()
      when 'deal_product' then DealProductCfName.update(id: customFieldName.id, deal_product_cf_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()
      when 'account' then AccountCfName.update(id: customFieldName.id, account_cf_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()
      when 'contact' then ContactCfName.update(id: customFieldName.id, contact_cf_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()
      when 'publisher' then PublisherCustomFieldName.update(id: customFieldName.id, publisher_custom_field_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()
      when 'activity' then CustomFieldNames.update(subject_type: $scope.customFieldName.field_object, id: customFieldName.id, custom_field_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
