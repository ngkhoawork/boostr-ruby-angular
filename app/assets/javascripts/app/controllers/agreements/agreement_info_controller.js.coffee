@app.controller 'AgreementInfoController',
['$scope', '$modalInstance', 'options'
($scope, $modalInstance, options) ->
    init = ->
        $scope.message = options.messages[0]
        $scope.typeOfExcluded = options.typeOfExcluded
        $scope.typeOfUpdate = options.typeOfUpdate
        $scope.isObject = false
        $scope.isString = false
        $scope.isSingular = true

        if $scope.message != null && typeof $scope.message == 'object'
            $scope.isObject = true
            length = $scope.message.excluded_objects.length

            if length == 1 then $scope.isSingular = true else $scope.isSingular = false

        else if typeof $scope.message == 'string'
            $scope.isString = true

    $scope.close = -> $modalInstance.close()

    init()    
]