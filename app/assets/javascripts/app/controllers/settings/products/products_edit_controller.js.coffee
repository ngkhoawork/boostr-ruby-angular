@app.controller "ProductsEditController",
['$scope', '$modalInstance', '$filter', 'Product', 'ProductFamily', 'Field', 'product',
( $scope,   $modalInstance,   $filter,   Product,   ProductFamily,   Field,   product) ->

  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.revenue_types = ['Display', 'Content-Fee']

  ProductFamily.all(active: true).then (product_families) ->
    $scope.product_families = product_families
  Field.defaults(product, 'Product').then (fields) ->
    $scope.product = product

  $scope.submitForm = () ->
    $scope.errors = {}

    if (!$scope.product.name)
      $scope.errors['name'] = 'Name is required'
    if (!$scope.product.revenue_type)
      $scope.errors['revenue_type'] = 'Revenue Type is required'
    $scope.product.margin = parseInt($scope.product.margin)
    if $scope.product.margin < 1 || $scope.product.margin > 100
      $scope.errors['margin'] = 'Margin should be in a range of 1 to 100'

    if Object.keys($scope.errors).length > 0 then return
    
    $scope.buttonDisabled = true
    Product.update(id: $scope.product.id, product: $scope.product).then (product) ->
      $scope.product = product
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]
