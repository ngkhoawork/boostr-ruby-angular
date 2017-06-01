@app.controller 'ActivityAccountController',
    ['$scope', '$window', '$location', '$httpParamSerializer', '$routeParams', 'ActivityType', 'ActivityReport'
    ( $scope,   $window,   $location,   $httpParamSerializer,   $routeParams,   ActivityType,   ActivityReport ) ->

        $scope.activityTypes = []
        $scope.types = [
            'All'
            'Advertiser'
            'Agency'
        ]
        $scope.accounts = []
        $scope.filter =
            type: $routeParams.type || $scope.types[0]
            date: (->
                if $routeParams.start_date && $routeParams.end_date
                    {startDate: moment($routeParams.start_date), endDate: moment($routeParams.end_date)}
                else
                    {startDate: null, endDate: null}
            )()

        $scope.datePicker =
            toString: ->
                date = $scope.filter.date
                if !date.startDate || !date.endDate then return false
                date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
            apply: -> $scope.applyFilter()

        $scope.setFilter = (key, val) ->
            $scope.filter[key] = val
            $scope.applyFilter()

        $scope.applyFilter = ->
            query = getQuery()
            $location.search(query)
            getActivities(query)

        $scope.resetFilter = ->
            $scope.filter.type = $scope.types[0]
            $scope.filter.date.startDate = null
            $scope.filter.date.endDate = null
            $scope.applyFilter()

        $scope.getTotalActivities = (type) ->
            _.reduce($scope.accounts, (total, account) ->
                total += account[type] || 0
            , 0)

        getQuery = ->
            f = $scope.filter
            query = {}
            if f.type != $scope.types[0]
                query.type = f.type
            if f.date.startDate && f.date.endDate
                query.start_date = f.date.startDate.format('YYYY-MM-DD')
                query.end_date = f.date.endDate.format('YYYY-MM-DD')
            query

        getActivities = (query) ->
            ActivityReport.by_account(query).$promise.then (data) ->
                $scope.accounts = data.client_activities

        ActivityType.all().then (activityTypes) ->
            $scope.activityTypes = activityTypes
            $scope.applyFilter()

        $scope.export = ->
            url = '/api/reports/summary_by_account.csv'
            $window.open url + '?' + $httpParamSerializer getQuery()
            return

    ]