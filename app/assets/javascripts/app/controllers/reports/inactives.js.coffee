@app.controller 'InactivesController',
    ['$scope', '$document', 'Product', 'Field'
        ($scope, $document, Product, Field) ->
            $scope.test = 15
    ]