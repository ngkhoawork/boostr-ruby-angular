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
            product: emptyFilter
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

        getQuery = ->
            f = $scope.filter
            query = {}
            query.team_id = f.team.id if f.team.id
            query.product_id = f.product.id if f.product.id
            query.seller_id = f.seller.id if f.seller.id
            if f.createdDate.startDate && f.createdDate.endDate
                query.created_date_start = f.createdDate.startDate.format('YYYY-MM-DD')
                query.created_date_end = f.createdDate.endDate.format('YYYY-MM-DD')
            query

        getData = ->
            Report.product_monthly_summary(getQuery()).$promise.then (data) ->
                console.log(data.data);
                $scope.data = data.data;
                $scope.customFieldNames = data.deal_product_cf_names

        init = ->
            $q.all(
                user: CurrentUser.get().$promise
                teams: Team.all(all_teams: true)
                products: Product.all()
                sellers: Seller.query({id: 'all'}).$promise
            ).then (data) ->
                $scope.teams = data.teams
                $scope.teams.unshift emptyFilter
                $scope.sellers = data.sellers
                $scope.sellers.unshift emptyFilter
                $scope.products = data.products
                $scope.products = _.sortBy $scope.products, 'name'
                $scope.products.unshift emptyFilter

        init()
    ]