@app.controller 'NewProductsController',
['$scope', '$modalInstance', 'Product', 'ProductFamily', 'Field',
( $scope,   $modalInstance,   Product,   ProductFamily,   Field) ->

  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.product = { active: true }
  $scope.revenue_types = ['Display', 'Content-Fee']

  ProductFamily.all(active: true).then (product_families) ->
    $scope.product_families = product_families
  Field.defaults($scope.product, 'Product').then (fields) ->
    $scope.product.revenue_type = ""
    $scope.product.pricing_type = Field.field($scope.product, 'Pricing Type')

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
    Product.create(product: $scope.product).then (product) ->
      $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.close()
]