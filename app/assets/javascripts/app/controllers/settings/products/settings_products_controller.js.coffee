@app.controller 'SettingsProductsController',
  ['$scope', '$modal', '$window', 'Product', 'ProductFamily', 'Field', '$routeParams', '$location', 'Company', 'ProductOption',
  ( $scope,   $modal,   $window,   Product,   ProductFamily,   Field,   $routeParams,   $location,   Company,   ProductOption) ->
    $scope.expendedRow = null
    $scope.productUnits = {}
    $scope.isUnitsLoading = {}
    $scope.menus = [
      { name: 'Products', value: 'products' }
      { name: 'Product Familes', value: 'product_families' }
    ]
    $scope.selectedMenu = $routeParams.tab || $scope.menus[0].value
    $scope.company = {}
    $scope.products = []
    $scope.productFamilies = []
    $scope.productOptions = []
    $scope.selectedOption = {}

    $scope.init = () ->
      Company.get().$promise.then (company) ->
        $scope.company = company
        if company.product_options_enabled
          $scope.menus.push { name: 'Product Options', value: 'product_options' }
      getProductFamilies()
      getProducts()
      getProductOptions()

    $scope.onSelectMenu = (value) ->
      $scope.selectedMenu = value
      # $location.search({tab: value})

    $scope.updateSettings = () ->
      $scope.company.$update().then (company) ->
        if company.product_options_enabled && $scope.menus.length == 2
          $scope.menus.push { name: 'Product Options', value: 'product_options' }
        else if !company.product_options_enabled && $scope.menus.length == 3
          $scope.menus.pop()

    $scope.addOption = (isSub=false) ->
      if isSub
        $scope.productOptions.push { name: '', product_option_id: $scope.selectedOption.id }
      else
        $scope.productOptions.push { name: '' }

    $scope.updateOption = (option, isSub=false) ->
      if isSub
        option.product_option_id = $scope.selectedOption.id
      if !option.id && option.name
        ProductOption.create(option).then (o) ->
          index = $scope.productOptions.indexOf(option)
          $scope.productOptions[index] = o
          $scope.selectedOption = o if $scope.selectedOption == option
      else if option.id
        ProductOption.update(option)

    $scope.deleteOption = (option) ->
      if confirm('Are you sure you want to delete "' +  option.name + '"?')
        ProductOption.delete(option).then () ->
          index = $scope.productOptions.indexOf(option)
          $scope.productOptions.splice(index, 1)
          $scope.selectedOption = null if $scope.selectedOption == option

    $scope.getSubOptions = (option) ->
      if option && option.id
        _.filter $scope.productOptions, (o) -> o.product_option_id == option.id

    $scope.getOptions = () ->
      _.filter $scope.productOptions, (o) -> !o.product_option_id

    $scope.setOption = (option) ->
      $scope.selectedOption = option

    getProductOptions = () ->
      ProductOption.all().then (productOptions) ->
        $scope.productOptions = productOptions
        $scope.selectedOption = _.find productOptions, (o) -> !o.product_option_id

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
      console.log(product)
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/product_form.html'
        size: 'md'
        controller: 'NewProductsController'
        backdrop: 'static'
        keyboard: false
        resolve:
          product: ->
            angular.copy product
          productFamilies: ->
            angular.copy $scope.productFamilies
          productOptions: ->
            angular.copy $scope.productOptions
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
