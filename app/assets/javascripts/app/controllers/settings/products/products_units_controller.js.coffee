@app.controller "ProductsUnitsController",
    ['$scope', '$modalInstance', 'Product', 'product', 'unit'
    ( $scope,   $modalInstance,   Product,   product,   unit ) ->

        $scope.headerText = if unit then 'Edit Ad unit' else 'Add Ad unit to ' + product.name
        $scope.submitText = if unit then 'Save' else 'Add'

        $scope.productUnit = unit || {}

        $scope.submitForm = () ->
            $scope.errors = {}

            fields = ['name']

            fields.forEach (key) ->
                field = $scope.productUnit[key]
                switch key
                    when 'name'
                        if !field then return $scope.errors[key] = 'Name is required'

            if Object.keys($scope.errors).length > 0 then return

            if unit
                Product.update_unit({
                    product_id: product.id
                    id: $scope.productUnit.id
                    ad_unit: $scope.productUnit
                }).then (resp) -> $scope.cancel()
            else
                Product.add_unit({
                    product_id: product.id
                    ad_unit: $scope.productUnit
                }).then (resp) -> $scope.cancel()

        $scope.cancel = ->
            $modalInstance.dismiss()
    ]