@app.controller 'BillingController',
    ['$scope', 'Billing',
        ($scope, Billing) ->
            $scope.years = [2016...moment().year() + 5]
            $scope.months = moment.months()
            $scope.selectedYear = ''
            $scope.selectedMonth = ''
            $scope.iosForApproval = []
            $scope.iosMissingDisplayLineItems = []
            $scope.iosMissingMonthlyActual = []
            $scope.dataIsLoading = false

            $scope.selectMonth = (month) ->
                $scope.selectedMonth = month
                getData()

            $scope.selectYear = (year) ->
                $scope.selectedYear = year
                getData()

            getData = () ->
                if $scope.selectedMonth && $scope.selectedYear
                    filter =
                        month: $scope.selectedMonth
                        year: $scope.selectedYear
                    $scope.dataIsLoading = true
                    Billing.all(filter).then (data) ->
                        iosForApproval = _.map data.ios_for_approval, (item) ->
                            if item.content_fee_product_budgets[0]
                                return item.content_fee_product_budgets[0]
                            else if item.display_line_item_budgets[0]
                                return item.display_line_item_budgets[0]
                            return null
                        $scope.iosForApproval =_.filter iosForApproval
                        $scope.iosMissingDisplayLineItems = data.ios_missing_display_line_items
                        $scope.iosMissingMonthlyActual = data.ios_missing_monthly_actual
                        $scope.dataIsLoading = false

    ]