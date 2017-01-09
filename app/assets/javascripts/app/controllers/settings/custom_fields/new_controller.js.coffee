@app.controller "SettingsDealCustomFieldNamesNewController",
['$scope', '$modalInstance', '$q', '$filter', 'DealCustomFieldName', 'User', 'TimePeriod', 'dealCustomFieldName',
($scope, $modalInstance, $q, $filter, DealCustomFieldName, User, TimePeriod, dealCustomFieldName) ->

  $scope.init = () ->
    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.dealCustomFieldName = dealCustomFieldName
    $scope.fieldTypes = DealCustomFieldName.field_type_list
    $scope.requiredChoices = [
      {name: "Yes", value: true},
      {name: "No", value: false}
    ]

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    DealCustomFieldName.create(deal_custom_field_name: $scope.dealCustomFieldName).then (dealCustomFieldName) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
