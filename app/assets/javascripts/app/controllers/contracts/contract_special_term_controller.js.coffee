@app.controller 'ContractSpecialTermController', [
    '$scope', '$modalInstance', 'Field', 'contract'
    ($scope,   $modalInstance,   Field,   contract) ->

        console.log contract

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
            fields = ['term_name_id']

            fields.forEach (key) ->
                field = $scope.form[key]
                switch key
                    when 'term_name_id'
                        if !field then return $scope.errors[key] = 'Name is required'

            return if !_.isEmpty $scope.errors
            console.log $scope.form
            # SEND DATA...
]
