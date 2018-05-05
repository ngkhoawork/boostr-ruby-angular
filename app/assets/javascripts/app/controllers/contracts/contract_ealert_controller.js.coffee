@app.controller 'ContractsEalertController', [
    '$scope', '$modalInstance', 'Ealert', 'contract'
    ($scope,   $modalInstance,   Ealert,   contract) ->

        $scope.contract = contract
        $scope.comment = ''
        $scope.email = ''
        $scope.recipient_list = []
        $scope.errors = {}

        validateEmail = (email) ->
            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            re.test(email)

        $scope.addRecipient = ->
            if $scope.errors && $scope.errors['recipient']
                delete $scope.errors['recipient']

            $scope.errors.email = !validateEmail($scope.email)
            return if !$scope.email || $scope.errors.email

            index = _.find $scope.recipient_list, (recipient) -> recipient == $scope.email
            if index == undefined
                $scope.recipient_list.push($scope.email)
            $scope.email = ''

        $scope.cancel = ->
            $modalInstance.close()

        $scope.submitForm = () ->
            $scope.errors = {}

            if $scope.recipient_list.length == 0
                $scope.errors['recipient'] = 'Recipient is required'

            if Object.keys($scope.errors).length > 0 then return

            data = {
                recipients: $scope.recipient_list.join(),
                comment: $scope.comment,
                deal_id: $scope.contract.id
            }
            return $modalInstance.close(true)
            Ealert.send_ealert(id: $scope.ealert.id, data: data).then(
                (res) ->
                    $modalInstance.close(true)
                (err) ->
                    for key, error of err.data.errors
                        $scope.errors[key] = error && error[0]
            )

]
