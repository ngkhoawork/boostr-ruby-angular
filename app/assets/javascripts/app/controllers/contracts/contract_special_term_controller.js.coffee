@app.controller 'ContractSpecialTermController', [
    '$scope', '$modalInstance', 'Field', 'Contract', 'contract'
    ($scope,   $modalInstance,   Field,   Contract,   contract) ->

        $scope.form = {}
        $scope.termNames = []
        $scope.termTypes = []

        fields = {}
        Field.defaults(fields, 'Contract').then ->
            $scope.termNames = Field.field(fields, 'Special Term Name').options
            $scope.termTypes = Field.field(fields, 'Special Term Type').options

        $scope.cancel = ->
            $modalInstance.close()

        $scope.submitForm = ->
            $scope.errors = {}
            fields = ['name_id']

            fields.forEach (key) ->
                field = $scope.form[key]
                switch key
                    when 'name_id'
                        if !field then return $scope.errors[key] = 'Name is required'

            return if !_.isEmpty $scope.errors
            Contract.update
                id: contract.id
                contract:
                    special_terms_attributes: [$scope.form]
            .then (data) ->
                _.extend contract, data
                $modalInstance.close()

]
