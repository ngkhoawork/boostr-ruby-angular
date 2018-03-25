@app.controller 'NewProductsController',
['$scope', '$modalInstance', 'Product', 'ProductFamily', 'Field', 'product', 'products', 'productFamilies', 'company',
( $scope,   $modalInstance,   Product,   ProductFamily,   Field,   product,   products,   productFamilies,   company) ->
  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.product = product || { active: true, auto_generated: true }
  $scope.revenueTypes = Product.revenue_types
  $scope.productFamilies =  productFamilies
  $scope.product_options_enabled = company.product_options_enabled
  $scope.products = _.filter products, (p) -> p.id != $scope.product.id && p.level != 2

  init = () ->
    if product
      $scope.formType = 'Edit'
      $scope.submitText = 'Save'
    else
      Field.defaults($scope.product, 'Product').then (fields) ->
        $scope.product.pricing_type = Field.field($scope.product, 'Pricing Type')

    $scope.products = _.map $scope.products, (p) -> 
      p.path = getProductPath(p)
      p

  getProductPath = (p, str=' > ') ->
    path = p.name
    parent = _.find products, (o) -> o.id == p.parent_id
    while parent
      path = parent.name + str + path
      parent = _.find products, (o) -> o.id == parent.parent_id
    path

  $scope.onChangeAutoGenerate = () ->
    if $scope.product.auto_generated
      $scope.product.full_name = getProductPath($scope.product, ' ')

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