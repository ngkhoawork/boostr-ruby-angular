@app.controller 'ForecastsDetailController',
    ['$scope', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast', 'Revenue', 'Deal'
    ( $scope,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast,   Revenue,   Deal) ->
        $scope.teams = []
        $scope.sellers = []
        $scope.timePeriods = []
        defaultUser = {id: 'all', name: 'All', first_name: 'All'}
        $scope.filter =
            team: {id: null, name: 'All'}
            seller: defaultUser
            timePeriod: {id: null, name: 'Select'}
        $scope.selectedTeam = $scope.filter.team
        $scope.switch =
            revenues: 'quarters'
            deals: 'quarters'
            set: (key, val) ->
                this[key] = val
        $scope.revenueSorting = {}
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
            getData()

        $scope.getAnnualSum = (data) ->
            sum = 0
            _.each $scope.quarters, (quarter) ->
                sum += Number data[quarter]
            sum

        $scope.sortRevenuesBy = (key) ->
            if typeof $scope.revenueSorting[key] != 'undefined'
                $scope.revenueSorting[key] = !$scope.revenueSorting[key]
            else
                $scope.revenueSorting = {}
                $scope.revenueSorting[key] = true
            $scope.revenues.sort (r1, r2) ->
                switch key
                    when 'name'
                        r1 = r1[key].toLowerCase()
                        r2 = r2[key].toLowerCase()
                    when 'budget'
                        r1 = Number r1[key]
                        r2 = Number r2[key]
                    when 'start_date', 'end_date'
                        r1 = new Date r1[key]
                        r2 = new Date r2[key]
                return if r1 > r2 then 1 else if r1 < r2 then -1 else 0
            if $scope.revenueSorting[key] == false then $scope.revenues.reverse()


        $q.all(
            user: CurrentUser.get().$promise
            teams: Team.all(all_teams: true)
            sellers: Seller.query({id: 'all'}).$promise
            timePeriods: TimePeriod.all()
        ).then (data) ->
            $scope.teams = data.teams
            $scope.teams.unshift {id: null, name: 'All'}
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.sellers.unshift(defaultUser)
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
            getData()

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
            forecast = data.forecast
            forecast.quarterly_weighted_forecast = {}
            forecast.quarterly_unweighted_forecast = {}
            forecast.quarterly_weighted_gap_to_quota = {}
            forecast.quarterly_unweighted_gap_to_quota = {}
            forecast.quarterly_percentage_of_annual_quota = {}
            quotaSum = _.reduce forecast.quarterly_quota, (result, val) -> result + Number val
            _.each data.quarters, (quarter) ->
                weighted = Number forecast.quarterly_revenue[quarter]
                unweighted = Number forecast.quarterly_revenue[quarter]
                _.each forecast.stages, (stage) ->
                    weighted += Number forecast.quarterly_weighted_pipeline_by_stage[stage.id][quarter]
                    unweighted += Number forecast.quarterly_unweighted_pipeline_by_stage[stage.id][quarter]
                forecast.quarterly_weighted_forecast[quarter] = weighted
                forecast.quarterly_unweighted_forecast[quarter] = unweighted
                forecast.quarterly_weighted_gap_to_quota[quarter] = forecast.quarterly_quota[quarter] - weighted
                forecast.quarterly_unweighted_gap_to_quota[quarter] = forecast.quarterly_quota[quarter] - unweighted
                forecast.quarterly_percentage_of_annual_quota[quarter] = if $scope.isYear() then Math.round(Number(forecast.quarterly_quota[quarter]) / quotaSum * 100) else null
            forecast.stages.sort (s1, s2) -> s1.probability - s2.probability

        addDetailAmounts = (data, type) ->
            qs = ['Q1', 'Q2', 'Q3', 'Q4']
            ms = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
            suffix = if type == 'revenues' then 's' else if type == 'deals' then '_amounts'
            quarters = []
            months = []
            for q, i in qs
                for item in data
                    if item['quarter' + suffix][i] != null
                        quarters.push q
                        break
            for m, i in ms
                for item in data
                    if item['month' + suffix][i] != null
                        months.push m
                        break
            data.detail_amounts =
                quarters: quarters
                months: months

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
                addDetailAmounts data, 'revenues'
                $scope.revenues = data
                $scope.sortRevenuesBy('budget')
            Deal.forecast_detail(query).then (data) ->
                addDetailAmounts data, 'deals'
                $scope.deals = data

    ]