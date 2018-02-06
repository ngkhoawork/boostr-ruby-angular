@app.controller 'NewProductsController',
['$scope', '$modalInstance', 'Product', 'ProductFamily', 'Field', 'product', 'productFamilies', 'productOptions', 'company',
( $scope,   $modalInstance,   Product,   ProductFamily,   Field,   product,   productFamilies,   productOptions,   company) ->
  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.product = product || { active: true }
  $scope.revenueTypes = ['Display', 'Content-Fee']
  $scope.productFamilies =  productFamilies
  $scope.rootOptions = _.filter productOptions, (o) -> !o.product_option_id
  $scope.option1_field = company.product_option1_field
  $scope.option2_field = company.product_option2_field
  $scope.product_options_enabled = company.product_options_enabled

  init = () ->
    if product
      $scope.formType = 'Edit'
      $scope.submitText = 'Save'
    else
      Field.defaults($scope.product, 'Product').then (fields) ->
        $scope.product.pricing_type = Field.field($scope.product, 'Pricing Type')

  $scope.getSubOptions = () ->
    if $scope.product.option1_id
      _.filter productOptions, (o) -> o.product_option_id == $scope.product.option1_id

  $scope.submitForm = () ->
    $scope.errors = {}

    if (!$scope.product.name)
      $scope.errors['name'] = 'Name is required'
    if (!$scope.product.revenue_type)
      $scope.errors['revenue_type'] = 'Revenue Type is required'
    $scope.product.margin = parseInt($scope.product.margin)
    if $scope.product.margin < 1 || $scope.product.margin > 100
      $scope.errors['margin'] = 'Enter a valid margin between 1 and 100'

    if Object.keys($scope.errors).length > 0 then return
    
    if $scope.formType == 'New'
      Product.create(product: $scope.product).then (product) ->
        $modalInstance.close()
    else
      Product.update(id: $scope.product.id, product: $scope.product).then (product) ->
        $scope.product = product
        $modalInstance.close()

  $scope.cancel = ->
    $modalInstance.dismiss()

  init()
]