@app.controller 'ProductForecastsDetailController', [
    '$scope', '$q', 'Team', 'Seller', 'TimePeriod', 'Forecast', 'Revenue', 'Deal', 'Product', 'ProductFamily', 'Stage', 'zError'
    ($scope,   $q,   Team,   Seller,   TimePeriod,   Forecast,   Revenue,   Deal,   Product,   ProductFamily,   Stage,   zError) ->

        $scope.teams = []
        $scope.sellers = []
        $scope.productFamilies = []
        $scope.timePeriods = []
        $scope.quarters = []
        $scope.forecast = {}
        $scope.isLoading = false

        $scope.scrollTo = (id) ->
            angular.element('html, body').animate {
                scrollTop: angular.element(id).offset().top
            }, 1000
            return

        $q.all(
            teams: Team.all(all_teams: true)
            sellers: Seller.query({id: 'all'}).$promise
            timePeriods: TimePeriod.all()
            products: Product.all()
            stages: Stage.query().$promise
            productFamilies: ProductFamily.all(active: true)
        ).then (data) ->
            $scope.teams = data.teams
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.products = data.products
            $scope.productFamilies = data.productFamilies
            $scope.stages = _.filter data.stages, (item) ->
                if item.probability > 0
                    return true

        ($scope.updateSellers = (team) ->
            Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
        )()


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
            query['product_ids[]'] = ['all'] if !query['product_ids[]'] || !query['product_ids[]'].length
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
                    weighted_pipeline: 0
                }
                _.each data, (item) ->
                    if item.revenue && item.revenue > 0
                        $scope.totalForecastData.revenue += parseFloat(item.revenue)

                    if item.unweighted_pipeline && item.unweighted_pipeline > 0
                        $scope.totalForecastData.unweighted_pipeline += parseFloat(item.unweighted_pipeline)

                    if item.weighted_pipeline && item.weighted_pipeline > 0
                        $scope.totalForecastData.weighted_pipeline += parseFloat(item.weighted_pipeline)

                    _.each item.unweighted_pipeline_by_stage, (val, index) ->
                        if !$scope.totalForecastData.unweighted_pipeline_by_stage[index]
                            $scope.totalForecastData.unweighted_pipeline_by_stage[index] = 0
                        $scope.totalForecastData.unweighted_pipeline_by_stage[index] += parseFloat(val)

                    _.each item.weighted_pipeline_by_stage, (val, index) ->
                        if !$scope.totalForecastData.weighted_pipeline_by_stage[index]
                            $scope.totalForecastData.weighted_pipeline_by_stage[index] = 0
                        $scope.totalForecastData.weighted_pipeline_by_stage[index] += parseFloat(val)
                query.team_id = query.id
                delete query.id
                return Revenue.forecast_detail(query).$promise
            .then (data) ->
                parseBudget data
                $scope.revenues = data

                return Forecast.pmp_product_data(query).$promise
            .then (data) ->
                $scope.pmp_revenues = parsePmpData data
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