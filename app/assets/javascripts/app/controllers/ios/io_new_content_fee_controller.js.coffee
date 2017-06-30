@app.controller "IONewContentFeeController",
    ['$scope', '$rootScope', '$modalInstance', '$filter', 'Product', 'ContentFee', 'currentIO',
        ($scope, $rootScope, $modalInstance, $filter, Product, ContentFee, currentIO) ->
            $scope.currency_symbol = (->
                if currentIO && currentIO.currency
                    if currentIO.currency.curr_symbol
                        return currentIO.currency.curr_symbol
                    else if currentIO.currency.curr_cd
                        return currentIO.currency.curr_cd
                return '%'
            )()
            $scope.currentIO = currentIO
            $scope.content_fee = {
                io_id: currentIO.id,
                content_fee_product_budgets: []
                months: []
            }

            for month in $scope.currentIO.months
                month = moment().year(month[0]).month(month[1] - 1).format('MMM YYYY')
                $scope.content_fee.content_fee_product_budgets.push({ budget_loc: '' })
                $scope.content_fee.months.push(month)

            Product.all({active: true, revenue_type: 'Content-Fee'}).then (products) ->
                content_fee_products = _.map $scope.currentIO.content_fees, (content_fee_item) ->
                    return content_fee_item.product
                $scope.products = $filter('notIn')(products, content_fee_products)

            addProductBudgetCorrection = ->
                budgetSum = 0
                budgetPercentSum = 0
                length = $scope.content_fee.content_fee_product_budgets.length
                _.each $scope.content_fee.content_fee_product_budgets, (month, index) ->
                    if(length-1 != index)
                        budgetSum = budgetSum + month.budget_loc
                        budgetPercentSum = budgetPercentSum + month.percent_value
                    else
                        month.budget_loc = $scope.content_fee.budget_loc - budgetSum
                        month.percent_value = 100 - budgetPercentSum

            cutSymbolsAddProductBudget = (contentFee)->
                contentFee = angular.copy contentFee
                _.each contentFee.content_fee_product_budgets, (month) ->
                    month.budget_loc = Number((month.budget_loc+'').replace($scope.currency_symbol, ''))
                    month.percent_value = Number((month.percent_value+'').replace('%', ''))
                contentFee

            $scope.cutCurrencySymbol = (value, index) ->
                value = Number((value + '').replace($scope.currency_symbol, ''))
                if(index != undefined )
                    $scope.content_fee.content_fee_product_budgets[index].budget_loc = value
                else
                    return value

            $scope.setCurrencySymbol = (value, index) ->
                value = $scope.currency_symbol + value
                if(index!= undefined )
                    $scope.content_fee.content_fee_product_budgets[index].budget_loc = value
                else
                    return value

            $scope.cutPercent = (percent_value, index) ->
                percent_value = Number((percent_value+'').replace('%', ''))
                if(index!= undefined )
                    $scope.content_fee.content_fee_product_budgets[index].percent_value = percent_value
                else
                    return percent_value

            $scope.setPercent = (percent_value, index) ->
                percent_value = percent_value + '%'
                if(index!= undefined)
                    $scope.content_fee.content_fee_product_budgets[index].percent_value = percent_value
                else
                    return percent_value

            setSymbolsAddProductBudget = ->
                _.each $scope.content_fee.content_fee_product_budgets, (month) ->
                    month.budget_loc = $scope.currency_symbol + month.budget_loc
                    month.percent_value =  month.percent_value + '%'


            $scope.changeTotalBudget = ->
                $scope.content_fee.budget_percent = 100
                $scope.content_fee.isIncorrectTotalBudgetPercent = false
                budgetOneDay = $scope.content_fee.budget_loc / $scope.currentIO.days

                budgetSum = 0
                budgetPercentSum = 0
                _.each $scope.content_fee.content_fee_product_budgets, (month, index) ->
                    if(!$scope.content_fee.budget_loc)
                        month.percent_value = 0
                        month.budget_loc = 0
                    else
                        month.budget_loc = Math.round($scope.currentIO.days_per_month[index] * budgetOneDay)
                        month.percent_value = Math.round(month.budget_loc / $scope.content_fee.budget_loc * 100)
                    budgetSum = budgetSum + $scope.currentIO.days_per_month[index] * budgetOneDay
                    budgetPercentSum = budgetPercentSum + month.percent_value
                if($scope.content_fee.budget_loc && budgetSum != $scope.content_fee.budget_loc  || budgetPercentSum && budgetPercentSum != 100)
                    addProductBudgetCorrection()
                setSymbolsAddProductBudget()

            $scope.changeMonthValue = (monthValue, index)->
                if(!monthValue)
                    monthValue = 0
                if((monthValue+'').length > 1 && (monthValue+'').charAt(0) == '0')
                    monthValue = Number((monthValue + '').slice(1))
                $scope.content_fee.content_fee_product_budgets[index].budget_loc = monthValue

                $scope.content_fee.budget_loc = 0
                _.each $scope.content_fee.content_fee_product_budgets, (month, monthIndex) ->
                    if(index == monthIndex)
                        $scope.content_fee.budget_loc = $scope.content_fee.budget_loc + Number(monthValue)
                    else
                        $scope.content_fee.budget_loc = $scope.content_fee.budget_loc + $scope.cutCurrencySymbol(month.budget_loc)
                _.each $scope.content_fee.content_fee_product_budgets, (month) ->
                    month.percent_value = $scope.setPercent( Math.round($scope.cutCurrencySymbol(month.budget_loc) / $scope.content_fee.budget_loc * 100))

            $scope.changeMonthPercent = (monthPercentValue, index)->
                if(!monthPercentValue)
                    monthPercentValue = 0
                if((monthPercentValue+'').length > 1 && (monthPercentValue+'').charAt(0) == '0')
                    monthPercentValue = Number((monthPercentValue + '').slice(1))
                $scope.content_fee.content_fee_product_budgets[index].percent_value = monthPercentValue
                $scope.content_fee.content_fee_product_budgets[index].budget_loc = $scope.setCurrencySymbol(Math.round(monthPercentValue/100*$scope.content_fee.budget_loc))

                $scope.content_fee.budget_percent = 0
                _.each $scope.content_fee.content_fee_product_budgets, (month) ->
                    $scope.content_fee.budget_percent = $scope.cutPercent($scope.content_fee.budget_percent) + $scope.cutPercent((month.percent_value))
                if($scope.content_fee.budget_percent != 100)
                    $scope.content_fee.isIncorrectTotalBudgetPercent = true
                else
                    $scope.content_fee.isIncorrectTotalBudgetPercent = false

            $scope.setBudgetPercent = (deal) ->
                if(deal && deal.content_fees instanceof Array)
                    _.each deal.content_fees, (content_fee) ->
                        if(content_fee && content_fee.content_fee_product_budgets instanceof Array)
                            budgetSum = 0
                            budgetPercentSum = 0
                            _.each content_fee.content_fee_product_budgets, (content_fee_product_budget, index) ->
                                content_fee_product_budget.budget_percent = Math.round(content_fee_product_budget.budget_loc/content_fee.budget_loc*100)
                                budgetSum = budgetSum + content_fee_product_budget.budget_loc
                                budgetPercentSum = budgetPercentSum + content_fee_product_budget.budget_percent

                            content_fee.total_budget_percent = 100

            $scope.resetAddProduct = ->
                $scope.changeTotalBudget()

            $scope.addContentFee = ->
                $scope.errors = {}
                contentFee = cutSymbolsAddProductBudget($scope.content_fee)
                ContentFee.create(io_id: $scope.currentIO.id, content_fee: contentFee).then(
                    (deal) ->
                        $rootScope.$broadcast 'content_fee_added', deal
                        $scope.cancel()
#                        $scope.currentIO = deal
#                        $scope.selectedStageId = deal.stage_id
#                        $scope.setBudgetPercent(deal)
                    (resp) ->
                        for key, error of resp.data.errors
                            $scope.errors[key] = error && error[0]
                )
            $scope.resetContentFee = ->
                $scope.content_fee = {
                    content_fee_product_budgets: []
                    months: []
                }

            $scope.cancel = ->
                $modalInstance.close()
    ]
