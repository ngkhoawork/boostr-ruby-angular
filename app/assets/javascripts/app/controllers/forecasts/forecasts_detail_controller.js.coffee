@app.controller 'ForecastsDetailController',
    ['$scope', '$window', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast', 'Revenue', 'Deal'
    ( $scope,   $window,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast,   Revenue,   Deal ) ->
        $scope.teams = []
        $scope.sellers = []
        $scope.timePeriods = []
        defaultUser = {id: 'all', name: 'All', first_name: 'All'}
        $scope.filter =
            team: {id: 'all', name: 'All'}
            seller: defaultUser
            timePeriod: {id: null, name: 'Select'}
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
        $scope.getSortableAmountKey = (type, index) ->
            switch type
                when 'revenues'
                    if $scope.switch.revenues == 'quarters'
                        return "quarters[#{index}]"
                    if $scope.switch.revenues == 'months'
                        return "months[#{index}]"
                when 'deals'
                    if $scope.switch.deals == 'quarters'
                        return "quarter_amounts[#{index}]"
                    if $scope.switch.deals == 'months'
                        return "month_amounts[#{index}]"

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

        $scope.scrollTo = (id) ->
            angular.element('html, body').animate {
                scrollTop: angular.element(id).offset().top
            }, 1000
            return

        $scope.setFilter = (key, value) ->
            if $scope.filter[key]is value
                return
            $scope.filter[key] = value
#            getData()

        $scope.applyFilter = ->
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
        ).then (data) ->
            $scope.teams = data.teams
            $scope.teams.unshift {id: 'all', name: 'All'}
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.sellers.unshift(defaultUser)
            $scope.forecast_gap_to_quota_positive = data.user.company_forecast_gap_to_quota_positive
            switch data.user.user_type
                when 1 #seller
                    $scope.filter.seller = data.user
                    searchAndSetUserTeam data.teams, data.user.id
                    searchAndSetTimePeriod data.timePeriods
                when 2 #managet
                    searchAndSetUserTeam data.teams, data.user.id
                    searchAndSetTimePeriod data.timePeriods
            if (data.user.is_admin)
                searchAndSetTimePeriod data.timePeriods
#            getData()

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

        handleForecast = (data) ->
            fc = data.forecast
            fc.quarterly_weighted_forecast = {}
            fc.quarterly_unweighted_forecast = {}
            fc.quarterly_weighted_gap_to_quota = {}
            fc.quarterly_unweighted_gap_to_quota = {}
            fc.quarterly_percentage_of_annual_quota = {}
            quotaSum = _.reduce fc.quarterly_quota, (result, val) -> result + Number val
            _.each data.quarters, (quarter) ->
                weighted = Number fc.quarterly_revenue[quarter]
                unweighted = Number fc.quarterly_revenue[quarter]
                _.each fc.stages, (stage) ->
                    weighted += Number fc.quarterly_weighted_pipeline_by_stage[stage.id][quarter]
                    unweighted += Number fc.quarterly_unweighted_pipeline_by_stage[stage.id][quarter]
                fc.quarterly_weighted_forecast[quarter] = weighted
                fc.quarterly_unweighted_forecast[quarter] = unweighted
                if $scope.forecast_gap_to_quota_positive
                    fc.quarterly_weighted_gap_to_quota[quarter] = fc.quarterly_quota[quarter] - weighted
                    fc.quarterly_unweighted_gap_to_quota[quarter] = fc.quarterly_quota[quarter] - unweighted
                else
                    fc.quarterly_weighted_gap_to_quota[quarter] = weighted - fc.quarterly_quota[quarter]
                    fc.quarterly_unweighted_gap_to_quota[quarter] = unweighted - fc.quarterly_quota[quarter]

                fc.quarterly_percentage_of_annual_quota[quarter] = if $scope.isYear() then Math.round(Number(fc.quarterly_quota[quarter]) / quotaSum * 100) else null
            fc.stages.sort (s1, s2) -> s2.probability - s1.probability

        addDetailAmounts = (data, type) ->
            qs = ['Q1', 'Q2', 'Q3', 'Q4']
            ms = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
            suffix = if type == 'revenues' then 's' else if type == 'deals' then '_amounts'
            quarters = {}
            months = {}
            for q, i in qs
                for item in data
                    if item['quarter' + suffix][i] != null
                        quarters[i] = q
                        break
            for m, i in ms
                for item in data
                    if item['month' + suffix][i] != null
                        months[i] = m
                        break
            data.detail_amounts =
                quarters: quarters
                months: months

        parseRevenueBudgets = (data) ->
            data = _.map data, (item) ->
                item.budget = parseFloat item.budget if item.budget
                item.budget_loc = parseFloat item.budget_loc if item.budget_loc
                item.in_period_split_amt = parseFloat item.in_period_split_amt if item.in_period_split_amt
                item.months = _.map item.months, (m) -> if isNaN parseFloat m then null else parseFloat m
                item.quarters = _.map item.quarters, (q) -> if isNaN parseFloat q then null else parseFloat q
                item
        parseDealBudgets = (data) ->
            data = _.map data, (item) ->
                item.budget = parseInt item.budget if item.budget
                item.budget_loc = parseInt item.budget_loc if item.budget_loc
                item.split_period_budget = parseInt item.split_period_budget if item.split_period_budget
                item.month_amounts = _.map item.month_amounts, (m) -> if isNaN parseInt m then null else parseInt m
                item.quarter_amounts = _.map item.quarter_amounts, (q) -> if isNaN parseInt q then null else parseInt q
                item

        getData = ->
            if !$scope.filter.timePeriod || !$scope.filter.timePeriod.id then return
            query =
                id: $scope.filter.team.id || 'all'
                user_id: $scope.filter.seller.id || 'all'
                time_period_id: $scope.filter.timePeriod.id
            Forecast.forecast_detail(query).$promise.then (data) ->
                handleForecast data
                $scope.forecast = data.forecast
                $scope.quarters = data.quarters
                query.team_id = query.id
                delete query.id
                Revenue.forecast_detail(query).$promise.then (data) ->
                    parseRevenueBudgets data
                    addDetailAmounts data, 'revenues'
                    $scope.revenues = data
                    Deal.forecast_detail(query).then (data) ->
                        parseDealBudgets data
                        addDetailAmounts data, 'deals'
                        $scope.deals = data

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
            a.download = 'forecast-detail-' + moment().format('YYYY-MM-DD') + '.csv'
            a.click()
            a.remove()
            return

    ]