@app.controller 'ActivityEmailsController',
    ['$scope', '$modalInstance', '$sce', 'activity',
        ($scope, $modalInstance, $sce, activity) ->
            $scope.activity = activity
            console.log(activity)
            $scope.cancel = ->
                $modalInstance.close()

            $scope.getHtml = (html) ->
                return $sce.trustAsHtml(html)
    ]
