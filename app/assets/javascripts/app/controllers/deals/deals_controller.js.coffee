@app.controller 'DealsController',
    ['$rootScope', '$window', '$document', '$scope', '$filter', '$modal', '$q', '$location', 'Deal', 'Stage'
        ($rootScope, $window, $document, $scope, $filter, $modal, $q, $location, Deal, Stage) ->
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
            Selection = ->
                @owner = ''
                @advertiser = ''
                @agency = ''
                @budget = ''
                @date =
                    startDate: null
                    endDate: null
                return
            $scope.filter =
                owners: []
                advertisers: []
                agencies: []
                isOpen: false
                isEndDateOpen: false
                isStartDateOpen: false
                search: ''
                minBudget: null
                maxBudget: null
                selected: new Selection()
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
                        if selected.date.startDate && selected.date.endDate
                            if moment(selected.date.startDate).startOf('day').diff(deal.start_date, 'day') > 0 or
                            moment(selected.date.endDate).startOf('day').diff(deal.start_date, 'day') < 0
                                return false
                        deal
                    columns = angular.copy $scope.emptyColumns
                    $scope.deals.forEach (deal) ->
                        if !deal || !deal.stage_id then return
                        stage = _.findWhere $scope.stages, id: deal.stage_id
                        if stage then columns[stage.index].push deal
                    $scope.columns = columns
                    $scope.sortingDealsByDate()
                    if !reset then this.isOpen = false
                reset: (key) ->
                    this.selected[key] = new Selection()[key]
                resetAll: ->
                    this.selected = new Selection()
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
                    this.selected[key] = value
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
                    maxBudget = 0
                    $scope.deals = data.deals
                    $scope.stages = data.stages
                    $scope.stages = $scope.stages.filter (stage) ->
                        stage.active
                    $scope.stages.forEach (stage, i) ->
                        stage.index = i
                        columns.push []
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
                        stage = _.findWhere $scope.stages, id: deal.stage_id
                        if stage then columns[stage.index].push deal

                    $scope.allDeals = angular.copy $scope.deals
                    $scope.filter.owners = _.uniq owners
                    $scope.filter.advertisers = _.uniq advertisers, 'id'
                    $scope.filter.agencies = _.uniq agencies, 'id'
                    $scope.filter.slider.maxValue = maxBudget
                    $scope.filter.slider.options.ceil = maxBudget
                    $scope.columns = columns
                    $scope.sortingDealsByDate()

#                    for i in [1..15]
#                        $scope.stages.push {index: 6 + i, name: 'TEST' + i}
#                        $scope.columns.push []

            $scope.filterDeals = (filter) ->
                $scope.selectedType = filter
                $rootScope.dealFilter = $scope.dealFilter
                $scope.init()

            $scope.filterDeals($scope.dealTypes[0])

            $scope.openFilter = ->
                $scope.isFilterOpen = !$scope.isFilterOpen

            $scope.sortingDealsByDate = ->
                _.each $scope.columns, (col) ->
                    col.sort (d1, d2) ->
                        d1 = new Date(d1.start_date)
                        d2 = new Date(d2.start_date)
                        if d1 > d2 then return 1
                        if d1 < d2 then return -1
                        return 0

            $scope.onDrop = (deal, newStage) ->
                if deal.stage_id is newStage.id then return
                deal.stage_id = newStage.id
                if !newStage.open && newStage.probability == 0
                    $scope.showCloseDealModal(deal)
                else
                    Deal.update(id: deal.id, deal: deal).then (deal) ->
                deal

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
                    size: 'lg'
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

            shadeColor = (color, percent) ->
                f = parseInt(color.slice(1), 16)
                t = if percent < 0 then 0 else 255
                p = if percent < 0 then percent * -1 else percent
                R = f >> 16
                G = f >> 8 & 0x00FF
                B = f & 0x0000FF
                '#' + (0x1000000 + (Math.round((t - R) * p) + R) * 0x10000 + (Math.round((t - G) * p) + G) * 0x100 + Math.round((t - B) * p) + B).toString(16).slice(1)

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