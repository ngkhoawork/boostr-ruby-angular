@app.controller 'ProductForecastsDetailController', [
    '$scope', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast', 'Revenue', 'Deal', 'Product', 'ProductFamily', 'Stage', 'zError'
    ($scope,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast,   Revenue,   Deal,   Product,   ProductFamily,   Stage,   zError) ->

        $scope.teams = []
        $scope.sellers = []
        $scope.productFamilies = []
        $scope.timePeriods = []
        $scope.quarters = []
        $scope.forecast = {}
        $scope.isLoading = false
        $scope.isNetForecast = false
        $scope.filter = {}
        $scope.productsLevel1 = []

        $scope.scrollTo = (id) ->
            angular.element('html, body').animate {
                scrollTop: angular.element(id).offset().top
            }, 1000
            return

        $q.all(
            teams: Team.all(all_teams: true)
            user: CurrentUser.get().$promise
            sellers: Seller.query({id: 'all'}).$promise
            timePeriods: TimePeriod.all()
            products: Product.all({active: true})
            stages: Stage.query().$promise
            productFamilies: ProductFamily.all(active: true)
        ).then (data) ->
            setPermission(data.user)
            $scope.teams = data.teams
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (
                    period.period_type is 'quarter' or
                    period.period_type is 'year' or
                    period.period_type is 'month'
                )
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.products = data.products
            $scope.productsLevel0 = productsByLevel(0)
            $scope.productFamilies = data.productFamilies
            $scope.stages = _.filter data.stages, (item) ->
                if item.probability > 0
                    return true

        setPermission = (user) ->
            $scope.hasNetPermission = user.company_net_forecast_enabled
            $scope.productOptionsEnabled = user.product_options_enabled
            $scope.productOption1Enabled = user.product_options_enabled && user.product_option1_enabled
            $scope.productOption2Enabled = user.product_options_enabled && user.product_option2_enabled
            $scope.productOption1 = user.product_option1 || 'Option 1'
            $scope.productOption2 = user.product_option2 || 'Option 2'

        $scope.onProductChange = (product) ->
            $scope.filter.product = product
            $scope.productsLevel1 = productsByLevel(1)

        $scope.onProduct1Change = (product) ->
            $scope.filter.product1 = product
            $scope.productsLevel2 = productsByLevel(2)

        productsByLevel = (level) ->
            _.filter $scope.products, (p) -> 
                if level == 0
                    p.level == level
                else if level == 1
                    p.level == 1 && $scope.filter.product && p.parent_id == $scope.filter.product.id
                else if level == 2
                    p.level == 2 && $scope.filter.product1 && p.parent_id == $scope.filter.product1.id

        ($scope.updateSellers = (team) ->
            Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
        )()

        $scope.toggleNetForecast = (e) ->
            $scope.isNetForecast = !$scope.isNetForecast

        parseBudget = (data) ->
            data = _.map data, (item) ->
                item.budget = parseFloat item.budget if item.budget
                item.budget_loc = parseFloat item.budget_loc if item.budget_loc
                item
        parsePmpData = (data) ->
            new_data = []
            _.each data, (pmp) ->
                _.each pmp.products, (product_item) ->
                    new_pmp = angular.copy(pmp)
                    new_pmp.$$hashKey = new_pmp.$$hashKey + product_item.product_id
                    new_pmp.product_id = product_item.product_id
                    new_pmp.product = product_item.product
                    new_pmp.budget = parseFloat new_pmp.budget if new_pmp.budget
                    new_pmp.budget_loc = parseFloat new_pmp.budget_loc if new_pmp.budget_loc
                    new_pmp.in_period_amt = product_item.in_period_amt
                    new_pmp.in_period_split_amt = product_item.in_period_split_amt
                    new_data.push(new_pmp)
            return new_data

        $scope.onFilterApply = (query) ->
            query.id = query.id || 'all'
            query.user_id = query.user_id || 'all'
            query.product_id = query.product_id
            query.product1_id = query.product1_id
            query.product2_id = query.product2_id
            query.product_family_id = query.product_family_id || 'all'
            getData(query)

        getData = (query) ->
            if !query.time_period_id
                zError '#time-period-field', 'Select a Time Period to Run Report'
                return
            $scope.isLoading = true
            Forecast.product_forecast_detail(query).$promise.then (data) ->
                $scope.forecastData = data
                $scope.totalForecastData = {
                    revenue: 0,
                    unweighted_pipeline_by_stage: {}, 
                    unweighted_pipeline: 0,
                    weighted_pipeline_by_stage: {}, 
                    weighted_pipeline: 0,
                    revenue_net: 0,
                    unweighted_pipeline_by_stage_net: {}, 
                    unweighted_pipeline_net: 0,
                    weighted_pipeline_by_stage_net: {}, 
                    weighted_pipeline_net: 0
                }
                _.each data, (item) ->
                    if item.revenue && item.revenue > 0
                        $scope.totalForecastData.revenue += parseFloat(item.revenue)

                    if item.revenue_net && item.revenue_net > 0
                        $scope.totalForecastData.revenue_net += parseFloat(item.revenue_net)

                    if item.unweighted_pipeline && item.unweighted_pipeline > 0
                        $scope.totalForecastData.unweighted_pipeline += parseFloat(item.unweighted_pipeline)

                    if item.unweighted_pipeline_net && item.unweighted_pipeline_net > 0
                        $scope.totalForecastData.unweighted_pipeline_net += parseFloat(item.unweighted_pipeline_net)

                    if item.weighted_pipeline && item.weighted_pipeline > 0
                        $scope.totalForecastData.weighted_pipeline += parseFloat(item.weighted_pipeline)

                    if item.weighted_pipeline_net && item.weighted_pipeline_net > 0
                        $scope.totalForecastData.weighted_pipeline_net += parseFloat(item.weighted_pipeline_net)

                    _.each item.unweighted_pipeline_by_stage, (val, index) ->
                        if !$scope.totalForecastData.unweighted_pipeline_by_stage[index]
                            $scope.totalForecastData.unweighted_pipeline_by_stage[index] = 0
                        $scope.totalForecastData.unweighted_pipeline_by_stage[index] += parseFloat(val)

                    _.each item.unweighted_pipeline_by_stage_net, (val, index) ->
                        if !$scope.totalForecastData.unweighted_pipeline_by_stage_net[index]
                            $scope.totalForecastData.unweighted_pipeline_by_stage_net[index] = 0
                        $scope.totalForecastData.unweighted_pipeline_by_stage_net[index] += parseFloat(val)

                    _.each item.weighted_pipeline_by_stage, (val, index) ->
                        if !$scope.totalForecastData.weighted_pipeline_by_stage[index]
                            $scope.totalForecastData.weighted_pipeline_by_stage[index] = 0
                        $scope.totalForecastData.weighted_pipeline_by_stage[index] += parseFloat(val)

                    _.each item.weighted_pipeline_by_stage_net, (val, index) ->
                        if !$scope.totalForecastData.weighted_pipeline_by_stage_net[index]
                            $scope.totalForecastData.weighted_pipeline_by_stage_net[index] = 0
                        $scope.totalForecastData.weighted_pipeline_by_stage_net[index] += parseFloat(val)
                query.team_id = query.id
                delete query.id
                query.is_product = true
                return Revenue.forecast_detail(query).$promise
            .then (data) ->
                parseBudget data
                $scope.revenues = data

                return Forecast.pmp_product_data(query).$promise
            .then (data) ->
                $scope.pmp_revenues = parsePmpData data
                query.is_product = true
                return Deal.forecast_detail(query)
            .then (data) ->
                parseBudget data
                $scope.deals = data
                $scope.isLoading = false

        tableToCSV = (el) ->
            table = angular.element(el)
            headers = table.find('tr:has(th):not(.z-fixed-header):not(.csv-ignore)')
            rows = table.find('tr:has(td)')
            tmpColDelim = String.fromCharCode(11)
            tmpRowDelim = String.fromCharCode(0)
            colDelim = '","'
            rowDelim = '"\u000d\n"'
            csv = '"'
            formatRows = (rows) ->
                rows.get().join(tmpRowDelim).split(tmpRowDelim).join(rowDelim).split(tmpColDelim).join colDelim
            grabRow = (i, row) ->
                row = angular.element(row)
                cols = row.find('td')
                if !cols.length
                    cols = row.find('th')
                cols.map(grabCol).get().join tmpColDelim
            grabCol = (j, col) ->
                col = angular.element(col)
                text = col.text().trim()
                text.replace '"', '""'
            csv += formatRows(headers.map(grabRow))
            csv += rowDelim
            csv += formatRows(rows.map(grabRow)) + '"'

        $scope.export = ->
            tables = angular.element('.exportable-table')
            csv = _.map(tables, (table) -> tableToCSV(table)).join('\u000d\n\u000d\n')
            a = document.createElement 'a'
            a.href = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv)
            a.download = 'product-forecast-' + moment().format('YYYY-MM-DD') + '.csv'
            a.click()
            a.remove()
            return
]