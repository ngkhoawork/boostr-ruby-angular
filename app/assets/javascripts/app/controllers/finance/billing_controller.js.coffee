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
            $scope.billingStatuses = ['Pending', 'Approved', 'Ignore']

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
                        iosForApproval = []
                        _.forEach data.ios_for_approval, (item) ->
                            console.log item
                            iosForApproval = iosForApproval.concat item.content_fee_product_budgets, item.display_line_item_budgets
                        $scope.iosForApproval = iosForApproval
                        console.log iosForApproval
                        $scope.iosMissingDisplayLineItems = data.ios_missing_display_line_items
                        $scope.iosMissingMonthlyActual = data.ios_missing_monthly_actual
                        $scope.dataIsLoading = false

            $scope.selectedMonth = 'January'
            $scope.selectedYear = '2017'
            getData()

            $scope.updateBillingStatus = (item, status) ->
                item.billing_status = status
                Billing.updateApproval(item).then (resp) ->
                    console.log 'RESPONSE'
                , (err) ->
                    console.log err

    ]