@app.controller 'NewProductsController',
['$scope', '$modalInstance', 'Product', 'Field',
($scope, $modalInstance, Product, Field) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.product = {}

  Field.defaults($scope.product, 'Product').then (fields) ->
    $scope.product.pricing_type = Field.field($scope.product, 'Pricing Type')
    $scope.product.product_line = Field.field($scope.product, 'Product Line')
    $scope.product.product_family = Field.field($scope.product, 'Product Family')

  $scope.submitForm = () ->
    $scope.buttonDisabled = true
    Product.create(product: $scope.product).then (product) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]