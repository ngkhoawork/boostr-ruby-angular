@app.controller 'DealWarningController',
    ['$scope', '$modalInstance', 'message'
        ($scope, $modalInstance, message) ->

            $scope.message = message

            $scope.cancel = ->
                $modalInstance.close()

    ]
