@app.controller "DealNewProductController",
    ['$scope', '$rootScope', '$modalInstance', '$modal', '$filter', 'Product', 'DealProduct', 'currentDeal', 'isPmpDeal', 'company',
     ($scope,   $rootScope,   $modalInstance,   $modal,   $filter,   Product,   DealProduct,   currentDeal,   isPmpDeal,   company) ->
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
            $scope.products = []
            $scope.productOptionsEnabled = company.product_options_enabled
            $scope.productOption1Enabled = company.product_option1_enabled
            $scope.productOption2Enabled = company.product_option2_enabled
            $scope.option1Field = company.product_option1_field || 'Option1'
            $scope.option2Field = company.product_option2_field || 'Option2'

            for month in $scope.currentDeal.months
                month = moment().year(month[0]).month(month[1] - 1).format('MMM YYYY')
                $scope.deal_product.deal_product_budgets.push({ budget_loc: '' })
                $scope.deal_product.months.push(month)

            Product.all({active: true}).then (products) ->
                $scope.products = products

            $scope.productsByLevel = (level) ->
                _.filter $scope.products, (p) -> 
                  if level == 0
                    p.level == level
                  else if level == 1
                    p.level == 1 && p.parent_id == $scope.deal_product.product0
                  else if level == 2
                    p.level == 2 && p.parent_id == $scope.deal_product.product1

            $scope.onChangeProduct = (item, model) ->
                if item
                  $scope.deal_product.product_id = item.id
                  if item.level == 0
                    $scope.deal_product.product1 = null
                    $scope.deal_product.product2 = null
                  else if item.level == 1
                    $scope.deal_product.product2 = null
                else
                  if !$scope.deal_product.product1
                    $scope.deal_product.product_id = $scope.deal_product.product0
                    $scope.deal_product.product2 = null
                  else if !$scope.deal_product.product2
                    $scope.deal_product.product_id = $scope.deal_product.product1

            $scope.hasSubProduct = (level) ->
                if $scope.productOptionsEnabled && subProduct = _.find($scope.products, (p) -> 
                    (!level || p.level == level) && p.parent_id == $scope.deal_product.product_id)
                    return subProduct

            $scope.selectedProduct = () ->
                _.find $scope.products, (p) -> p.id == $scope.deal_product.product_id

            addProductBudgetCorrection = ->
                budgetSum = 0
                budgetPercentSum = 0
                length = $scope.deal_product.deal_product_budgets.length
                _.each $scope.deal_product.deal_product_budgets, (month, index) ->
                    month.budget_loc = $scope.cutCurrencySymbol(month.budget_loc)
                    month.percent_value = $scope.cutPercent(month.percent_value)
                    if(length-1 != index)
                        budgetSum = budgetSum + month.budget_loc
                        budgetPercentSum = Number( (budgetPercentSum + month.percent_value).toFixed(1) )
                    else
                        month.budget_loc = $scope.deal_product.budget_loc - budgetSum
                        month.percent_value = Number( ( 100 - budgetPercentSum ).toFixed(1) )

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

            showWarningModal = (message) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_warning.html'
                    size: 'md'
                    controller: 'DealWarningController'
                    backdrop: 'static'
                    keyboard: true
                    resolve:
                        message: -> message
                        id: ->

            $scope.setCurrencySymbol = (value, index) ->
                if String(value).indexOf($scope.currency_symbol) < 0
                    value = $scope.currency_symbol + value
                else
                    return value

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
                percent_value = 0 if !percent_value

                if String(percent_value).indexOf('%') < 0
                    percent_value = percent_value + '%'
                else
                    return percent_value
                    
                if(index!= undefined)
                    $scope.deal_product.deal_product_budgets[index].percent_value = percent_value
                else
                    return percent_value

            setSymbolsAddProductBudget = ->
                _.each $scope.deal_product.deal_product_budgets, (month) ->
                    month.budget_loc = $scope.currency_symbol + month.budget_loc
                    month.percent_value =  month.percent_value + '%'


            $scope.changeTotalBudget = ->
                $scope.deal_product.budget_loc = Number($scope.deal_product.budget_loc) || 0
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
                        month.percent_value = Number( (month.budget_loc / $scope.deal_product.budget_loc * 100).toFixed(1) )
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
                    month.percent_value = $scope.setPercent( Number( ( $scope.cutCurrencySymbol(month.budget_loc) / $scope.deal_product.budget_loc * 100 ).toFixed(1) ) )
                addProductBudgetCorrection()
                _.each $scope.deal_product.deal_product_budgets, (month) ->
                    month.budget_loc = $scope.setCurrencySymbol(month.budget_loc)
                    month.percent_value = $scope.setPercent(month.percent_value)

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

                if !$scope.deal_product.product_id
                    $scope.errors['product_id'] = 'Product is required'
                else if subProduct = $scope.hasSubProduct()
                    $scope.errors['product' + subProduct.level] = $scope['option' + subProduct.level + 'Field'] + ' is required'

                if !_.isEmpty($scope.errors) || $scope.deal_product.isIncorrectTotalBudgetPercent then return

                dealProduct = cutSymbolsAddProductBudget($scope.deal_product)
                if isPmpDeal && $scope.selectedProduct().revenue_type != 'PMP'
                    message = 'This deal has only PMP products. You can\'t add non PMP product.'
                    showWarningModal(message)
                else if !isPmpDeal && currentDeal.deal_products.length > 0 && $scope.selectedProduct().revenue_type == 'PMP'
                    message = 'This deal has only non PMP products. You can\'t add PMP product.'
                    showWarningModal(message)
                else
                    $scope.disableSubmitButton = true
                    DealProduct.create(deal_id: $scope.currentDeal.id, deal_product: dealProduct).then(
                        (deal) ->
                            $rootScope.$broadcast 'deal_product_added', deal
                            $scope.cancel()
                        (resp) ->
                            for key, error of resp.data.errors
                                $scope.errors[key] = error && error[0]
                            $scope.disableSubmitButton = false    
                    )

            $scope.resetDealProduct = ->
                $scope.deal_product = {
                    deal_product_budgets: []
                    months: []
                }

            $scope.cancel = ->
                $modalInstance.close()

            $scope.isUndefined = angular.isUndefined
    ]
