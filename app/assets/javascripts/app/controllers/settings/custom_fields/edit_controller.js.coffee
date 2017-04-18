@app.controller "SettingsDealCustomFieldNamesEditController",
['$scope', '$modalInstance', '$q', '$filter', 'DealCustomFieldName', 'DealProductCfName', 'ContactCfName', 'User', 'TimePeriod', 'customFieldName', 'objectType',
($scope, $modalInstance, $q, $filter, DealCustomFieldName, DealProductCfName, ContactCfName, User, TimePeriod, customFieldName, objectType) ->

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"
    $scope.customFieldName = customFieldName
    $scope.customFieldName.field_object = objectType
    $scope.customFieldOptions = customFieldName.deal_custom_field_options
    if !$scope.customFieldOptions || $scope.customFieldOptions.length == 0
      $scope.customFieldOptions = [ {id: null, value: ""} ]
    $scope.fieldTypes = DealCustomFieldName.field_type_list
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

  $scope.submitForm = () ->
    $scope.buttonDisabled = true

    $scope.customFieldName.customFieldOptions = []
    $scope.customFieldOptions.forEach (item) ->
      if (item['value'].trim() != "")
        $scope.customFieldName.customFieldOptions.push(item)

    if $scope.customFieldName.field_object == 'deal'
      DealCustomFieldName.update(id: customFieldName.id, deal_custom_field_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()

    if $scope.customFieldName.field_object == 'deal_product'
      DealProductCfName.update(id: customFieldName.id, deal_product_cf_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()

    if $scope.customFieldName.field_object == 'contact'
      ContactCfName.update(id: customFieldName.id, contact_cf_name: $scope.customFieldName).then (customFieldName) ->
        $modalInstance.close()


  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
