@app.controller "ClientsEditController",
['$scope', '$modalInstance', '$filter', 'Client', 'Field', 'client'
($scope, $modalInstance, $filter, Client, Field, client) ->
  $scope.client = client

  $scope.init = () ->
    $scope.formType = "Edit"
    $scope.submitText = "Update"

    Field.defaults($scope.client, 'Client').then (fields) ->
      if ($scope.client.client_type)
        selectedOption = $scope.client.client_type.option || null
      $scope.client.client_type = Field.field($scope.client, 'Client Type')
      if (selectedOption)
        $scope.client.client_type.options.forEach (option) ->
          if option.name == selectedOption
            $scope.client.client_type.option_id = option.id
      $scope.setClientTypes()

    client_category_id = $scope.client.client_category_id
    if client_category_id
      $scope.setCategory(client_category_id)

    if $scope.client && $scope.client.address
      $scope.client.address.phone = $filter('tel')($scope.client.address.phone)

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.client.$update(
      -> $modalInstance.close(),
      (resp) ->
        $scope.errors = resp.data.errors
        $scope.buttonDisabled = false
    )

  $scope.setCategory = (id) ->
    $scope.client.fields.forEach (field) ->
      if (field.name == 'Category')
        field.options.forEach (category) ->
          if category.id == id
            $scope.current_category = category

  $scope.setClientTypes = () ->
    $scope.client.client_type.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.updateCategory = (category) ->
    $scope.client.client_subcategory_id = undefined
    $scope.current_category = category

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.init()
]
