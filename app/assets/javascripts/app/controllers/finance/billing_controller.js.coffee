@app.controller 'BillingController',
    ['$scope', '$timeout', 'Billing',
        ($scope, $timeout, Billing) ->
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
                            iosForApproval = iosForApproval.concat item.content_fee_product_budgets, item.display_line_item_budgets
                        $scope.iosForApproval = iosForApproval
                        $scope.iosMissingDisplayLineItems = data.ios_missing_display_line_items
                        $scope.iosMissingMonthlyActual = data.ios_missing_monthly_actual
                        $scope.dataIsLoading = false

            $scope.updateBillingStatus = (item, newValue) ->
                oldValue = item.billing_status
                item.billing_status = newValue
                Billing.updateStatus(item).then (resp) ->
                    item.billing_status = resp.billing_status
                , (err) ->
                    console.log err
                    item.billing_status = oldValue



            $scope.updateBudget = (item, newValue) ->
                if item.amount == newValue then return
                oldValue = item.amount
                item.amount = Number newValue
                Billing.updateBudget(item).then (resp) ->
                    item.amount = Number resp.budget
                , (err) ->
                    console.log err
                    item.amount = oldValue

            $scope.updateQuantity = (item, newValue) ->
                if item.quantity == newValue then return
                oldValue = item.amount
                item.quantity = newValue
                Billing.updateQuantity(item).then (resp) ->
                    item.quantity = resp.quantity
                    item.amount = resp.budget
                , (err) ->
                    console.log err
                    item.quantity = oldValue

            $scope.fixingDropdownPosition = (e) ->
                button = angular.element(e.currentTarget)
                menu = angular.element(e.currentTarget).find('ul.dropdown-menu')
                buttonOffset = button.offset()
                buttonOffset.top += button.outerHeight()
                $timeout () ->
                    menu.offset buttonOffset
                return
    ]