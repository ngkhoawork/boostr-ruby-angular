@app.controller "IONewCostController",
    ['$scope', '$rootScope', '$modalInstance', '$filter', 'Product', 'Cost', 'Field', 'currentIO', 'company',
        ($scope, $rootScope, $modalInstance, $filter, Product, Cost, Field, currentIO, company) ->
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
            $scope.productOptionsEnabled = company.product_options_enabled
            $scope.productOption1Enabled = company.product_option1_enabled
            $scope.productOption2Enabled = company.product_option2_enabled
            $scope.option1Field = company.product_option1_field || 'Option1'
            $scope.option2Field = company.product_option2_field || 'Option2'

            Field.defaults($scope.cost, 'Cost').then (fields) ->
                $scope.cost.type = Field.field($scope.cost, 'Cost Type')

            for month in $scope.currentIO.months
                month = moment().year(month[0]).month(month[1] - 1).format('MMM YYYY')
                $scope.cost.cost_monthly_amounts.push({ budget_loc: '' })
                $scope.cost.months.push(month)

            Product.all({active: true, revenue_type: 'Content-Fee'}).then (products) ->
                $scope.products = products

            $scope.productsByLevel = (level) ->
                _.filter $scope.products, (p) -> 
                  if level == 0
                    p.level == level
                  else if level == 1
                    p.level == 1 && p.parent_id == $scope.cost.product0
                  else if level == 2
                    p.level == 2 && p.parent_id == $scope.cost.product1

            $scope.onChangeProduct = (item, model) ->
                if item
                  $scope.cost.product_id = item.id
                  if item.level == 0
                    $scope.cost.product1 = null
                    $scope.cost.product2 = null
                  else if item.level == 1
                    $scope.cost.product2 = null
                else
                  if !$scope.cost.product1
                    $scope.cost.product_id = $scope.cost.product0
                    $scope.cost.product2 = null
                  else if !$scope.cost.product2
                    $scope.cost.product_id = $scope.cost.product1

            $scope.hasSubProduct = (level) ->
                if $scope.productOptionsEnabled && subProduct = _.find($scope.products, (p) -> 
                    (!level || p.level == level) && p.parent_id == $scope.cost.product_id)
                    return subProduct

            $scope.selectedProduct = () ->
                _.find $scope.products, (p) -> p.id == $scope.cost.product_id

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

                if !$scope.cost.product_id
                    $scope.errors['product_id'] = 'Product is required'
                else if subProduct = $scope.hasSubProduct()
                    $scope.errors['product' + subProduct.level] = $scope['option' + subProduct.level + 'Field'] + ' is required'

                if !_.isEmpty($scope.errors) || $scope.cost.isIncorrectTotalBudgetPercent then return

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
