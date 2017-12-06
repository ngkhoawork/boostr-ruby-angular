@app.controller 'NewProductFamiliesController',
['$scope', '$modalInstance', 'ProductFamily',
($scope, $modalInstance, ProductFamily) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.product_family = { active: true }

  $scope.submitForm = () ->
    $scope.errors = {}

    if (!$scope.product_family.name)
      $scope.errors['name'] = 'Name is required'

    if Object.keys($scope.errors).length > 0 then return
    
    $scope.buttonDisabled = true
    ProductFamily.create(product_family: $scope.product_family).then (product_family) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]