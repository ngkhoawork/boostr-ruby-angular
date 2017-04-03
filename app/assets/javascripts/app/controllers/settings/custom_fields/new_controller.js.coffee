@app.controller "SettingsDealCustomFieldNamesNewController",
['$scope', '$modalInstance', '$q', '$filter', 'DealCustomFieldName', 'DealProductCfName', 'User', 'TimePeriod', 'customFieldName',
($scope, $modalInstance, $q, $filter, DealCustomFieldName, DealProductCfName, User, TimePeriod, customFieldName) ->

  $scope.init = () ->
    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.customFieldName = customFieldName
    $scope.customFieldObjectTypes = [
      { name: 'Deal', value: 'deal' }
      { name: 'Deal Product', value: 'deal_product' }
    ]
    $scope.fieldTypes = DealCustomFieldName.field_type_list
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


  $scope.submitForm = () ->
    $scope.errors = {}

    console.log()

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


    if $scope.customFieldName.field_object == 'deal'
      DealCustomFieldName.create(deal_custom_field_name: $scope.customFieldName).then(
        (customFieldName) ->
          $modalInstance.close()
        (resp) ->
          $scope.responseErrors = resp.data.errors
          $scope.buttonDisabled = false
      )
    if $scope.customFieldName.field_object == 'deal_product'
      DealProductCfName.create(deal_product_cf_name: $scope.customFieldName).then(
        (customFieldName) ->
          $modalInstance.close()
        (resp) ->
          $scope.responseErrors = resp.data.errors
          $scope.buttonDisabled = false
      )

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
