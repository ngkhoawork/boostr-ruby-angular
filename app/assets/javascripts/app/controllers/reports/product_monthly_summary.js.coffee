@app.controller 'ProductMonthlySummaryController',
    ['$scope', '$window', '$q', 'Team', 'Seller', 'TimePeriod', 'CurrentUser', 'Revenue', 'Deal', 'Product', 'Report', 'DealCustomFieldName', '$httpParamSerializer'
    ( $scope,   $window,   $q,   Team,   Seller,   TimePeriod,   CurrentUser,   Revenue,   Deal,   Product,   Report,   DealCustomFieldName,   $httpParamSerializer) ->
        $scope.teams = []
        $scope.sellers = []
        $scope.data = []
        $scope.isLoading = false

        emptyFilter = $scope.emptyFilter = {id: null, name: 'All'}
        defaultFilter =
            team: emptyFilter
            seller: emptyFilter
            createdDate:
                startDate: null
                endDate: null
        $scope.filter = angular.copy defaultFilter
        $scope.selectedTeam = $scope.filter.team
        appliedFilter = null
        $scope.sort =
            field: 'product'
            reverse: false
            by: (key) ->
                if this.field == key
                    this.reverse = !this.reverse
                else
                    this.field = key
                    this.reverse = false

        $scope.datePicker =
            toString: (key) ->
                date = $scope.filter[key]
                if !date.startDate || !date.endDate then return false
                date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')


        $scope.setFilter = (key, val) ->
            $scope.filter[key] = val

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

        $scope.resetFilter = ->
            $scope.filter = angular.copy defaultFilter

        $scope.isFilterApplied = ->
            !angular.equals $scope.filter, appliedFilter

        $scope.export = ->
            url = '/api/reports/product_monthly_summary.csv'
            $window.open url + '?' + $httpParamSerializer getQuery()
            return

        searchAndSetUserTeam = (teams, user_id) ->
            for team in teams
                if team.leader_id is user_id or _.findWhere team.members, {id: user_id}
                    $scope.filter.team = team
                    return $scope.selectedTeam = team
                if team.children && team.children.length
                    searchAndSetUserTeam team.children, user_id

        parseBudget = (data) ->
            data = _.map data, (item) ->
                item.budget = parseFloat item.budget if item.budget
                item.budget_loc = parseFloat item.budget_loc if item.budget_loc
                item

        getQuery = ->
            f = $scope.filter
            query = {}
            query.team_id = f.team.id if f.team.id
            query.seller_id = f.seller.id if f.seller.id
            if f.createdDate.startDate && f.createdDate.endDate
                query.created_date_start = f.createdDate.startDate.format('YYYY-MM-DD')
                query.created_date_end = f.createdDate.endDate.format('YYYY-MM-DD')
            query

        getData = ->
            Report.product_monthly_summary(getQuery()).$promise.then (data) ->
                $scope.data = data.data;
                $scope.customFieldNames = data.deal_product_cf_names

        init = ->
            $q.all(
                user: CurrentUser.get().$promise
                teams: Team.all(all_teams: true)
                sellers: Seller.query({id: 'all'}).$promise
            ).then (data) ->
                $scope.teams = data.teams
                $scope.teams.unshift emptyFilter
                $scope.sellers = data.sellers
                $scope.sellers.unshift emptyFilter
                switch data.user.user_type
                    when 1 #seller
                        $scope.filter.seller = data.user
                        searchAndSetUserTeam data.teams, data.user.id
                    when 2 #manager
                        searchAndSetUserTeam data.teams, data.user.id

        init()
    ]