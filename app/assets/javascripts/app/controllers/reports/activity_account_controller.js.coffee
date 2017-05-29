@app.controller 'ActivityAccountController',
    ['$scope', 'ActivityType'
    ( $scope,   ActivityType ) ->

        $scope.activityTypes = []
        $scope.types = [
            {id: null, name: 'All'}
            {id: 1, name: 'Advertiser'}
            {id: 2, name: 'Agency'}
        ]
        $scope.accounts = []
        $scope.filter =
            type: $scope.types[0]
            date:
                startDate: null
                endDate: null
        $scope.datePicker =
            toString: ->
                date = $scope.filter.date
                if !date.startDate || !date.endDate then return false
                date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
#                apply: ->

        $scope.setFilter = (key, val) ->
            $scope.filter[key] = val

        $scope.resetFilter = ->
            $scope.filter.type = $scope.types[0]
            $scope.filter.date.startDate = null
            $scope.filter.date.endDate = null

        $scope.getTotalActivities = (type) ->
            _.reduce($scope.accounts, (total, account) ->
                total += account[type]
            , 0)


        ActivityType.all().then (activityTypes) ->
            $scope.activityTypes = activityTypes

            $scope.accounts = [1..10].map (i) ->
                account = {name: 'account name ' + i}
                account.total = 0
                for item in activityTypes
                    val = Math.round(Math.random() * 9) + 1
                    account[item.name] = val
                    account.total += val
                account

            console.log $scope.accounts

        $scope.export = ->
    ]