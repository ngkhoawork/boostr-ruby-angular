@app.controller "SettingsDealCustomFieldNamesNewController",
['$scope', '$modalInstance', '$q', '$filter', 'DealCustomFieldName', 'User', 'TimePeriod', 'dealCustomFieldName',
($scope, $modalInstance, $q, $filter, DealCustomFieldName, User, TimePeriod, dealCustomFieldName) ->

  $scope.init = () ->
    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.dealCustomFieldName = dealCustomFieldName
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

    fields = ['field_type', 'field_label', 'position']

    fields.forEach (key) ->
      field = $scope.dealCustomFieldName[key]
      switch key
        when 'field_type'
          if !field then return $scope.errors[key] = 'Field Type is required'
        when 'field_label'
          if !field then return $scope.errors[key] = 'Field Label is required'
        when 'position'
          if !field then return $scope.errors[key] = 'Position is required'

    if Object.keys($scope.errors).length > 0 then return

    $scope.dealCustomFieldName.dealCustomFieldOptions = []
    $scope.customFieldOptions.forEach (item) ->
      if (item['value'].trim() != "")
        $scope.dealCustomFieldName.dealCustomFieldOptions.push(item)


    $scope.buttonDisabled = true
    DealCustomFieldName.create(deal_custom_field_name: $scope.dealCustomFieldName).then(
      (dealCustomFieldName) ->
        $modalInstance.close()
      (resp) ->
        $scope.responseErrors = resp.data.errors
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.close()

  $scope.init()

]
