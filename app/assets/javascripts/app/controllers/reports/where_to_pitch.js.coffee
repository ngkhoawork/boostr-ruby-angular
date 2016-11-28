@app.controller 'WhereToPitchController',
    ['$scope', '$document', 'WhereToPitchService', 'Team', 'Product', 'Field', 'Seller'
        ($scope, $document, WTP, Team, Product, Field, Seller) ->

            $scope.filter = {}
            $scope.selectedTeam =
                id: 'all'
                name:'Team'
            $scope.datePicker =
                date:
                    startDate: null
                    endDate: null
                element: $document.find('#advertiser-date-picker')
                isDateSet: false
                apply: ->
                    _this = $scope.datePicker
                    if (_this.date.startDate && _this.date.endDate)
                        _this.element.html(_this.date.startDate.format('MMMM D, YYYY') + ' - ' + _this.date.endDate.format('MMMM D, YYYY'))
                        _this.isDateSet = true
                        $scope.setFilter('time period', _this.date)
                cancel: ->
                    _this = $scope.datePicker
                    _this.element.html('Time period')
                    _this.isDateSet = false
                    $scope.setFilter('time period', _this.date)

            $scope.setFilter = (type, item) ->
                if !item then return
                switch type
                    when 'time period'
                        if $scope.datePicker.isDateSet
                            $scope.filter.start_date = item.startDate.format('DD-MM-YYYY')
                            $scope.filter.end_date = item.endDate.format('DD-MM-YYYY')
                        else
                            $scope.filter.start_date = null
                            $scope.filter.end_date = null
                    when 'team' then $scope.filter.team = item.id
                    when 'seller' then $scope.filter.seller = item.id
                    when 'product' then $scope.filter.product_id = item.id
                    when 'category'
                        $scope.filter.category_id = item.id
                        $scope.filter.subcategory_id = undefined
                        if item.suboptions
                            $scope.subcategories = angular.copy item.suboptions
                            $scope.subcategories.unshift({name: 'All', id: null})
                        else
                            $scope.subcategories = $scope.allSubcategories
                    when 'subcategory' then $scope.filter.subcategory_id = item.id

                applyFilter()

            $scope.resetFilter = ->
                $scope.filter = {}
                $scope.datePicker.element.html('Time period')
                $scope.datePicker.isDateSet = false
                $scope.selectedTeam = {id: 'all', name:'Team'}
                $scope.subcategories = $scope.allSubcategories
                applyFilter()

            $scope.$watch 'selectedTeam', (nextTeam, prevTeam) ->
                if nextTeam.name == 'Team' && nextTeam.id == 'all' then return
                $scope.filter.seller = null
                Seller.query({id: nextTeam.id || 'all'}).$promise.then (sellers) ->
                    sellers.unshift({first_name: 'All', id: null})
                    $scope.sellers = sellers
                $scope.setFilter('team', nextTeam)

            #initial query
            WTP.get().$promise.then ((data) ->
                updateTable('advertisers', data.advertisers)
                updateTable('agencies', data.agencies)

                Product.all().then (products) ->
                    $scope.productsList = products
                    $scope.productsList.unshift({name: 'All', id: null})

                Seller.query({id: 'all'}).$promise.then (sellers) ->
                    $scope.sellers = sellers
                    $scope.sellers.unshift({first_name: 'All', id: null})

                Team.all(all_teams: true).then (teams) ->
                    $scope.teams = teams
                    $scope.teams.unshift({id: null, name: 'All'})

                Field.defaults({}, 'Client').then (clients) ->
                    categories = [{name: 'All', id: null}]
                    subcategories = [{name: 'All', id: null}]
                    for client in clients
                        if client.name is 'Category'
                            for category in client.options
                                categories.push category
                                for subcategory in category.suboptions
                                    subcategories.push subcategory

                    $scope.categories = categories
                    $scope.subcategories = $scope.allSubcategories = subcategories
            ), (err) ->
                if err then console.log(err)

            applyFilter = ->
                WTP.get($scope.filter).$promise.then ((data) ->
                    updateTable('advertisers', data.advertisers)
                    updateTable('agencies', data.agencies)
                ), (err) ->
                    if err then console.log(err)

            updateTable = (type, data) ->
                result =
                    11: []
                    12: []
                    21: []
                    22: []

                for item in data
                    if item.total_deals < 10 && item.win_rate < 35
                        result[11].push item
                    else if item.total_deals < 10 && item.win_rate >= 35
                        result[12].push item
                    else if item.total_deals >= 10 && item.win_rate < 35
                        result[21].push item
                    else if item.total_deals >= 10 && item.win_rate >= 35
                        result[22].push item

                $scope[type] = result


    ]