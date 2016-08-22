@app.controller "ClientsNewController",
['$scope', '$rootScope', '$modalInstance', 'Client', 'Field', 'client'
($scope, $rootScope, $modalInstance, Client, Field, client) ->

  $scope.formType = "New"
  $scope.submitText = "Create"
  $scope.client = new Client(client || {})
  Field.defaults($scope.client, 'Client').then (fields) ->
    if ($scope.client.client_type)
      selectedOption = $scope.client.client_type.option || null
    $scope.client.client_type = Field.field($scope.client, 'Client Type')
    if (selectedOption)
      $scope.client.client_type.options.forEach (option) ->
        if option.name == selectedOption
          $scope.client.client_type.option_id = option.id
    $scope.setClientTypes()

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    $scope.removeCategoriesFromAgency()
    $scope.client.$save ->
      $rootScope.$broadcast 'newClient', $scope.client
      $modalInstance.close()

  $scope.updateCategory = (category) ->
    $scope.client.client_subcategory_id = undefined
    $scope.current_category = category

  $scope.setClientTypes = () ->
    $scope.client.client_type.options.forEach (option) ->
      $scope[option.name] = option.id

  $scope.removeCategoriesFromAgency = () ->
    if $scope.client.client_type.option_id == $scope.Agency
      $scope.client.client_category_id = null
      $scope.client.client_subcategory_id = null

  $scope.cancel = ->
    $modalInstance.dismiss()
]
