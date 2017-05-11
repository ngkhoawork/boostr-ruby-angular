@app.controller 'ProductForecastsDetailController',
    ['$scope', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Forecast', 'Revenue', 'Deal', 'Product'
    ( $scope,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Forecast,   Revenue,   Deal,   Product) ->
        $scope.teams = []
        $scope.sellers = []
        $scope.timePeriods = []
        defaultUser = {id: 'all', name: 'All', first_name: 'All'}
        $scope.filter =
            team: {id: null, name: 'All'}
            seller: defaultUser
            timePeriod: {id: null, name: 'Select'}
            product: {id: 'all', name: 'All'}
        $scope.selectedTeam = $scope.filter.team
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
            getData()

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
        ).then (data) ->
            $scope.teams = data.teams
            $scope.teams.unshift {id: null, name: 'All'}
            data.timePeriods = data.timePeriods.filter (period) ->
                period.visible and (period.period_type is 'quarter' or period.period_type is 'year')
            $scope.timePeriods = data.timePeriods
            $scope.sellers = data.sellers
            $scope.sellers.unshift(defaultUser)
            $scope.products = data.products
            $scope.products.unshift({id: 'all', name: 'All'})
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
            fc = data.forecast
            fc.quarterly_weighted_forecast = {}
            fc.quarterly_unweighted_forecast = {}
            fc.quarterly_weighted_gap_to_quota = {}
            fc.quarterly_unweighted_gap_to_quota = {}
            fc.quarterly_percentage_of_annual_quota = {}
            fc.stages = _.filter fc.stages, (stage) -> stage.active
            quotaSum = _.reduce fc.quarterly_quota, (result, val) -> result + Number val
            _.each data.quarters, (quarter) ->
                weighted = Number fc.quarterly_revenue[quarter]
                unweighted = Number fc.quarterly_revenue[quarter]
                _.each fc.stages, (stage) ->
                    weighted += Number fc.quarterly_weighted_pipeline_by_stage[stage.id][quarter]
                    unweighted += Number fc.quarterly_unweighted_pipeline_by_stage[stage.id][quarter]
                fc.quarterly_weighted_forecast[quarter] = weighted
                fc.quarterly_unweighted_forecast[quarter] = unweighted
                fc.quarterly_weighted_gap_to_quota[quarter] = fc.quarterly_quota[quarter] - weighted
                fc.quarterly_unweighted_gap_to_quota[quarter] = fc.quarterly_quota[quarter] - unweighted
                fc.quarterly_percentage_of_annual_quota[quarter] = if $scope.isYear() then Math.round(Number(fc.quarterly_quota[quarter]) / quotaSum * 100) else null
            fc.stages.sort (s1, s2) -> s1.probability - s2.probability

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

        parseBudget = (data) ->
            data = _.map data, (item) ->
                item.budget = parseInt item.budget if item.budget
                item.budget_loc = parseInt item.budget_loc if item.budget_loc
                item

        getData = ->
            if !$scope.filter.timePeriod || !$scope.filter.timePeriod.id then return
            query =
                id: $scope.filter.team.id || 'all'
                user_id: $scope.filter.seller.id || 'all'
                time_period_id: $scope.filter.timePeriod.id
                product_id: $scope.filter.product.id
            Forecast.forecast_detail(query).$promise.then (data) ->
                handleForecast data
                $scope.forecast = data.forecast
                $scope.quarters = data.quarters
            query.team_id = query.id
            delete query.id
            Revenue.forecast_detail(query).$promise.then (data) ->
                parseBudget data
                addDetailAmounts data, 'revenues'
                $scope.revenues = data
            Deal.forecast_detail(query).then (data) ->
                parseBudget data
                addDetailAmounts data, 'deals'
                $scope.deals = data

    ]