@app.controller "SettingsDealCustomFieldNamesEditController",
['$scope', '$modalInstance', '$q', '$filter', 'DealCustomFieldName', 'User', 'TimePeriod', 'dealCustomFieldName',
($scope, $modalInstance, $q, $filter, DealCustomFieldName, User, TimePeriod, dealCustomFieldName) ->

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"
    $scope.dealCustomFieldName = dealCustomFieldName
    $scope.fieldTypes = DealCustomFieldName.field_type_list
    $scope.requiredChoices = [
      {name: "Yes", value: true},
      {name: "No", value: false}
    ]

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    DealCustomFieldName.update(id: dealCustomFieldName.id, deal_custom_field_name: $scope.dealCustomFieldName).then (dealCustomFieldName) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
