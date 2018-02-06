@app.controller "DealNewProductController",
    ['$scope', '$rootScope', '$modalInstance', '$filter', 'Product', 'DealProduct', 'currentDeal', 'Company',
        ($scope, $rootScope, $modalInstance, $filter, Product, DealProduct, currentDeal, Company) ->
            $scope.currency_symbol = (->
                if currentDeal && currentDeal.currency
                    if currentDeal.currency.curr_symbol
                        return currentDeal.currency.curr_symbol
                    else if currentDeal.currency.curr_cd
                        return currentDeal.currency.curr_cd
                return '%'
            )()
            $scope.currentDeal = currentDeal
            $scope.deal_product = {
                deal_product_budgets: []
                months: []
            }

            for month in $scope.currentDeal.months
                month = moment().year(month[0]).month(month[1] - 1).format('MMM YYYY')
                $scope.deal_product.deal_product_budgets.push({ budget_loc: '' })
                $scope.deal_product.months.push(month)

            Product.all({active: true}).then (products) ->
                $scope.products = $filter('notIn')(products, $scope.currentDeal.products)

            Company.get().$promise.then (company) ->
                $scope.productOptionsEnabled = company.product_options_enabled
                $scope.option1Field = company.product_option1_field || 'Option1'
                $scope.option2Field = company.product_option2_field || 'Option2'

            $scope.productsByName = () ->
                _.uniq _.pluck($scope.products, 'name')

            $scope.rootOptions = () ->
                if $scope.deal_product.product_name
                    products = _.filter $scope.products, (p) -> p.name == $scope.deal_product.product_name && p.option1_id
                    _.uniq _.pluck(products, 'option1'), (o) -> o.name

            $scope.subOptions = () ->
                if $scope.deal_product.product_option1_id
                    products = _.filter $scope.products, (p) -> 
                      p.name == $scope.deal_product.product_name && p.option1_id == $scope.deal_product.product_option1_id && p.option2_id
                    _.uniq _.pluck(products, 'option2'), (o) -> o.name

            $scope.onChangeProductName = () ->
                $scope.deal_product.product_option1_id = null
                $scope.deal_product.product_option2_id = null
                findProductId()

            $scope.onChangeOption1 = () ->
                $scope.deal_product.product_option2_id = null
                findProductId()

            $scope.onChangeOption2 = () ->
                findProductId()

            findProductId = () ->
                product = _.find $scope.products, (p) -> 
                  p.name == $scope.deal_product.product_name && p.option1_id == $scope.deal_product.product_option1_id && p.option2_id == $scope.deal_product.product_option2_id
                if product
                  $scope.deal_product.product_id = product.id

            addProductBudgetCorrection = ->
                budgetSum = 0
                budgetPercentSum = 0
                length = $scope.deal_product.deal_product_budgets.length
                _.each $scope.deal_product.deal_product_budgets, (month, index) ->
                    if(length-1 != index)
                        budgetSum = budgetSum + month.budget_loc
                        budgetPercentSum = budgetPercentSum + month.percent_value
                    else
                        month.budget_loc = $scope.deal_product.budget_loc - budgetSum
                        month.percent_value = 100 - budgetPercentSum

            cutSymbolsAddProductBudget = (dealProduct)->
                dealProduct = angular.copy dealProduct
                _.each dealProduct.deal_product_budgets, (month) ->
                    month.budget_loc = Number((month.budget_loc+'').replace($scope.currency_symbol, ''))
                    month.percent_value = Number((month.percent_value+'').replace('%', ''))
                dealProduct

            $scope.cutCurrencySymbol = (value, index) ->
                value = Number((value + '').replace($scope.currency_symbol, ''))
                if(index != undefined )
                    $scope.deal_product.deal_product_budgets[index].budget_loc = value
                else
                    return value

            $scope.setCurrencySymbol = (value, index) ->
                value = $scope.currency_symbol + value
                if(index!= undefined )
                    $scope.deal_product.deal_product_budgets[index].budget_loc = value
                else
                    return value

            $scope.cutPercent = (percent_value, index) ->
                percent_value = Number((percent_value+'').replace('%', ''))
                if(index!= undefined )
                    $scope.deal_product.deal_product_budgets[index].percent_value = percent_value
                else
                    return percent_value

            $scope.setPercent = (percent_value, index) ->
                percent_value = percent_value + '%'
                if(index!= undefined)
                    $scope.deal_product.deal_product_budgets[index].percent_value = percent_value
                else
                    return percent_value

            setSymbolsAddProductBudget = ->
                _.each $scope.deal_product.deal_product_budgets, (month) ->
                    month.budget_loc = $scope.currency_symbol + month.budget_loc
                    month.percent_value =  month.percent_value + '%'


            $scope.changeTotalBudget = ->
                $scope.deal_product.budget_percent = 100
                $scope.deal_product.isIncorrectTotalBudgetPercent = false
                budgetOneDay = $scope.deal_product.budget_loc / $scope.currentDeal.days
                budgetSum = 0
                budgetPercentSum = 0
                _.each $scope.deal_product.deal_product_budgets, (month, index) ->
                    if(!$scope.deal_product.budget_loc)
                        month.percent_value = 0
                        month.budget_loc = 0
                    else
                        month.budget_loc = Math.round($scope.currentDeal.days_per_month[index] * budgetOneDay)
                        month.percent_value = Math.round(month.budget_loc / $scope.deal_product.budget_loc * 100)
                    budgetSum = budgetSum + $scope.currentDeal.days_per_month[index] * budgetOneDay
                    budgetPercentSum = budgetPercentSum + month.percent_value
                if($scope.deal_product.budget_loc && budgetSum != $scope.deal_product.budget_loc  || budgetPercentSum && budgetPercentSum != 100)
                    addProductBudgetCorrection()
                setSymbolsAddProductBudget()

            $scope.changeMonthValue = (monthValue, index)->
                if(!monthValue)
                    monthValue = 0
                if((monthValue+'').length > 1 && (monthValue+'').charAt(0) == '0')
                    monthValue = Number((monthValue + '').slice(1))
                $scope.deal_product.deal_product_budgets[index].budget_loc = monthValue

                $scope.deal_product.budget_loc = 0
                _.each $scope.deal_product.deal_product_budgets, (month, monthIndex) ->
                    if(index == monthIndex)
                        $scope.deal_product.budget_loc = $scope.deal_product.budget_loc + Number(monthValue)
                    else
                        $scope.deal_product.budget_loc = $scope.deal_product.budget_loc + $scope.cutCurrencySymbol(month.budget_loc)
                _.each $scope.deal_product.deal_product_budgets, (month) ->
                    month.percent_value = $scope.setPercent( Math.round($scope.cutCurrencySymbol(month.budget_loc) / $scope.deal_product.budget_loc * 100))

            $scope.changeMonthPercent = (monthPercentValue, index)->
                if(!monthPercentValue)
                    monthPercentValue = 0
                if((monthPercentValue+'').length > 1 && (monthPercentValue+'').charAt(0) == '0')
                    monthPercentValue = Number((monthPercentValue + '').slice(1))
                $scope.deal_product.deal_product_budgets[index].percent_value = monthPercentValue
                $scope.deal_product.deal_product_budgets[index].budget_loc = $scope.setCurrencySymbol(Math.round(monthPercentValue/100*$scope.deal_product.budget_loc))

                $scope.deal_product.budget_percent = 0
                _.each $scope.deal_product.deal_product_budgets, (month) ->
                    $scope.deal_product.budget_percent = $scope.cutPercent($scope.deal_product.budget_percent) + $scope.cutPercent((month.percent_value))
                if($scope.deal_product.budget_percent != 100)
                    $scope.deal_product.isIncorrectTotalBudgetPercent = true
                else
                    $scope.deal_product.isIncorrectTotalBudgetPercent = false

            $scope.setBudgetPercent = (deal) ->
                if(deal && deal.deal_products instanceof Array)
                    _.each deal.deal_products, (deal_product) ->
                        if(deal_product && deal_product.deal_product_budgets instanceof Array)
                            budgetSum = 0
                            budgetPercentSum = 0
                            _.each deal_product.deal_product_budgets, (deal_product_budget, index) ->
                                deal_product_budget.budget_percent = Math.round(deal_product_budget.budget_loc/deal_product.budget_loc*100)
                                budgetSum = budgetSum + deal_product_budget.budget_loc
                                budgetPercentSum = budgetPercentSum + deal_product_budget.budget_percent

                            deal_product.total_budget_percent = 100

            $scope.resetAddProduct = ->
                $scope.changeTotalBudget()

            $scope.addProduct = ->
                $scope.errors = {}
                dealProduct = cutSymbolsAddProductBudget($scope.deal_product)
                DealProduct.create(deal_id: $scope.currentDeal.id, deal_product: dealProduct).then(
                    (deal) ->
                        $rootScope.$broadcast 'deal_product_added', deal
                        $scope.cancel()
#                        $scope.currentDeal = deal
#                        $scope.selectedStageId = deal.stage_id
#                        $scope.setBudgetPercent(deal)
                    (resp) ->
                        for key, error of resp.data.errors
                            $scope.errors[key] = error && error[0]
                )
            $scope.resetDealProduct = ->
                $scope.deal_product = {
                    deal_product_budgets: []
                    months: []
                }

            $scope.cancel = ->
                $modalInstance.close()
    ]
