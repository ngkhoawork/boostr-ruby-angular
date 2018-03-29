@app.controller 'BillingController',
    ['$scope', '$window', '$timeout', 'Billing',
        ($scope, $window, $timeout, Billing) ->
            $scope.years = [2016...moment().year() + 5]
            $scope.months = moment.months()
            $scope.selectedYear = ''
            $scope.selectedMonth = ''
            $scope.iosForApproval = []
            $scope.iosMissingDisplayLineItems = []
            $scope.iosMissingMonthlyActual = []
            $scope.dataIsLoading = false
            $scope.billingStatuses = ['Pending', 'Approved', 'Ignore']
            $scope.iosNeedingApproval = 0
            $scope.missingLineItems = 0
            $scope.missingActuals = 0

            $scope.selectMonth = (month) ->
                $scope.selectedMonth = month
                getData()

            $scope.selectYear = (year) ->
                $scope.selectedYear = year
                getData()

            getData = () ->
                if $scope.selectedMonth && $scope.selectedYear
                    filter =
                        month: $scope.selectedMonth.toLowerCase()
                        year: $scope.selectedYear
                    $scope.dataIsLoading = true
                    Billing.all(filter).then (data) ->
                        iosForApproval = []
                        _.forEach data.ios_for_approval, (item) ->
                            iosForApproval = iosForApproval.concat item.content_fee_product_budgets, item.display_line_item_budgets
                        $scope.iosForApproval = iosForApproval
                        $scope.iosMissingDisplayLineItems = data.ios_missing_display_line_items
                        $scope.iosMissingMonthlyActual = data.ios_missing_monthly_actual &&
                            data.ios_missing_monthly_actual.sort (item1, item2) ->
                                if item1.io_number > item2.io_number then return 1
                                if item1.io_number < item2.io_number then return -1
                                if item1.line_number > item2.line_number then return 1
                                if item1.line_number < item2.line_number then return -1
                                return 0

                        $scope.dataIsLoading = false
                        updateBillingStats()

            #set last month
            lastMonth = moment().subtract(1, 'month')
            $scope.selectMonth lastMonth.format('MMMM')
            $scope.selectYear lastMonth.format('YYYY')
            getData()

            updateBillingStats = () ->
                $scope.iosNeedingApproval = _.filter($scope.iosForApproval, (item) -> item.billing_status == 'Pending').length
                $scope.missingLineItems = $scope.iosMissingDisplayLineItems.length
                $scope.missingActuals = $scope.iosMissingMonthlyActual.length


            $scope.updateBillingStatus = (item, newValue) ->
                if item.billing_status == newValue then return
                oldValue = item.billing_status
                item.billing_status = newValue
                Billing.updateStatus(item).then (resp) ->
                    item.billing_status = resp.billing_status
                    updateBillingStats()
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
                    item.budget_loc = resp.budget_loc
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

            $scope.exportBilling = ->
                $window.open("""/api/billing_summary/export.csv?year=#{$scope.selectedYear}&month=#{$scope.selectedMonth}""")
                return
    ]
