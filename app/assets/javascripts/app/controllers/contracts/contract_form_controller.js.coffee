@app.controller "ContractFormController", [
    '$scope', '$modalInstance'
    ($scope,   $modalInstance) ->
        $scope.formType = "New"
        $scope.submitText = "Create"


        $scope.cancel = ->
            $modalInstance.dismiss()
]
