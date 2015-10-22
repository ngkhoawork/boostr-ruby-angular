@app.controller 'SettingsProductsController',
['$scope', '$modal', 'Product', 'Field',
($scope, $modal, Product, Field) ->

  $scope.init = () ->
    Product.all().then (products) ->
      $scope.products = products
      _.each $scope.products, (product) ->
        Field.defaults(product, 'Product').then (fields) ->
          product.pricing_type = Field.field(product, 'Pricing Type')
          product.product_line = Field.field(product, 'Product Line')

  $scope.showModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/product_form.html'
      size: 'lg'
      controller: 'NewProductsController'
      backdrop: 'static'
      keyboard: false

  $scope.editModal = (product) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/product_form.html'
      size: 'lg'
      controller: 'ProductsEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        product: ->
          product

  $scope.$on 'updated_products', ->
    $scope.init()

  $scope.init()

]
