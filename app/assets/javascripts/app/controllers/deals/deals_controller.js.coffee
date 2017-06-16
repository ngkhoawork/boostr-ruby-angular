@app.controller 'DealsController',
    ['$rootScope', '$scope', '$window', '$timeout', '$document', '$filter', '$modal', '$q', '$location', 'Deal', 'Stage', 'ExchangeRate', 'DealsFilter', 'shadeColor',
    ( $rootScope,   $scope,   $window,   $timeout,   $document,   $filter,   $modal,   $q,   $location,   Deal,   Stage,   ExchangeRate,   DealsFilter,   shadeColor ) ->
            formatMoney = $filter('formatMoney')

            $scope.isLoading = false
            $scope.allDealsLoaded = false
            $scope.page = 1
            $scope.selectedDeal = null
            $scope.stages = []
            $scope.columns = []
            $scope.allDeals = []
            $scope.dealsCount = {}
            $scope.dealTypes = [
                {name: 'My Deals', param: ''}
                {name: 'My Team\'s Deals', param: 'team'}
                {name: 'All Deals', param: 'all'}
            ]

            $scope.teamFilter = (value) ->
                if value then DealsFilter.teamFilter = value else DealsFilter.teamFilter

            $scope.history =
                set: (id, key, value) ->
                    if !this[id] then this[id] = {locked: false}
                    if this[id].locked && key is 'from' then return
                    if value then this[id][key] = value
                get: (id) ->
                    return this[id]
                lock: (id, bool) ->
                    if !this[id] then this[id] = {}
                    this[id].locked = bool

            $scope.filter =
                currencies: []
                owners: []
                advertisers: []
                agencies: []
                isOpen: false
                isEndDateOpen: false
                isStartDateOpen: false
                search: ''
                minBudget: null
                maxBudget: null
                appliedSelection: angular.copy DealsFilter.selected
                selected: DealsFilter.selected
                slider:
                    minValue: 0
                    maxValue: 0
                    options:
                        floor: 0
                        ceil: 100
                        minRange: 0
                        pushRange: true
                        translate: (value) ->
                            formatMoney(value)
                        onChange: (slideId, minValue, maxValue, type) ->
                            if !$scope.filter.selected.budget then $scope.filter.selected.budget = {}
                            budget = $scope.filter.selected.budget
                            if minValue && maxValue
                                budget.min = $scope.filter.minBudget = Math.min(minValue, maxValue)
                                budget.max = $scope.filter.maxBudget = Math.max(minValue, maxValue)
                            else
                                budget.min = $scope.filter.minBudget = minValue
                                budget.max = $scope.filter.maxBudget = maxValue
                            if this.maxValue is 0 then this.maxValue = this.options.ceil
                    onChangeNumber: (type) ->
                        if !$scope.filter.selected.budget then $scope.filter.selected.budget = {}
                        budget = $scope.filter.selected.budget
                        $scope.filter.minBudget = parseInt($scope.filter.minBudget) || 0
                        $scope.filter.maxBudget = parseInt($scope.filter.maxBudget) || 0
                        switch type
                            when 'min'
                                if $scope.filter.minBudget > this.options.ceil
                                    $scope.filter.minBudget = this.options.ceil
                            when 'max'
                                if $scope.filter.maxBudget > this.options.ceil
                                    $scope.filter.maxBudget = this.options.ceil
                        if $scope.filter.minBudget && $scope.filter.maxBudget
                            budget.min = this.minValue = Math.min($scope.filter.minBudget, $scope.filter.maxBudget)
                            budget.max = this.maxValue = Math.max($scope.filter.minBudget, $scope.filter.maxBudget)
                        else
                            budget.min = this.minValue = $scope.filter.minBudget
                            budget.max = this.maxValue = $scope.filter.maxBudget
                        if this.maxValue is 0 then this.maxValue = this.minValue
                    refresh: ->
                        $scope.$broadcast 'rzSliderForceRender'
                datePicker:
                    date:
                        startDate: null
                        endDate: null
                    apply: ->
                        _this = $scope.filter.datePicker
                        if (_this.date.startDate && _this.date.endDate)
                            $scope.filter.selected.date = _this.date
                apply: (options = {}) ->
                    this.appliedSelection = angular.copy this.selected
                    $scope.page = 1
                    params = {filter: $scope.teamFilter().param}
                    _.extend params, this.toQuery()
                    $window.scrollTo(0, 0)
                    $scope.isLoading = true
                    Deal.list(params).then (data) ->
                        $scope.deals = data.deals_with_stage
                        _.forEach data.deals_count_per_stage, (stage) ->
                            pair = _.pairs(stage)[0]
                            $scope.dealsCount[pair[0]] = pair[1]
                        updateDealsTable()
                        $scope.filter.isOpen = false
                        $scope.allDealsLoaded = false
                        $timeout -> $scope.isLoading = false
                    if options.close then this.isOpen = false
                reset: (key) ->
                    DealsFilter.reset(key)
                resetAll: ->
                    DealsFilter.resetAll()
                    this.apply(close: true)
                getBudgetValue: ->
                    budget = this.selected.budget
                    if budget.min && !budget.max
                        return 'From ' + formatMoney(budget.min)
                    if !budget.min && budget.max
                        return 'To ' + formatMoney(budget.max)
                    if budget.min && budget.max
                        return formatMoney(budget.min) + ' - ' + formatMoney(budget.max)
                    return 'Budget'
                getDateValue: ->
                    date = this.selected.date
                    if date.startDate && date.endDate
                        return """#{date.startDate.format('MMMM D, YYYY')} -\n#{date.endDate.format('MMMM D, YYYY')}"""
                    return 'Time period'
                select: (key, value) ->
                    DealsFilter.select(key, value)
                onDropdownToggle: ->
                    this.search = ''
                open: (event) ->
#                    event.stopPropagation()
                    this.isOpen = true
                close: (event) ->
#                    event.stopPropagation()
                    this.isOpen = false
                toQuery: (previous) ->
                    f = if previous then this.appliedSelection else this.selected
                    query = {}
                    query.owner_id = f.owner.id if f.owner
                    query.advertiser_id = f.advertiser.id if f.advertiser
                    query.agency_id = f.agency.id if f.agency
                    query.budget_from = f.budget.min if f.budget
                    query.budget_to = f.budget.max if f.budget
                    query.curr_cd = f.currency.curr_cd if f.currency
                    query.start_date = f.date.startDate if f.date.startDate
                    query.end_date = f.date.endDate if f.date.endDate
                    query.closed_year = f.yearClosed if f.yearClosed
                    query

            updateDealsTable = ->
                columns = angular.copy $scope.emptyColumns
                $scope.deals.forEach (deal) ->
                    if !deal || !deal.stage_id then return
                    deal.isExpired = moment(deal.start_date) < moment().startOf('day')
                    stage = _.findWhere $scope.stages, id: deal.stage_id
                    if stage
                        columns[stage.index].open = stage.open
                        columns[stage.index].push deal
                $scope.columns = columns
    


            $scope.init = ->
                $scope.page = 1
                $scope.allDealsLoaded = false
                params = {filter: $scope.teamFilter().param}
                _.extend params, $scope.filter.toQuery()
                $scope.isLoading = true
                $q.all({
                    deals: Deal.list(params)
                    filter: Deal.filter_data()
                    stages: Stage.query().$promise
                }).then (data) ->
                    $scope.filter.owners = data.filter.owners
                    $scope.filter.advertisers = data.filter.advertisers
                    $scope.filter.agencies = data.filter.agencies
                    $scope.filter.currencies = data.filter.currencies
                    $scope.filter.dealYears = [2015.. DealsFilter.currentYear]
                    $scope.filter.slider.maxValue = $scope.filter.slider.options.ceil = data.filter.max_budget
                    columns = []
                    _.forEach data.deals.deals_count_per_stage, (stage) ->
                        pair = _.pairs(stage)[0]
                        $scope.dealsCount[pair[0]] = pair[1]
                    $scope.deals = data.deals.deals_with_stage
                    $scope.stages = data.stages
                    $scope.stages = $scope.stages.filter (stage) -> stage.active
                    $scope.stages.forEach (stage, i) ->
                        stage.index = i
                        column = []
                        column.open = stage.open
                        columns.push column
                    $scope.emptyColumns = angular.copy columns
                    updateDealsTable()
                    $scope.isLoading = false

            $scope.loadMoreDeals = ->
                params = {
                    filter: $scope.teamFilter().param
                    page: ++$scope.page
                }
                _.extend params, $scope.filter.toQuery(true)
                $scope.isLoading = true
                Deal.list(params).then (data) ->
                    $scope.allDealsLoaded = !data.deals_with_stage.length
                    $scope.deals = $scope.deals.concat data.deals_with_stage
                    updateDealsTable()
                    $timeout -> $scope.isLoading = false

            $scope.filterDeals = (filter) ->
                $scope.teamFilter filter
                $rootScope.dealFilter = $scope.dealFilter
                $scope.init();

            if $scope.teamFilter()
                $scope.filterDeals $scope.teamFilter()
            else
                $scope.filterDeals $scope.dealTypes[0]

            $scope.openFilter = ->
                $scope.isFilterOpen = !$scope.isFilterOpen

            $scope.onMoved = (deal, dealIndex, columnIndex) ->
                $scope.history.set deal.id, 'from',
                        deal: dealIndex
                        column: columnIndex
                $scope.history.lock(deal.id, true)

                $scope.columns[columnIndex].splice(dealIndex, 1)

            $scope.onInserted = (deal, dealIndex, columnIndex) ->
                $scope.history.set deal.id, 'to',
                        deal: dealIndex
                        column: columnIndex

            $scope.onDrop = (deal, newStage) ->
                if deal.stage_id is newStage.id then return
                deal.stage_id = newStage.id
                if !newStage.open && newStage.probability == 0
                    $scope.showCloseDealModal(deal)
                else
                    if $scope.history[deal.id] && $scope.history[deal.id].locked
                        return deal
                    Deal.update(id: deal.id, deal: deal).then (deal) ->
                        $scope.history.lock(deal.id, false)
                    , (err) ->
                        if err && err.data && err.data.errors && Object.keys(err.data.errors).length
                            errors = err.data.errors
                            errorsStack = []
                            for key, error of errors
                                errorsStack.push error
                        else if err && err.statusText
                            errorsStack = [err.statusText]
                        if errorsStack.length
                            $scope.undoLastMove(deal.id)
                            $timeout ->
                                $scope.showDealErrors(deal.id, errorsStack)
                deal

            $scope.showDealErrors = (id, errors) ->
                deal = angular.element('#deal-' + id)
                dealOffset = deal.offset()
                error = angular.element('<div class="deal-error"></div>')
                angular.element('#deals').append(error)
                error.outerWidth(deal.outerWidth())
                error.html(errors.join('<br>'))
                errorHeight = error.outerHeight()
                dealOffset.top -= errorHeight + 6
                error.offset(dealOffset)
                error.css('opacity', 1)
                $timeout ->
                    error.css('opacity', 0)
                    $timeout ->
                        error.remove()
                    , 1000
                , 10000

                return true

            $scope.undoLastMove = (dealId) ->
                last = $scope.history.get(dealId)
                if last.from && last.to && last.from.column != last.to.column
                    columnTo = $scope.columns[last.to.column]
                    deal = angular.copy _.findWhere columnTo, id: dealId
                    prevStage = $scope.stages[last.from.column]
                    if deal && prevStage
                        deal.stage_id = prevStage.id
                        columnTo.splice(_.findIndex(columnTo, id: dealId), 1)
                        $scope.columns[last.from.column].splice(last.from.deal, 0, deal)
                        $scope.history.lock(dealId, false)

            $scope.$on 'closeDealCanceled', (event, id) ->
                $scope.undoLastMove(id)

            $scope.$on 'newDeal', (event, id) ->
                $location.path('/deals/' + id)

            $scope.$on 'updated_deals', $scope.init

            $scope.filtering = (item) ->
                if !item then return false
                if item.name
                    return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
                else
                    return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1

            $scope.linkTo = (href) ->
                $location.path href

            $scope.calcWeighted = (deals, stage) ->
                weighted = 0
                if !deals || !deals.length
                    return weighted
                mod = if stage.probability is 0 then 0 else stage.probability / 100
                deals.forEach (deal) ->
                    weighted += (parseInt(deal.budget) || 0) * mod
                weighted

            $scope.calcUnweighted = (deals) ->
                unweighted = 0
                if !deals || !deals.length
                    return unweighted
                deals.forEach (deal) ->
                    unweighted += parseInt(deal.budget) || 0
                unweighted

            $scope.showNewDealModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_form.html'
                    size: 'md'
                    controller: 'DealsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        deal: ->
                            {}

            $scope.showCloseDealModal = (currentDeal) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_close_form.html'
                    size: 'md'
                    controller: 'DealsCloseController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        currentDeal: ->
                            currentDeal

            $scope.coloringColumns = ->
                baseColor = '#ff7200'
                headers = $document.find('.column-header')
                headers.each (i, elem) ->
                    color = shadeColor baseColor, 0.8 - 0.8 / (headers.length - 1) * i
                    header = angular.element(elem)
                    svgPolygon = header.find('polygon')
                    header.css('backgroundColor', color)
                    svgPolygon.css('fill', color)
                return true

            $scope.showDealEditModal = (deal) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_form.html'
                    size: 'md'
                    controller: 'DealsEditController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        deal: ->
                            angular.copy deal

            $scope.deleteDeal = (deal) ->
                if confirm('Are you sure you want to delete "' +  deal.name + '"?')
                    Deal.delete deal



            x = 0
            shift = 0
            dragDirection = null
            interval = null
            dealsContainer = null
            angular.element(document).ready ->
                dealsContainer = angular.element('.deals-container')[0]
                angular.element('#deals').on 'drag', (e) ->
                    e = e.originalEvent
                    if shift >= 35
                        dragDirection = 'right'
                        shift = 0
                    else if shift <= -35
                        dragDirection = 'left'
                        shift = 0
                    if x then shift -= x - e.clientX
                    x = e.clientX

            $scope.onDragStart = ->
                angular.element('.deal-error').remove()
                x = 0
                shift = 0
                dragDirection = null
                interval = setInterval checkPositionThenScroll, 33

            $scope.onDragEnd = ->
                clearInterval interval

            checkPositionThenScroll = ->
                if !dealsContainer then return

                scrollZone = 0.14
                width = $window.innerWidth
                leftBorder = width * scrollZone
                rightBorder = width * (1 - scrollZone)

                if x <= leftBorder && dragDirection == 'left'
                    dealsContainer.scrollLeft -= (leftBorder - x) / 10
                else if x >= rightBorder && dragDirection == 'right'
                    dealsContainer.scrollLeft += (x - rightBorder) / 10

    ]