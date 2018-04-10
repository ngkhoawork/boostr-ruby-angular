@app.controller 'BillingController',
    ['$scope', '$window', '$timeout', '$routeParams', '$location', 'Billing', 'Team', 'Product', 'ProductFamily', 'Field', 'Seller',
        ($scope, $window, $timeout, $routeParams, $location, Billing, Team, Product, ProductFamily, Field, Seller) ->
            defaultUser = {id: null, name: 'All', first_name: 'All'}
            $scope.years = [2016...moment().year() + 5]
            $scope.months = moment.months()
            $scope.selectedYear = ''
            $scope.selectedMonth = ''
            $scope.iosForApproval = []
            $scope.iosMissingDisplayLineItems = []
            $scope.iosMissingMonthlyActual = []
            $scope.dataIsLoading = false
            $scope.statuses = ['Pending', 'Approved', 'Ignore']
            $scope.iosNeedingApproval = 0
            $scope.missingLineItems = 0
            $scope.missingActuals = 0
            $scope.costs = []
            $scope.productFamilies = []
            $scope.products = []
            $scope.billingTabs = [
                {name: 'Revenue', value: ''}
                {name: 'Costs', value: 'costs'}
            ]
            $scope.currentTab = ''

            emptyFilter = {id: null, name: 'All'}

            $scope.filter =
                team: emptyFilter
                user: defaultUser
                manager: defaultUser
                productFamily: emptyFilter
                product: emptyFilter

            $scope.shouldUpdate = true

            $scope.setTab = (tab) ->
                $scope.currentTab = tab
                if $scope.shouldUpdate
                    getData()
                    $scope.shouldUpdate = false

            $scope.selectMonth = (month) ->
                $scope.selectedMonth = month
                $scope.shouldUpdate = true
                getData()

            $scope.selectYear = (year) ->
                $scope.selectedYear = year
                $scope.shouldUpdate = true
                getData()

            $scope.setFilter = (key, value) ->
                if $scope.filter[key]is value
                    return
                $scope.filter[key] = value
                getData()

            getData = () ->
                if $scope.currentTab == 'costs'
                    getCostsData()
                else
                    getRevenueData()

            getRevenueData = () ->
                if $scope.selectedMonth && $scope.selectedYear
                    filter =
                        month: $scope.selectedMonth.toLowerCase()
                        year: $scope.selectedYear
                        product_id: $scope.filter.product.id
                        product_family_id: $scope.filter.productFamily.id

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

            getCostsData = () ->
                filters = 
                    team_id: $scope.filter.team.id
                    user_id: $scope.filter.user.id
                    manager_id: $scope.filter.manager.id
                    product_id: $scope.filter.product.id
                    product_family_id: $scope.filter.productFamily.id
                    month: $scope.selectedMonth.toLowerCase()
                    year: $scope.selectedYear

                Billing.getCosts(filters).then (data) ->
                    $scope.costs = data;
                    Field.all(subject: 'Cost').then (fields) ->
                        Field.set('Cost', fields)
                        $scope.costs = _.map $scope.costs, (cost) ->
                            Field.defaults(cost, 'Cost').then (fields) ->
                                cost.type = Field.field(cost, 'Type')
                            return cost

            getTeams = () ->
                Team.all(all_teams: true).then (teams) ->
                    $scope.teams = teams
                    $scope.teams.unshift {id: null, name: 'All'}

            getProducts = () ->
                Product.all({active: true}).then (products) ->
                    $scope.allProducts = products
                    $scope.products = products
                    $scope.products.unshift emptyFilter

            getProductFamilies = () ->
                ProductFamily.all(active: true).then (productFamilies) ->
                    $scope.productFamilies = productFamilies
                    $scope.productFamilies.unshift emptyFilter

            getTeamUsers = (team_id) ->
                Seller.query({ id: team_id || 'all' }).$promise.then (users) ->
                    $scope.users = users
                    $scope.users.unshift(defaultUser)
                Team.all_account_managers({ team_id: team_id || 'all' }).then (managers) ->
                    $scope.managers = managers
                    $scope.managers.unshift(defaultUser)
                   
            #set last month
            init = () ->
                getTeams()
                getTeamUsers('all')
                getProducts()
                getProductFamilies()

                lastMonth = moment().subtract(1, 'month')
                $scope.selectMonth lastMonth.format('MMMM')
                $scope.selectYear lastMonth.format('YYYY')
                getData()

            init()

            $scope.$watch 'filter.team', (nextTeam, prevTeam) ->
                if nextTeam.id then $scope.filter.user = defaultUser
                $scope.setFilter('team', nextTeam)
                getTeamUsers(nextTeam.id || 'all')
                getData()

            $scope.$watch 'filter.productFamily', (productFamily, prevProductFamily) ->
                if productFamily == prevProductFamily then return
                if productFamily.id then $scope.setFilter('product', emptyFilter)
                $scope.setFilter('productFamily', productFamily)
                Product.all(product_family_id: productFamily.id).then (products) ->
                    $scope.products = products
                    $scope.products.unshift emptyFilter

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

            $scope.updateCostBudget = (item) ->
                Billing.updateCostBudget(item).then (resp) ->
                    item.amount = resp.amount
                , (err) ->
                    console.log err
                    item.amount = oldValue

            $scope.updateCost = (item) ->
                cost = {
                    id: item.cost_id,
                    product_id: item.product_id,
                    values: item.values,
                    type: item.type
                }
                Billing.updateCost(cost).then (resp) ->
                    item.product = resp.product
                    item.values = resp.values
                    Field.defaults(resp, 'Cost').then (fields) ->
                        item.type = Field.field(resp, 'Type')
                , (err) ->
                    console.log err
                    item.amount = oldValue

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

            $scope.fixingDropdownPosition = (e, direction = '') ->
                button = angular.element(e.currentTarget)
                menu = angular.element(e.currentTarget).find('ul.dropdown-menu')
                buttonOffset = button.offset()
                if direction == 'right'
                    buttonOffset.left += button.outerWidth() - menu.outerWidth()
                buttonOffset.top += button.outerHeight()
                $timeout () ->
                    menu.offset buttonOffset
                return

            exportCosts = ->
                url = '/api/billing_summary/export_cost_budgets.csv?'
                if $scope.filter.team.id
                    url += """team_id=#{$scope.filter.team.id || ''}&"""
                if $scope.filter.user.id
                    url += """user_id=#{$scope.filter.user.id || ''}&"""
                if $scope.filter.manager.id
                    url += """manager_id=#{$scope.filter.manager.id || ''}&"""
                if $scope.filter.product.id
                    url += """product_id=#{$scope.filter.product.id || ''}&"""
                if $scope.filter.productFamily.id
                    url += """product_family_id=#{$scope.filter.productFamily.id || ''}&"""

                if $scope.selectedYear
                    url += """year=#{$scope.selectedYear}&"""
                if $scope.selectedMonth
                    url += """month=#{$scope.selectedMonth}&"""
                $window.open(url)
                return

            exportRevenue = ->
                url = '/api/billing_summary/export.csv?'
                if $scope.selectedYear
                    url += """year=#{$scope.selectedYear}&"""
                if $scope.selectedMonth
                    url += """month=#{$scope.selectedMonth}&"""
                if $scope.filter.product.id
                    url += """product_id=#{$scope.filter.product.id || ''}&"""
                if $scope.filter.productFamily.id
                    url += """product_family_id=#{$scope.filter.productFamily.id || ''}&"""
                $window.open(url)
                return

            $scope.exportBilling = ->
                if $scope.currentTab == 'costs'
                    exportCosts()
                else
                    exportRevenue()
    ]
