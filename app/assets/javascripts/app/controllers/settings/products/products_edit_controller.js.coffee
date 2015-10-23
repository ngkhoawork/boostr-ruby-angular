@app.controller "ProductsEditController",
['$scope', '$modalInstance', '$filter', 'Product', 'Field', 'product',
($scope, $modalInstance, $filter, Product, Field, product) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  Field.defaults(product, 'Product').then (fields) ->
    product.pricing_type = Field.field(product, 'Pricing Type')
    product.product_line = Field.field(product, 'Product Line')
    product.product_family = Field.field(product, 'Product Family')
    $scope.product = product

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Product.update(id: $scope.product.id, product: $scope.product).then (product) ->
      $scope.product = product
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
