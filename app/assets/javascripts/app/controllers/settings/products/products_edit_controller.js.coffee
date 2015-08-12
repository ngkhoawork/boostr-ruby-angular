@app.controller "ProductsEditController",
['$scope', '$modalInstance', '$filter', 'Product', 'product',
($scope, $modalInstance, $filter, Product, product) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.product = product
  $scope.product_lines = Product.product_lines()
  $scope.families = Product.families()
  $scope.pricing_types = Product.pricing_types()

  $scope.submitForm = () ->
    Product.update(id: $scope.product.id, product: $scope.product).then (product) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
