@app.controller 'SettingsProductsController',
    ['$scope', '$modal', '$window', 'Product', 'Field',
    ( $scope,   $modal,   $window,   Product,   Field) ->
        $scope.expendedRow = null
        $scope.productUnits = {}
        $scope.isUnitsLoading = {}

        $scope.init = () ->
            Product.all().then (products) ->
                $scope.products = products
                _.each $scope.products, (product) ->
                    Field.defaults(product, 'Product').then (fields) ->
                        product.pricing_type = Field.field(product, 'Pricing Type')
                        product.product_line = Field.field(product, 'Product Line')
                        product.product_family = Field.field(product, 'Product Family')

        getProductUnits = (product_id) ->
            $scope.isUnitsLoading[product_id] = true
            Product.get_units(product_id: product_id).then (data) ->
                $scope.productUnits[product_id] = data
                $scope.isUnitsLoading[product_id] = false


        $scope.expendRow = (product) ->
            $scope.expendedRow = if $scope.expendedRow != product.id then product.id else null
            if !$scope.productUnits[product.id] then getProductUnits(product.id)

        $scope.showModal = () ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/product_form.html'
                size: 'md'
                controller: 'NewProductsController'
                backdrop: 'static'
                keyboard: false

        $scope.editModal = (product) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/product_form.html'
                size: 'md'
                controller: 'ProductsEditController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    product: ->
                        product

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

        $scope.$on 'updated_products', ->
            $scope.init()
        $scope.$on 'updated_product_units', (e, product_id)->
            getProductUnits(product_id)

        $scope.exportProducts = ->
            $window.open('/api/products.csv')
            return true

        $scope.init()

    ]
