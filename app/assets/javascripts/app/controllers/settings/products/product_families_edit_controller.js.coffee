@app.controller "ProductFamiliesEditController",
['$scope', '$modalInstance', 'ProductFamily', 'product_family',
($scope, $modalInstance, ProductFamily, product_family) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.product_family = product_family

  $scope.submitForm = () ->
    $scope.errors = {}

    if (!$scope.product_family.name)
      $scope.errors['name'] = 'Name is required'
    if Object.keys($scope.errors).length > 0 then return
    
    $scope.buttonDisabled = true
    ProductFamily.update(id: $scope.product_family.id, product_family: $scope.product_family).then (product_family) ->
      $scope.product_family = product_family
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
