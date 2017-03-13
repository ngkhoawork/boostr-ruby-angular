@app.controller 'InitiativeFormController',
    ['$scope', '$modalInstance', 'Initiatives', 'initiative',
        ($scope, $modalInstance, Initiatives, initiative) ->

            $scope.initiative = {}
            $scope.headerPrefix = 'New'
            $scope.submitButtonText = 'Create'
            $scope.selectedStatus = ''
            $scope.statuses = ['Open', 'Closed']

            $scope.setStatus = (status) ->
                $scope.initiative.status = status

            if initiative
                $scope.initiative = initiative
                $scope.headerPrefix = 'Edit'
                $scope.submitButtonText = 'Save'
            else
                $scope.setStatus($scope.statuses[0])


            $scope.cancel = ->
                $modalInstance.close()

            $scope.submitForm = ->
                if initiative
                    Initiatives.update($scope.initiative).then (data) ->
                        $scope.cancel()
                    , (err) ->
                        console.log err
                else
                    Initiatives.create($scope.initiative).then (data) ->
                        $scope.cancel()
                    , (err) ->
                        console.log err
    ]
