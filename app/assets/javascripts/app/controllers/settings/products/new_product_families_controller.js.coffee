@app.controller 'NewProductFamiliesController',
['$scope', '$modalInstance', 'ProductFamily', 'productFamily',
( $scope,   $modalInstance,   ProductFamily,   productFamily) ->
  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.productFamily = productFamily || { active: true }

  init = () ->
    if productFamily
      $scope.formType = 'Edit'
      $scope.submitText = 'Save'

  $scope.submitForm = () ->
    $scope.errors = {}

    if (!$scope.productFamily.name)
      $scope.errors['name'] = 'Name is required'

    if Object.keys($scope.errors).length > 0 then return
    
    if $scope.formType == 'New'
      ProductFamily.create(product_family: $scope.productFamily).then (productFamily) ->
        $modalInstance.close()
    else
      ProductFamily.update(id: $scope.productFamily.id, product_family: $scope.productFamily).then (productFamily) ->
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()

  init()
]