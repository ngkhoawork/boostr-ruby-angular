@app.controller 'WhereToPitchController',
    ['$scope', '$document', 'WhereToPitchService', 'Team', 'Product', 'Field', 'Seller', 'CurrentUser'
        ($scope, $document, WTP, Team, Product, Field, Seller, CurrentUser) ->
            $scope.filter = { date_criteria: 'closed_date' }
            $scope.selected = {}
            $scope.maxDeals = 10
            $scope.slider =
                deals:
                    value: $scope.maxDeals
                    options:
                        floor: 0
                        ceil: $scope.maxDeals
                        onEnd: ->
                            if $scope.mainData
                                updateTable('advertisers', $scope.mainData.advertisers)
                                updateTable('agencies', $scope.mainData.agencies)
                winRate:
                    value: 35
                    options:
                        floor: 0
                        ceil: 100
                        translate: (value) ->
                            if value > 0 && value < 100 then return value + '%'
                            value
                        onEnd: ->
                            if $scope.mainData
                                updateTable('advertisers', $scope.mainData.advertisers)
                                updateTable('agencies', $scope.mainData.agencies)
            $scope.selectedTeam =
                id: 'all'
                name:'All'
            $scope.datePicker =
                date:
                    startDate: null
                    endDate: null
                element: $document.find('#advertiser-date-picker')
                isDateSet: false
                apply: ->
                    _this = $scope.datePicker
                    if (_this.date.startDate && _this.date.endDate)
                        _this.element.html(_this.date.startDate.format('MMM D, YY') + ' - ' + _this.date.endDate.format('MMM D, YY'))
                        _this.isDateSet = true
                        $scope.setFilter('time period', _this.date)
                cancel: ->
                    _this = $scope.datePicker
                    _this.element.html('Time period')
                    _this.isDateSet = false
                    $scope.setFilter('time period', _this.date)
                setDefault: ->
                    _this = $scope.datePicker
                    _this.date.startDate = moment()
                        .subtract(6, 'months')
                        .date(1)
                    _this.date.endDate = moment()
                        .subtract(1, 'months')
                        .endOf('month')
                    _this.element.html(_this.date.startDate.format('MMM D, YY') + ' - ' + _this.date.endDate.format('MMM D, YY'))
                    _this.isDateSet = true

            $scope.datePicker.setDefault()

            $scope.setFilter = (type, item) ->
                if !item then return
                $scope.selected[type] = item
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

            $scope.resetFilter = ->
                $scope.selected = {}
                $scope.filter = { date_criteria: 'closed_date' }
                $scope.selectedTeam = {id: 'all', name:'All'}
                $scope.subcategories = $scope.allSubcategories
                $scope.datePicker.setDefault()

            $scope.$watch 'selectedTeam', (nextTeam, prevTeam) ->
                if nextTeam.name == 'Team' && nextTeam.id == 'all' then return
                $scope.filter.seller = null
                delete $scope.selected.seller
                Seller.query({id: nextTeam.id || 'all'}).$promise.then (sellers) ->
                    sellers.unshift({first_name: 'All', id: null})
                    $scope.sellers = sellers
                $scope.setFilter('team', nextTeam)

            #initial query
            CurrentUser.get().$promise.then (user) ->
                $scope.user = user
                query = {}
                # if seller or manager then filter by this user
                if user.user_type is 1 || user.user_type is 2
                    query.seller = user.id
                    $scope.setFilter('seller', user)

                Product.all({active: true}).then (products) ->
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

            $scope.applyFilter = ->
                WTP.get($scope.filter).$promise.then ((data) ->
                    $scope.mainData = data
                    updateTable('advertisers', data.advertisers)
                    updateTable('agencies', data.agencies)
                    updateSlider(data)
                ), (err) ->
                    if err then console.log(err)

            updateTable = (type, data) ->
                deals = $scope.slider.deals.value
                winRate = $scope.slider.winRate.value
                
                result =
                    11: []
                    12: []
                    21: []
                    22: []

                for item in data
                    if item.total_deals >= deals && item.win_rate < winRate
                        result[11].push item
                    else if item.total_deals >= deals && item.win_rate >= winRate
                        result[12].push item
                    else if item.total_deals < deals && item.win_rate < winRate
                        result[21].push item
                    else if item.total_deals < deals && item.win_rate >= winRate
                        result[22].push item

                #sorting data
                for key of result
                    result[key].sort((a, b) ->
                        b.total_deals - a.total_deals || b.win_rate - a.win_rate
                    )

                $scope[type] = result

            updateSlider = (data) ->
                maxDeals = $scope.slider.deals.options.ceil = $scope.maxDeals
                for advertiser in data.advertisers
                    if advertiser.total_deals > maxDeals then maxDeals = advertiser.total_deals
                for agency in data.agencies
                    if agency.total_deals > maxDeals then maxDeals = agency.total_deals
                if maxDeals > $scope.maxDeals
                    $scope.slider.deals.options.ceil = maxDeals
                if $scope.slider.deals.value > $scope.slider.deals.options.ceil
                    $scope.slider.deals.value = $scope.slider.deals.options.ceil



    ]