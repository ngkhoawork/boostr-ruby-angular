@app.controller 'BillingController',
    ['$scope',
        ($scope) ->
            $scope.years = [2010...2021]
            $scope.months = moment.months()
            $scope.selectedYear = ''
            $scope.selectedMonth = ''

            $scope.selectMonth = (month) ->
                $scope.selectedMonth = month

            $scope.selectYear = (year) ->
                $scope.selectedYear = year
    ]