@app.controller 'ContractsFilterController', [
    '$scope', 'ContractsFilter', 'Contract'
    ($scope,   ContractsFilter,   Contract) ->

        $scope.filter =
            members: []
            deals: []
            advertisers: []
            agencies: []
            hodlingCompanies: []
            isOpen: false
            search: ''
            selected: ContractsFilter.selected
            datePicker:
                startDate:
                    startDate: null
                    endDate: null
                endDate:
                    startDate: null
                    endDate: null
                applyStartDate: ->
                    _this = $scope.filter.datePicker
                    if (_this.startDate.startDate && _this.startDate.endDate)
                        $scope.filter.selected.startDate = _this.startDate
                applyEndDate: ->
                    _this = $scope.filter.datePicker
                    if (_this.endDate.startDate && _this.endDate.endDate)
                        $scope.filter.selected.endDate = _this.endDate
            get: ->
                s = this.selected
                filter = {}
                filter.type_id = s.type.id if s.type
                filter.status_id = s.status.id if s.status
                filter.advertiser_id = s.advertiser.id if s.advertiser
                filter.agency_id = s.agency.id if s.agency
                filter.deal_id = s.deal.id if s.deal
                filter.holding_company_id = s.holdingCompany.id if s.holdingCompany
                filter.user_id = s.member.id if s.member
                if s.startDate.startDate && s.startDate.endDate
                    filter.start_date_start = s.startDate.startDate.toDate()
                    filter.start_date_end = s.startDate.endDate.toDate()
                if s.endDate.startDate && s.endDate.endDate
                    filter.end_date_start = s.endDate.startDate.toDate()
                    filter.end_date_end = s.endDate.endDate.toDate()
                filter
            apply: (reset) ->
                params = this.get()
                params.page = 1
                $scope.$parent.getContracts(params)
#                if !reset then this.isOpen = false
            searching: (item) ->
                if !item then return false
                if item.name
                    return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
                else
                    return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
            getDateValue: (key) ->
                date = this.selected[key]
                if date.startDate && date.endDate
                    return "#{date.startDate.format('MMM D, YYYY')} -\n#{date.endDate.format('MMM D, YYYY')}"
                return switch key
                    when 'startDate' then 'Start date'
                    when 'endDate' then 'End date'
            reset: ContractsFilter.reset
            resetAll: ContractsFilter.resetAll
            select: ContractsFilter.select
            onDropdownToggle: ->
                this.search = ''
            open: ->
                this.isOpen = true
            close: ->
                this.isOpen = false

        Contract.filterValues().then (data) ->
            console.log data
            $scope.filter.types = data.type_options
            $scope.filter.statuses = data.status_options
            $scope.filter.members = data.linked_users
            $scope.filter.deals = data.linked_deals
            $scope.filter.advertisers = data.linked_advertisers
            $scope.filter.agencies = data.linked_agencies
            $scope.filter.holdingCompanies = data.linked_holding_companies

]
