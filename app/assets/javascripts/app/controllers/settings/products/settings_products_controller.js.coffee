@app.controller 'SettingsProductsController',
['$scope', '$modal', 'Product',
($scope, $modal, Product) ->

  $scope.init = () ->
    Product.all().then (products) ->
      $scope.products = products

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
