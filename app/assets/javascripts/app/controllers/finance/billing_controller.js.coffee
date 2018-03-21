@app.controller 'BillingController',
    ['$scope', '$window', '$timeout', '$routeParams', '$location', 'Billing', 'Team', 'Product', 'Field', 'Seller',
        ($scope, $window, $timeout, $routeParams, $location, Billing, Team, Product, Field, Seller) ->
            defaultUser = {id: null, name: 'All', first_name: 'All'}
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
            $scope.costs = []
            $scope.billingTabs = [
                {name: 'Revenue', value: ''}
                {name: 'Costs', value: 'costs'}
            ]
            $scope.userTypes = [
                { name: 'All', id: null }
                { name: 'Account Manager', id: 3 }
                { name: 'Manager Account Manager', id: 4 }
            ]
            $scope.currentTab = ''

            $scope.costsFilter =
                team: {id: null, name: 'All'}
                user: defaultUser
                userType: { name: 'All', id: null }

            $scope.setTab = (tab) ->
                $scope.currentTab = tab
                if (tab == 'costs' && !$scope.costs.length)
                    getData()

            $scope.selectMonth = (month) ->
                $scope.selectedMonth = month
                getData()

            $scope.selectYear = (year) ->
                $scope.selectedYear = year
                getData()

            $scope.setCostsFilter = (key, value) ->
                if $scope.costsFilter[key]is value
                    return
                $scope.costsFilter[key] = value
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
                    team_id: $scope.costsFilter.team.id
                    user_id: $scope.costsFilter.user.id
                    user_type: $scope.costsFilter.userType.id

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
                    $scope.products = products

            getTeamUsers = (team_id) ->
                Seller.query({id: team_id || 'all'}).$promise.then (users) ->
                    $scope.users = users
                    $scope.users.unshift(defaultUser)
                   
            #set last month
            init = () ->
                getTeams()
                getTeamUsers('all')
                getProducts()

                lastMonth = moment().subtract(1, 'month')
                $scope.selectMonth lastMonth.format('MMMM')
                $scope.selectYear lastMonth.format('YYYY')
                getData()

            init()

            $scope.$watch 'costsFilter.team', (nextTeam, prevTeam) ->
                if nextTeam.id then $scope.costsFilter.user = defaultUser
                $scope.setCostsFilter('team', nextTeam)
                getTeamUsers(nextTeam.id || 'all')

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

            $scope.updateCost = (item) ->
                Billing.updateCost(item).then (resp) ->
                    item.product = resp.product
                    item.amount = resp.amount
                    item.values = resp.values
                    Field.defaults(resp, 'Cost').then (fields) ->
                        item.type = Field.field(resp, 'Type')
                    console.log(resp);
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
                console.log('test')
                url = '/api/billing_summary/export_costs.csv?'
                if $scope.costsFilter.team.id
                    url += """team_id=#{$scope.costsFilter.team.id || ''}&"""
                if $scope.costsFilter.user.id
                    url += """user_id=#{$scope.costsFilter.user.id || ''}&"""
                if $scope.costsFilter.userType.id
                    url += """user_type=#{$scope.costsFilter.userType.id || ''}&"""
                $window.open(url)
                return

            exportRevenue = ->
                $window.open("""/api/billing_summary/export.csv?year=#{$scope.selectedYear}&month=#{$scope.selectedMonth}""")
                return

            $scope.exportBilling = ->
                console.log('exportBilling')
                if $scope.currentTab == 'costs'
                    exportCosts()
                else
                    exportRevenue()
    ]
