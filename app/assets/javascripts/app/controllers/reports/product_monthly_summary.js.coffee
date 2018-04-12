@app.controller 'ProductMonthlySummaryController',
    ['$scope', '$window', '$q', 'Team', 'Seller', 'TimePeriod', 'Product', 'Report', '$httpParamSerializer', 'Company',
    ( $scope,   $window,   $q,   Team,   Seller,   TimePeriod,   Product,   Report,   $httpParamSerializer,   Company) ->

        $scope.teams = []
        $scope.sellers = []
        $scope.data = []
        $scope.isLoading = false
        $scope.allItemsLoaded = true
        $scope.shouldRenderList = false
        $scope.page = 1

        appliedFilter = null
        Company.get().$promise.then (company) -> $scope.company = company

        $scope.loadMoreData = ->
            if !$scope.allItemsLoaded then getData(appliedFilter)

        resetPagination = ->
            $scope.page = 1
            $scope.allItemsLoaded = false
            $scope.data = []

        $scope.onFilterApply = (query) ->
            resetPagination()
            query.per_page = 50
            appliedFilter = query
            getData(query)

        getData = (query) ->
            $scope.isLoading = true
            query.page = $scope.page
            Report.product_monthly_summary(query).$promise.then (data) ->
                $scope.allItemsLoaded = !data.has_more_data
                $scope.data = $scope.data.concat data.data
                $scope.page++
                $scope.customFieldNames = data.deal_product_cf_names
                $scope.isLoading = false
                $scope.shouldRenderList = true

        ($scope.updateSellers = (team) ->
            Seller.query({id: (team && team.id) || 'all'}).$promise.then (sellers) ->
                $scope.sellers = sellers
        )()

        $q.all(
            teams: Team.all(all_teams: true)
            products: Product.all({level: 0, active: true})
            sellers: Seller.query({id: 'all'}).$promise
        ).then (data) ->
            $scope.teams = data.teams
            $scope.sellers = data.sellers
            $scope.products = data.products

        $scope.export = ->
            url = '/api/reports/product_monthly_summary.csv'
            query = _.omit appliedFilter, ['page', 'per_page']
            $window.open url + '?' + $httpParamSerializer query
            return
    ]