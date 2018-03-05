@app.controller "IONewCostController",
    ['$scope', '$rootScope', '$modalInstance', '$filter', 'Product', 'Cost', 'Field', 'currentIO',
        ($scope, $rootScope, $modalInstance, $filter, Product, Cost, Field, currentIO) ->
            $scope.currency_symbol = (->
                if currentIO && currentIO.currency
                    if currentIO.currency.curr_symbol
                        return currentIO.currency.curr_symbol
                    else if currentIO.currency.curr_cd
                        return currentIO.currency.curr_cd
                return '%'
            )()
            $scope.currentIO = currentIO
            $scope.cost = {
                io_id: currentIO.id,
                cost_monthly_amounts: []
                months: []
            }

            Field.defaults($scope.cost, 'Cost').then (fields) ->
                $scope.cost.type = Field.field($scope.cost, 'Type')

            for month in $scope.currentIO.months
                month = moment().year(month[0]).month(month[1] - 1).format('MMM YYYY')
                $scope.cost.cost_monthly_amounts.push({ budget_loc: '' })
                $scope.cost.months.push(month)

            Product.all({active: true}).then (products) ->
                $scope.products = products

            addProductBudgetCorrection = ->
                budgetSum = 0
                budgetPercentSum = 0
                length = $scope.cost.cost_monthly_amounts.length
                _.each $scope.cost.cost_monthly_amounts, (month, index) ->
                    if(length-1 != index)
                        budgetSum = budgetSum + month.budget_loc
                        budgetPercentSum = budgetPercentSum + month.percent_value
                    else
                        month.budget_loc = Math.round(($scope.cost.budget_loc - budgetSum) * 100) / 100
                        month.percent_value = Math.round((100 - budgetPercentSum) * 100) / 100

            cutSymbolsAddProductBudget = (cost)->
                cost = angular.copy cost
                _.each cost.cost_monthly_amounts, (month) ->
                    month.budget_loc = Number((month.budget_loc+'').replace($scope.currency_symbol, ''))
                    month.percent_value = Number((month.percent_value+'').replace('%', ''))
                cost

            $scope.cutCurrencySymbol = (value, index) ->
                value = Number((value + '').replace($scope.currency_symbol, ''))
                if(index != undefined )
                    $scope.cost.cost_monthly_amounts[index].budget_loc = value
                else
                    return value

            $scope.setCurrencySymbol = (value, index) ->
                value = $scope.currency_symbol + value
                if(index!= undefined )
                    $scope.cost.cost_monthly_amounts[index].budget_loc = value
                else
                    return value

            $scope.cutPercent = (percent_value, index) ->
                percent_value = Number((percent_value+'').replace('%', ''))
                if(index!= undefined )
                    $scope.cost.cost_monthly_amounts[index].percent_value = percent_value
                else
                    return percent_value

            $scope.setPercent = (percent_value, index) ->
                percent_value = percent_value + '%'
                if(index!= undefined)
                    $scope.cost.cost_monthly_amounts[index].percent_value = percent_value
                else
                    return percent_value

            setSymbolsAddProductBudget = ->
                _.each $scope.cost.cost_monthly_amounts, (month) ->
                    month.budget_loc = $scope.currency_symbol + month.budget_loc
                    month.percent_value =  month.percent_value + '%'


            $scope.changeTotalBudget = ->
                $scope.cost.budget_percent = 100
                $scope.cost.isIncorrectTotalBudgetPercent = false
                budgetOneDay = parseFloat($scope.cost.budget_loc) / parseFloat($scope.currentIO.days)
                if ($scope.cost.budget_loc && Math.floor($scope.cost.budget_loc * 100) / 100 != parseFloat($scope.cost.budget_loc))
                    $scope.cost.budget_loc = Math.floor($scope.cost.budget_loc * 100) / 100
                budgetSum = 0
                budgetPercentSum = 0
                _.each $scope.cost.cost_monthly_amounts, (month, index) ->
                    if(!$scope.cost.budget_loc)
                        month.percent_value = 0
                        month.budget_loc = 0
                    else
                        month.budget_loc = Math.round($scope.currentIO.days_per_month[index] * budgetOneDay * 100) / 100
                        month.percent_value = Math.round(month.budget_loc / $scope.cost.budget_loc * 10000) / 100
                    budgetSum = budgetSum + $scope.currentIO.days_per_month[index] * budgetOneDay
                    budgetPercentSum = budgetPercentSum + month.percent_value
                if($scope.cost.budget_loc && budgetSum != $scope.cost.budget_loc  || budgetPercentSum && budgetPercentSum != 100)
                    addProductBudgetCorrection()
                setSymbolsAddProductBudget()
                console.log($scope.cost);

            $scope.changeMonthValue = (monthValue, index)->
                if (monthValue && Math.floor(monthValue * 100) / 100 != parseFloat(monthValue))
                    monthValue = Math.floor(monthValue * 100) / 100
                if(!monthValue)
                    monthValue = 0
                if((monthValue+'').length > 1 && (monthValue+'').charAt(0) == '0')
                    monthValue = Number((monthValue + '').slice(1))
                $scope.cost.cost_monthly_amounts[index].budget_loc = monthValue

                $scope.cost.budget_loc = 0
                _.each $scope.cost.cost_monthly_amounts, (month, monthIndex) ->
                    if(index == monthIndex)
                        $scope.cost.budget_loc = $scope.cost.budget_loc + Number(monthValue)
                    else
                        $scope.cost.budget_loc = $scope.cost.budget_loc + $scope.cutCurrencySymbol(month.budget_loc)
                $scope.cost.budget_loc = Math.round($scope.cost.budget_loc * 100) / 100
                _.each $scope.cost.cost_monthly_amounts, (month) ->
                    month.percent_value = $scope.setPercent( Math.round($scope.cutCurrencySymbol(month.budget_loc) / $scope.cost.budget_loc * 10000) / 100)

            $scope.changeMonthPercent = (monthPercentValue, index)->
                if(!monthPercentValue)
                    monthPercentValue = 0
                if((monthPercentValue+'').length > 1 && (monthPercentValue+'').charAt(0) == '0')
                    monthPercentValue = Number((monthPercentValue + '').slice(1))
                $scope.cost.cost_monthly_amounts[index].percent_value = monthPercentValue
                $scope.cost.cost_monthly_amounts[index].budget_loc = $scope.setCurrencySymbol(Math.round(monthPercentValue/100*$scope.cost.budget_loc*100) / 100)

                $scope.cost.budget_percent = 0
                _.each $scope.cost.cost_monthly_amounts, (month) ->
                    $scope.cost.budget_percent = $scope.cutPercent($scope.cost.budget_percent) + $scope.cutPercent((month.percent_value))
                if($scope.cost.budget_percent != 100)
                    $scope.cost.isIncorrectTotalBudgetPercent = true
                else
                    $scope.cost.isIncorrectTotalBudgetPercent = false

            $scope.setBudgetPercent = (deal) ->
                if(deal && deal.costs instanceof Array)
                    _.each deal.costs, (cost) ->
                        if(cost && cost.cost_monthly_amounts instanceof Array)
                            budgetSum = 0
                            budgetPercentSum = 0
                            _.each cost.cost_monthly_amounts, (cost_product_budget, index) ->
                                cost_product_budget.budget_percent = Math.round(cost_product_budget.budget_loc/cost.budget_loc*10000) / 100
                                budgetSum = budgetSum + cost_product_budget.budget_loc
                                budgetPercentSum = budgetPercentSum + cost_product_budget.budget_percent

                            cost.total_budget_percent = 100

            $scope.resetAddProduct = ->
                $scope.changeTotalBudget()

            $scope.addCost = ->
                $scope.errors = {}
                cost = cutSymbolsAddProductBudget($scope.cost)
                Cost.create(io_id: $scope.currentIO.id, cost: cost).then(
                    (deal) ->
                        $rootScope.$broadcast 'cost_added', deal
                        $scope.cancel()
#                        $scope.currentIO = deal
#                        $scope.selectedStageId = deal.stage_id
#                        $scope.setBudgetPercent(deal)
                    (resp) ->
                        for key, error of resp.data.errors
                            $scope.errors[key] = error && error[0]
                )
            $scope.resetCost = ->
                $scope.cost = {
                    cost_monthly_amounts: []
                    months: []
                }

            $scope.cancel = ->
                $modalInstance.close()
    ]
