@app.controller 'DealsController',
    ['$rootScope', '$document', '$scope', '$filter', '$modal', '$q', '$location', 'Deal', 'Stage'
        ($rootScope, $document, $scope, $filter, $modal, $q, $location, Deal, Stage) ->
            formatMoney = $filter('formatMoney')

            $scope.selectedDeal = null
            $scope.stagesById = {}
            $scope.columns = []
            $scope.allDeals = []
            $scope.selectedType = 0
            $scope.dealTypes = [
                {name: 'My Deals', param: ''}
                {name: 'My Team\'s Deals', param: 'team'}
                {name: 'All Deals', param: 'company'}
            ]
            $scope.filter =
                owners: []
                advertisers: []
                agencies: []
                isOpen: true
                isEndDateOpen: false
                isStartDateOpen: false
                search: ''
                minBudget: null
                maxBudget: null
                selected:
                    owner: ''
                    advertiser: ''
                    agency: ''
                    budget: ''
                    startDate: null
                    endDate: null
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
                apply: (reset) ->
                    selected = this.selected
                    $scope.deals = $scope.allDeals.filter (deal) ->
                        if selected.owner && deal.members.indexOf(selected.owner) is -1
                            return false
                        if selected.advertiser && (deal.advertiser && deal.advertiser.id != selected.advertiser.id)
                            return false
                        if selected.agency && (deal.agency && deal.agency.id != selected.agency.id)
                            return false
                        if selected.budget
                            if !parseInt(deal.budget)
                                return false
                            if selected.budget.min && parseInt(deal.budget) < selected.budget.min
                                return false
                            if selected.budget.max && parseInt(deal.budget) > selected.budget.max
                                return false
                        if selected.startDate && !moment(selected.startDate).isSame(deal.start_date, 'day')
                            return false
                        if selected.endDate && !moment(selected.endDate).isSame(deal.end_date, 'day')
                            return false
                        deal
                    columns = angular.copy $scope.emptyColumns
                    $scope.deals.forEach (deal) ->
                        if !deal || !deal.stage_id then return
                        index = $scope.stagesById[deal.stage_id].index
                        columns[index].push deal
                    $scope.columns = columns
                    if !reset then this.isOpen = false
                reset: ->
                    this.selected =
                        owner: ''
                        advertiser: ''
                        agency: ''
                        budget: ''
                        startDate: null
                        endDate: null
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
                    $scope.stages.forEach (stage, i) ->
                        stage.index = i
                        $scope.stagesById[stage.id] = stage
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
                        index = $scope.stagesById[deal.stage_id].index
                        columns[index].push deal

                    $scope.allDeals = angular.copy $scope.deals
                    $scope.filter.owners = _.uniq owners
                    $scope.filter.advertisers = _.uniq advertisers, 'id'
                    $scope.filter.agencies = _.uniq agencies, 'id'
                    $scope.filter.slider.maxValue = maxBudget
                    $scope.filter.slider.options.ceil = maxBudget
                    $scope.columns = columns

    #                $scope.stagesById[100] = {index: 7, name: 'TEST1'}
    #                $scope.columns.push []
    #                $scope.stagesById[200] = {index: 7, name: 'TEST2'}
    #                $scope.columns.push []
    #                $scope.stagesById[300] = {index: 7, name: 'TEST3'}
    #                $scope.columns.push []

            $scope.filterDeals = (filter) ->
                $scope.selectedType = filter
                $rootScope.dealFilter = $scope.dealFilter
                $scope.init()

            $scope.filterDeals($scope.dealTypes[0])

            $scope.openFilter = ->
                $scope.isFilterOpen = !$scope.isFilterOpen

            $scope.onDrop = (deal, newStage) ->
                deal.stage_id = newStage.id
                if !newStage.open
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
    ]