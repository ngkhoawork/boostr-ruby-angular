@app.controller 'NewProductsController',
['$scope', '$modalInstance', 'Product',
($scope, $modalInstance, Product) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.product = {}

  $scope.product_lines = Product.product_lines()
  $scope.families = Product.families()
  $scope.pricing_types = Product.pricing_types()

  $scope.submitForm = () ->
    Product.create(product: $scope.product).then (product) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]