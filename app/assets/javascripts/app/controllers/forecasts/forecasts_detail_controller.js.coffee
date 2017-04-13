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

        $q.all(
            user: CurrentUser.get().$promise
            teams: Team.all(all_teams: true)
            sellers: Seller.query({id: 'all'}).$promise
            timePeriods: TimePeriod.all()
        ).then (data) ->
            $scope.teams = data.teams
            $scope.teams.unshift {id: null, name: 'All'}
            data.timePeriods = data.timePeriods.filter (period) ->
                period.period_type is 'quarter' or period.period_type is 'year'
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
            quotaSum = _.reduce forecast.quarterly_quota, (result, val) -> result + val
            _.each data.quarters, (quarter) ->
                weighted = forecast.quarterly_revenue[quarter]
                unweighted = forecast.quarterly_revenue[quarter]
                _.each forecast.stages, (stage) ->
                    weighted += forecast.quarterly_weighted_pipeline_by_stage[stage.id][quarter]
                    unweighted += forecast.quarterly_unweighted_pipeline_by_stage[stage.id][quarter]
                forecast.quarterly_weighted_forecast[quarter] = weighted
                forecast.quarterly_unweighted_forecast[quarter] = unweighted
                forecast.quarterly_weighted_gap_to_quota[quarter] = forecast.quarterly_quota[quarter] - weighted
                forecast.quarterly_unweighted_gap_to_quota[quarter] = forecast.quarterly_quota[quarter] - unweighted
                forecast.quarterly_percentage_of_annual_quota[quarter] =
                    if $scope.filter.timePeriod.period_type is 'year'
                        Math.round(forecast.quarterly_quota[quarter] / quotaSum * 100)
                    else null
            forecast.stages.sort (stage1, stage2) -> stage2.probability - stage1.probability

        qs = ['Q1', 'Q2', 'Q3', 'Q4']
        ms = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
        addDetailAmounts = (data, type) ->
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
            Deal.forecast_detail(query).then (data) ->
                addDetailAmounts data, 'deals'
                $scope.deals = data

    ]