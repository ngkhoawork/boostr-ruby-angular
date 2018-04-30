@app.controller 'ForecastsDetailController',
    ['$scope', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast', 'Revenue', 'Deal', 'zError'
    ( $scope,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast,   Revenue,   Deal,   zError ) ->

        $scope.teams = []
        $scope.sellers = []
        $scope.timePeriods = []
        $scope.appliedFilter = {}
        $scope.isNetForecast = false
        $scope.switch =
            revenues: 'quarters'
            pmp_revenues: 'quarters'
            deals: 'quarters'
            set: (key, val) ->
                this[key] = val
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

        $scope.isNumber = (number) -> angular.isNumber number
        $scope.isYear = ->
            timePeriod = _.findWhere $scope.timePeriods, {id: $scope.appliedFilter.time_period_id}
            timePeriod && timePeriod.period_type is 'year'

        $scope.quarters = []
        $scope.forecast = {}

        ($scope.updateSellers = (team) ->
            Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
        )()

        $scope.scrollTo = (id) ->
            angular.element('html, body').animate {
                scrollTop: angular.element(id).offset().top
            }, 1000
            return

        $scope.onFilterApply = (query) ->
            $scope.appliedFilter = query
            query.id = 'all' if !query.id
            query.user_id = 'all' if !query.user_id
            getData(query)

        $scope.toggleNetForecast = (e) ->
            $scope.isNetForecast = !$scope.isNetForecast

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
            $scope.user = data.user
            $scope.hasNetPermission = data.user.company_net_forecast_enabled
            $scope.teams = data.teams
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (
                    period.period_type is 'quarter' or
                    period.period_type is 'year' or
                    period.period_type is 'month'
                )
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.forecast_gap_to_quota_positive = data.user.company_forecast_gap_to_quota_positive

        handleForecast = (data) ->
            fc = data.forecast
            fc.quarterly_weighted_forecast = {}
            fc.quarterly_weighted_forecast_net = {}
            fc.quarterly_unweighted_forecast = {}
            fc.quarterly_unweighted_forecast_net = {}
            fc.quarterly_weighted_gap_to_quota = {}
            fc.quarterly_weighted_gap_to_quota_net = {}
            fc.quarterly_unweighted_gap_to_quota = {}
            fc.quarterly_unweighted_gap_to_quota_net = {}
            fc.quarterly_percentage_of_annual_quota = {}
            fc.quarterly_percentage_of_annual_quota_net = {}
            quotaSum = _.reduce fc.quarterly_quota, (result, val) -> result + Number val
            quotaSumNet = _.reduce fc.quarterly_quota_net, (result, val) -> result + Number val
            _.each data.quarters, (quarter) ->
                weighted = Number fc.quarterly_revenue[quarter]
                weighted_net = Number fc.quarterly_revenue_net[quarter]
                unweighted = Number fc.quarterly_revenue[quarter]
                unweighted_net = Number fc.quarterly_revenue_net[quarter]
                _.each fc.stages, (stage) ->
                    weighted += Number fc.quarterly_weighted_pipeline_by_stage[stage.id][quarter]
                    weighted_net += Number fc.quarterly_weighted_pipeline_by_stage_net[stage.id][quarter]
                    unweighted += Number fc.quarterly_unweighted_pipeline_by_stage[stage.id][quarter]
                    unweighted_net += Number fc.quarterly_unweighted_pipeline_by_stage_net[stage.id][quarter]
                fc.quarterly_weighted_forecast[quarter] = weighted
                fc.quarterly_weighted_forecast_net[quarter] = weighted_net
                fc.quarterly_unweighted_forecast[quarter] = unweighted
                fc.quarterly_unweighted_forecast_net[quarter] = unweighted_net
                if $scope.forecast_gap_to_quota_positive
                    fc.quarterly_weighted_gap_to_quota[quarter] = fc.quarterly_quota[quarter] - weighted
                    fc.quarterly_weighted_gap_to_quota_net[quarter] = fc.quarterly_quota_net[quarter] - weighted_net
                    fc.quarterly_unweighted_gap_to_quota[quarter] = fc.quarterly_quota[quarter] - unweighted
                    fc.quarterly_unweighted_gap_to_quota_net[quarter] = fc.quarterly_quota_net[quarter] - unweighted_net
                else
                    fc.quarterly_weighted_gap_to_quota[quarter] = weighted - fc.quarterly_quota[quarter]
                    fc.quarterly_weighted_gap_to_quota_net[quarter] = weighted_net - fc.quarterly_quota_net[quarter]
                    fc.quarterly_unweighted_gap_to_quota[quarter] = unweighted - fc.quarterly_quota[quarter]
                    fc.quarterly_unweighted_gap_to_quota_net[quarter] = unweighted_net - fc.quarterly_quota_net[quarter]

                fc.quarterly_percentage_of_annual_quota[quarter] = if $scope.isYear() then Math.round(Number(fc.quarterly_quota[quarter]) / quotaSum * 100) else null
                fc.quarterly_percentage_of_annual_quota_net[quarter] = if $scope.isYear() then Math.round(Number(fc.quarterly_quota_net[quarter]) / quotaSumNet * 100) else null
            fc.stages.sort (s1, s2) -> s2.probability - s1.probability

        addDetailAmounts = (data, type) ->
            qs = ['Q1', 'Q2', 'Q3', 'Q4']
            ms = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
            suffix = if type == 'revenues' || type == 'pmp_revenues' then 's' else if type == 'deals' then '_amounts'
            quarters = {}
            months = {}
            monthObj = ms.reduce(((acc, cur, i) ->
              acc[i] = {month: cur, total: 0}
              acc
            ), {})
            quarterObj = qs.reduce(((acc, cur, i) ->
              acc[i] = {quarter: cur, total: 0}
              acc
            ), {})

            for q, i in qs
                for item in data
                    amount = item['quarter' + suffix][i]
                    if amount != null && amount != undefined
                        quarters[i] = q
                        break
            for m, i in ms
                for item in data
                    amount = item['month' + suffix][i]
                    if amount != null && amount != undefined
                        months[i] = m
                        break

            data.detail_amounts =
                quarters: quarters
                months: months

            calculateTotalByMonthsAndQuarter(monthObj, quarterObj, data, suffix)


        calculateTotalByMonthsAndQuarter = (monthObj, quarterObj, data, suffix) ->
          _.each data, (revenue) ->
            _.each monthObj, (month, index) ->
              monthObj[index].total += revenue['month' + suffix][index]

          _.each data.detail_amounts.months, (month, index) ->
            _.each monthObj, (monthsObj) ->
              if month == monthsObj.month
                data.detail_amounts.months[index] = monthsObj

          _.each data, (revenue) ->
            _.each quarterObj, (q, index) ->
              quarterObj[index].total += revenue['quarter' + suffix][index]

          _.each data.detail_amounts.quarters, (quarter, index) ->
            _.each quarterObj, (quartersObj) ->
              if quarter == quartersObj.quarter
                data.detail_amounts.quarters[index] = quartersObj

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

        getData = (query) ->
            if !query.time_period_id
                zError '#time-period-field', 'Select a Time Period to Run Report'
                return
            if !$scope.user then return
            $scope.forecast_gap_to_quota_positive = $scope.user.company_forecast_gap_to_quota_positive
            Forecast.forecast_detail(query).$promise.then (data) ->
                handleForecast data
                $scope.forecast = data.forecast
                $scope.quarters = data.quarters
                query.team_id = query.id
                delete query.id
                return Revenue.forecast_detail(query).$promise
            .then (data) ->
                parseRevenueBudgets data
                addDetailAmounts data, 'revenues'
                $scope.revenues = data
                return Forecast.pmp_data(query).$promise
            .then (pmp_data) ->
                parseRevenueBudgets pmp_data
                addDetailAmounts pmp_data, 'pmp_revenues'
                $scope.pmp_revenues = pmp_data
                query.type='quarterly'
                return Forecast.pipeline_data(query).$promise
            .then (deal_data) ->
                parseDealBudgets deal_data
                addDetailAmounts deal_data, 'deals'
                $scope.deals = deal_data

        tableToCSV = (el) ->
            table = angular.element(el)
            headers = table.find('tr:has(th):not(.z-fixed-header)')
            rows = table.find('tr:has(td)')
            tmpColDelim = String.fromCharCode(11)
            tmpRowDelim = String.fromCharCode(0)
            colDelim = '","'
            rowDelim = '"\u000d\n"'
            csv = '"'
            formatRows = (rows) ->
                rows.get().join(tmpRowDelim).split(tmpRowDelim).join(rowDelim).split(tmpColDelim).join colDelim
            replaceQuotes = (text) ->
                text.replace(/"/g, '""')
            grabRow = (i, row) ->
                row = angular.element(row)
                cols = row.find('td')
                if !cols.length
                    cols = row.find('th')
                cols.map(grabCol).get().join tmpColDelim
            grabCol = (j, col) ->
                col = angular.element(col)
                if col.hasClass('totalCol')
                  total = col.find('span').text().trim()
                  totalLabel = col.find('.z-sortable').text().trim()
                  col.find('.z-sortable').text(totalLabel + " / " + total)
                  col.find('span').text("")

                text = col.text().trim()
                if text.indexOf('"') >= 0
                    text = replaceQuotes(text)
                text
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