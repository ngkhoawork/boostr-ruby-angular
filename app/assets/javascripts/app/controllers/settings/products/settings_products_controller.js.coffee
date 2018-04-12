@app.controller 'SettingsProductsController',
  ['$scope', '$modal', '$window', 'Product', 'ProductFamily', 'Field', '$routeParams', '$location', 'Company',
  ( $scope,   $modal,   $window,   Product,   ProductFamily,   Field,   $routeParams,   $location,   Company) ->
    $scope.expendedRow = null
    $scope.productUnits = {}
    $scope.isUnitsLoading = {}
    $scope.menus = [
      { name: 'Products', value: 'products' }
      { name: 'Product Familes', value: 'product_families' }
      { name: 'Settings', value: 'settings' }
    ]
    $scope.selectedMenu = $routeParams.tab || $scope.menus[0].value
    $scope.company = {}
    $scope.products = []
    $scope.productFamilies = []

    $scope.init = () ->
      Company.get().$promise.then (company) ->
        $scope.company = company
      getProductFamilies()
      getProducts()

    $scope.onSelectMenu = (value) ->
      $scope.selectedMenu = value
      # $location.search({tab: value})

    $scope.updateSettings = () ->
      $scope.company.$update()

    $scope.enableProductOption1 = () ->
      if !$scope.company.product_option1_enabled
        $scope.company.product_option2_enabled = false
      $scope.updateSettings()

    $scope.enableProductOption2 = () ->
      if $scope.company.product_option2_enabled
        $scope.company.product_option1_enabled = true
      $scope.updateSettings()

    getProducts = () ->
      Product.all().then (products) ->
        $scope.products = products
        _.each $scope.products, (product) ->
          Field.defaults(product, 'Product').then (fields) ->
            product.pricing_type = Field.field(product, 'Pricing Type')

    getProductFamilies = () ->
      ProductFamily.all().then (productFamilies) ->
        $scope.productFamilies = productFamilies

    getProductUnits = (product_id) ->
      $scope.isUnitsLoading[product_id] = true
      Product.get_units(product_id: product_id).then (data) ->
        $scope.productUnits[product_id] = data
        $scope.isUnitsLoading[product_id] = false

    $scope.expendRow = (product) ->
      $scope.expendedRow = if $scope.expendedRow != product.id then product.id else null
      if !$scope.productUnits[product.id] then getProductUnits(product.id)

    $scope.showNewProductModal = (product=null) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/product_form.html'
        size: 'md'
        controller: 'NewProductsController'
        backdrop: 'static'
        keyboard: false
        resolve:
          product: ->
            angular.copy product
          products: ->
            angular.copy $scope.products
          productFamilies: ->
            angular.copy $scope.productFamilies
          company: ->
            angular.copy $scope.company

    $scope.showUnitModal = (product, unit) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/settings_products_unit_form.html'
        size: 'md'
        controller: 'ProductsUnitsController'
        backdrop: 'static'
        keyboard: false
        resolve:
          product: -> product
          unit: -> angular.copy unit

    $scope.deleteUnit = (product, unit) ->
      if confirm('Are you sure you want to delete "' +  unit.name + '"?')
        Product.delete_unit({
          product_id: product.id
          id: unit.id
        })

    $scope.showNewFamilyModal = (productFamily=null) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/product_family_form.html'
        size: 'md'
        controller: 'NewProductFamiliesController'
        backdrop: 'static'
        keyboard: false
        resolve:
          productFamily: ->
            angular.copy productFamily

    $scope.deleteFamily = (productFamily) ->
      if confirm('Are you sure you want to delete "' +  productFamily.name + '"?')
        ProductFamily.delete(id: productFamily.id)

    $scope.$on 'updated_product_families', ->
      getProductFamilies()
      getProducts()

    $scope.$on 'updated_products', ->
      getProducts()

    $scope.$on 'updated_product_units', (e, product_id)->
      getProductUnits(product_id)

    $scope.exportProducts = ->
      $window.open('/api/products.csv')
      return true

    $scope.init()
  ]
