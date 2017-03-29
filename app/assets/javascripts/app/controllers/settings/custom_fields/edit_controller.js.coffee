@app.controller "SettingsDealCustomFieldNamesEditController",
['$scope', '$modalInstance', '$q', '$filter', 'DealCustomFieldName', 'User', 'TimePeriod', 'dealCustomFieldName',
($scope, $modalInstance, $q, $filter, DealCustomFieldName, User, TimePeriod, dealCustomFieldName) ->

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"
    $scope.dealCustomFieldName = dealCustomFieldName
    $scope.customFieldOptions = dealCustomFieldName.deal_custom_field_options
    if $scope.customFieldOptions.length == 0
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

  $scope.submitForm = () ->
    $scope.buttonDisabled = true

    $scope.dealCustomFieldName.dealCustomFieldOptions = []
    $scope.customFieldOptions.forEach (item) ->
      if (item['value'].trim() != "")
        $scope.dealCustomFieldName.dealCustomFieldOptions.push(item)

    DealCustomFieldName.update(id: dealCustomFieldName.id, deal_custom_field_name: $scope.dealCustomFieldName).then (dealCustomFieldName) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
