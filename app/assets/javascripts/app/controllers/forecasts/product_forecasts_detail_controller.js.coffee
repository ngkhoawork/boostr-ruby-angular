@app.controller 'ProductForecastsDetailController',
    ['$scope', '$window', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast', 'Revenue', 'Deal', 'Product', 'Stage'
    ( $scope,   $window,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast,   Revenue,   Deal,   Product,   Stage) ->
        $scope.teams = []
        $scope.sellers = []
        $scope.timePeriods = []
        defaultUser = {id: 'all', name: 'All', first_name: 'All'}
        $scope.isLoading = false
        $scope.filter =
            team: {id: 'all', name: 'All'}
            seller: defaultUser
            timePeriod: {id: null, name: 'Select'}
            products: []
        $scope.selectedTeam = $scope.filter.team
        appliedFilter = null
        $scope.switch =
            revenues: 'quarters'
            deals: 'quarters'
            set: (key, val) ->
                this[key] = val
        $scope.sortRevenues =
            field: 'budget'
            reverse: false
            by: (key) ->
                if this.field == key
                    this.reverse = !this.reverse
                else
                    this.field = key
                    this.reverse = false
        $scope.sortDeals =
            field: 'budget'
            reverse: false
            by: (key) ->
                if this.field == key
                    this.reverse = !this.reverse
                else
                    this.field = key
                    this.reverse = false
        $scope.isYear = -> $scope.filter.timePeriod.period_type is 'year'
        $scope.isNumber = (number) -> angular.isNumber number


        $scope.quarters = []
        $scope.forecast = {}
        $scope.revenues = []
        $scope.deals = []

        isTeamFound = false
        $scope.$watch 'selectedTeam', (nextTeam, prevTeam) ->
            if nextTeam.id && !isTeamFound
                $scope.filter.seller = defaultUser

                $scope.setFilter('team', nextTeam)
            isTeamFound = false
            Seller.query({id: nextTeam.id || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
                $scope.sellers.unshift(defaultUser)

        $scope.setFilter = (key, value) ->
            if $scope.filter[key]is value
                return
            $scope.filter[key] = value

        $scope.removeFilter = (key, item) ->
            $scope.filter[key] = _.reject $scope.filter[key], (row) ->
                return row.id == item.id
            $scope.products.push item

        $scope.addFilter = (key, item) ->
            $scope.filter[key].push item
            $scope.products = _.reject $scope.products, (row) ->
                return row.id == item.id 

        $scope.applyFilter = () ->
            if !$scope.isLoading
                appliedFilter = angular.copy $scope.filter
                getData()

        $scope.isFilterApplied = ->
            !angular.equals $scope.filter, appliedFilter

        $scope.getAnnualSum = (data) ->
            sum = 0
            _.each $scope.quarters, (quarter) ->
                sum += Number data[quarter]
            sum

        $q.all(
            user: CurrentUser.get().$promise
            teams: Team.all(all_teams: true)
            sellers: Seller.query({id: 'all'}).$promise
            timePeriods: TimePeriod.all()
            products: Product.all()
            stages: Stage.query().$promise
        ).then (data) ->
            $scope.teams = data.teams
            $scope.teams.unshift {id: 'all', name: 'All'}
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.sellers.unshift(defaultUser)
            $scope.products = data.products
            $scope.stages = _.filter data.stages, (item) ->
                if item.probability > 0
                    return true
            switch data.user.user_type
                when 1 #seller
                    $scope.filter.seller = data.user
                    searchAndSetUserTeam data.teams, data.user.id
                    searchAndSetTimePeriod data.timePeriods
                when 2 #managet
                    searchAndSetUserTeam data.teams, data.user.id
                    searchAndSetTimePeriod data.timePeriods
                when 5 #admin
                    searchAndSetTimePeriod data.timePeriods

        searchAndSetUserTeam = (teams, user_id) ->
            for team in teams
                if team.leader_id is user_id or _.findWhere team.members, {id: user_id}
                    isTeamFound = true
                    $scope.filter.team = team
                    return $scope.selectedTeam = team
                if team.children && team.children.length
                    searchAndSetUserTeam team.children, user_id

        searchAndSetTimePeriod = (timePeriods) ->
            for period in timePeriods
                if period.period_type is 'quarter' and
                    moment().isBetween(period.start_date, period.end_date, 'days', '[]')
                        return $scope.filter.timePeriod = period
            for period in timePeriods
                if period.period_type is 'year' and
                    moment().isBetween(period.start_date, period.end_date, 'days', '[]')
                        return $scope.filter.timePeriod = period

        parseBudget = (data) ->
            data = _.map data, (item) ->
                item.budget = parseInt item.budget if item.budget
                item.budget_loc = parseInt item.budget_loc if item.budget_loc
                item
        getData = ->
            if !$scope.filter.timePeriod || !$scope.filter.timePeriod.id then return
            queryProducts = []
            if $scope.filter.products.length > 0
                queryProducts = _.map $scope.filter.products, (item) -> item.id
            else
                queryProducts = ['all']
            query =
                id: $scope.filter.team.id || 'all'
                user_id: $scope.filter.seller.id || 'all'
                time_period_id: $scope.filter.timePeriod.id
                'product_ids[]': queryProducts
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
                Revenue.forecast_detail(query).$promise.then (data) ->
                    parseBudget data
                    $scope.revenues = data

                    Deal.forecast_detail(query).then (data) ->
                        parseBudget data
                        $scope.deals = data
                        $scope.isLoading = false

        tableToCSV = (el) ->
            table = angular.element(el)
            headers = table.find('tr:has(th)')
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