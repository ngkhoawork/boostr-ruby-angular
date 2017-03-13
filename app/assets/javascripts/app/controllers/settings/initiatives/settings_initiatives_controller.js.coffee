@app.controller 'SettingsInitiativesController',
    ['$scope', '$modal', 'Initiatives'
        ($scope, $modal, Initiatives) ->
            $scope.initiatives = []

            getInitiatives = ->
                Initiatives.all().then (data) ->
                    $scope.initiatives = data
                , (err) ->
                    console.log err
            getInitiatives()

            $scope.showInitiativeModal = (initiative) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/initiative_form.html'
                    size: 'md'
                    controller: 'InitiativeFormController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        initiative: ->
                            angular.copy initiative
            
            $scope.deleteInitiative = (initiative) ->
                if confirm('Are you sure you want to delete "' +  initiative.name + '"?')
                    Initiatives.delete(initiative).then(
                        (initiative) ->
                        (err) ->
                            console.log err
                    )

            $scope.$on 'initiatives_updated', getInitiatives
    ]
