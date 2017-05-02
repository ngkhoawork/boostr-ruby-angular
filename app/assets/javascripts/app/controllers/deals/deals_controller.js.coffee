@app.controller 'DealsController',
    ['$rootScope', '$window', '$timeout', '$document', '$scope', '$filter', '$modal', '$q', '$location', 'Deal', 'Stage', 'ExchangeRate', 'DealsFilter', 'shadeColor',
        ($rootScope, $window, $timeout, $document, $scope, $filter, $modal, $q, $location, Deal, Stage, ExchangeRate, DealsFilter, shadeColor) ->
            formatMoney = $filter('formatMoney')

            $scope.selectedDeal = null
            $scope.stages = []
            $scope.columns = []
            $scope.allDeals = []
            $scope.selectedType = 0
            $scope.dealTypes = [
                {name: 'My Deals', param: ''}
                {name: 'My Team\'s Deals', param: 'team'}
                {name: 'All Deals', param: 'company'}
            ]
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
                exchange_rates: []
                owners: []
                advertisers: []
                agencies: []
                isOpen: false
                isEndDateOpen: false
                isStartDateOpen: false
                search: ''
                minBudget: null
                maxBudget: null
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
                apply: (reset) ->
                    selected = this.selected
                    $scope.appliedExchangeRate = selected.exchange_rate
                    $scope.deals = $scope.allDeals.filter (deal) ->
                        if selected.owner && deal.members.indexOf(selected.owner) is -1
                            return false
                        if selected.advertiser && (!deal.advertiser || deal.advertiser.id != selected.advertiser.id)
                            return false
                        if selected.agency && (!deal.agency || deal.agency.id != selected.agency.id)
                            return false
                        if selected.budget
                            if !parseInt(deal.budget)
                                return false
                            if selected.budget.min && parseInt(deal.budget) < selected.budget.min
                                return false
                            if selected.budget.max && parseInt(deal.budget) > selected.budget.max
                                return false
                        if selected.exchange_rate
                            if deal.curr_cd != selected.exchange_rate.currency.curr_cd
                                return false
                        if selected.date.startDate && selected.date.endDate
                            if moment(selected.date.startDate).startOf('day').diff(deal.start_date, 'day') > 0 or
                            moment(selected.date.endDate).startOf('day').diff(deal.start_date, 'day') < 0
                                return false
                        deal

                    columns = angular.copy $scope.emptyColumns
                    $scope.deals.forEach (deal) ->
                        if !deal || !deal.stage_id then return
                        stage = _.findWhere $scope.stages, id: deal.stage_id
                        if stage
                            columns[stage.index].open = stage.open
                            columns[stage.index].push deal
                    $scope.columns = columns
                    sortingDealsByDate(columns)
                    if !reset then this.isOpen = false
                reset: (key) ->
                    DealsFilter.reset(key)
                resetAll: ->
                    DealsFilter.resetAll()
                    this.apply(true)
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

            $scope.init = ->
                $q.all({ deals: Deal.all({filter: $scope.selectedType.param}), stages: Stage.query().$promise }).then (data) ->
                    owners = []
                    advertisers = []
                    agencies = []
                    columns = []
                    dealYears = [DealsFilter.currentYear]
                    maxBudget = 0
                    $scope.deals = data.deals
                    $scope.stages = data.stages
                    $scope.stages = $scope.stages.filter (stage) ->
                        stage.active
                    $scope.stages.forEach (stage, i) ->
                        stage.index = i
                        column = []
                        column.open = stage.open
                        columns.push column
                    $scope.emptyColumns = angular.copy columns
                    $scope.deals.forEach (deal) ->
                        deal.isExpired = moment(deal.start_date) < moment().startOf('day')
                        if deal.deal_members && deal.deal_members.length
                            deal.members = deal.deal_members.map (member) -> member.name
                            owners = owners.concat deal.members
                        if deal.advertiser then advertisers.push deal.advertiser
                        if deal.agency then agencies.push deal.agency
                        if deal.budget && parseInt(deal.budget) > maxBudget
                            maxBudget = parseInt(deal.budget)
                        dealYear = moment(deal.closed_at).year()
                        if dealYear && dealYears.indexOf(dealYear) is -1
                            dealYears.push dealYear
                        stage = _.findWhere $scope.stages, id: deal.stage_id
                        if stage then columns[stage.index].push deal

                    $scope.allDeals = angular.copy $scope.deals
                    $scope.filter.owners = _.uniq owners
                    $scope.filter.advertisers = _.uniq advertisers, 'id'
                    $scope.filter.agencies = _.uniq agencies, 'id'
                    $scope.filter.slider.maxValue = maxBudget
                    $scope.filter.slider.options.ceil = maxBudget
                    $scope.columns = columns
                    dealYears.sort().reverse()
                    $scope.filter.dealYears = dealYears
                    getExchangeRates()
                    sortingDealsByDate(columns)
                    $scope.filter.apply()

            $scope.filterDeals = (filter) ->
                $scope.selectedType = filter
                $rootScope.dealFilter = $scope.dealFilter
                $scope.init()

            $scope.filterDeals($scope.dealTypes[0])

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
                console.log(id)
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

            getExchangeRates = ->
                ExchangeRate.active_exchange_rates().then (exchange_rates) ->
                    usd_exchange_rate = {
                        rate: 1,
                        currency: {
                            name: 'United States dollar',
                            curr_cd: 'USD',
                            curr_symbol: '$'
                        }
                    }
                    exchange_rates.unshift usd_exchange_rate
                    $scope.filter.exchange_rates = exchange_rates

            sortingDealsByDate = (columns) ->
                _.each columns, (col, i) ->
                    if col.open is false
                        col.sort (d1, d2) ->
                            d1 = new Date(d1.closed_at)
                            d2 = new Date(d2.closed_at)
                            if d1 > d2 then return -1
                            if d1 < d2 then return 1
                            return 0
                    else
                        col.sort (d1, d2) ->
                            d1 = new Date(d1.start_date)
                            d2 = new Date(d2.start_date)
                            if d1 > d2 then return 1
                            if d1 < d2 then return -1
                            return 0
                    columns[i] = col.filter (deal) ->
                        if $scope.filter.selected.yearClosed && col.open is false && $scope.filter.selected.yearClosed != moment(deal.closed_at).year()
                            return false
                        deal

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