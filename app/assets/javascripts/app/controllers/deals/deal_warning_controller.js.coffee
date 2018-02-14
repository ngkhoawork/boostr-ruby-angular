@app.controller 'DealWarningController',
    ['$scope', '$modalInstance', 'message', 'id', 'localStorageService'
        ($scope, $modalInstance, message, id, localStorageService) ->

            $scope.message = message
            $scope.dealId = id
            $scope.dontShowWarnings = false
            $scope.getWarningSettings = () ->
                localStorageService.get('dealsWithoutWarning')

            settings = $scope.getWarningSettings() || []
            settings.forEach((deal) -> 
                if deal.dealId == $scope.dealId
                    $scope.dontShowWarnings = true
            )
            

            $scope.setWarningSettings = (newSetting) ->
                settings = $scope.getWarningSettings() or []
                isNewSetting = true

                if settings.length != 0
                    settings.forEach((setting, index) ->
                        if setting.dealId is newSetting.dealId
                            settings.splice(index, 1)
                            localStorageService.set('dealsWithoutWarning', settings)
                            isNewSetting = false
                    )
                if isNewSetting
                    settings.push(newSetting)

                localStorageService.set('dealsWithoutWarning', settings)
                isNewSetting = true

            $scope.onChange = ->
                $scope.setWarningSettings dealId: $scope.dealId

            $scope.cancel = ->
                $modalInstance.close()

    ]
