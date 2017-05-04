@app.controller "ProductsEditController",
['$scope', '$modalInstance', '$filter', 'Product', 'Field', 'product',
($scope, $modalInstance, $filter, Product, Field, product) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.revenue_types = ['Display', 'Content-Fee', 'Print', 'Programmatic', 'None']

  Field.defaults(product, 'Product').then (fields) ->
#    $scope.product.pricing_type = product.pricing_type
#    product.pricing_type = Field.field(product, 'Pricing Type')
#    product.product_line = Field.field(product, 'Product Line')
#    product.product_family = Field.field(product, 'Product Family')
    $scope.product = product
    console.log($scope.product)

  $scope.submitForm = () ->
    $scope.errors = {}

    fields = ['revenue_type']

    if (!$scope.product.revenue_type)
      $scope.errors['revenue_type'] = 'Revenue Type is required'

    if Object.keys($scope.errors).length > 0 then return
    
    $scope.buttonDisabled = true
    Product.update(id: $scope.product.id, product: $scope.product).then (product) ->
      $scope.product = product
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
