@app.controller 'RevenueController',
  ['$scope', '$document', '$timeout', '$modal', '$filter', '$routeParams', '$route', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem', 'PMP', 'PMPItemDailyActual', 'RevenueFilter', 'Deal', 'TimePeriod', 'Company', 'PMPItem',
  ( $scope,   $document,   $timeout,   $modal,   $filter,   $routeParams,   $route,   $location,   $q,   IO,   TempIO,   DisplayLineItem,   PMP,   PMPItemDailyActual, RevenueFilter, Deal, TimePeriod, Company, PMPItem) ->
    formatMoney = $filter('formatMoney')
    $scope.scrollCallback = -> $timeout -> $scope.$emit 'lazy:scroll'
    $scope.isLoading = false
    $scope.isItemsLoading = false
    $scope.allItemsLoaded = false
    $scope.allCustomItemsLoaded = false
    $scope.revenue = []
    $scope.revenueItems = []
    $scope.selectedId = null
    $scope.dataCount = 0
    $scope.receivedCount = 0
    $scope.prevRequest = $q.defer()
    $scope.prevItemsRequest = $q.defer()
    $scope.revenueLimit = 50
    $scope.selectedMenu = 'no-match-adv-ssp-advertisers'

    $scope.menus = [
      {
        value: "no-match-adv",
        name: "Deals"
      },
      {
        value: "no-match-adv-ssp-advertisers",
        name: "Advertisers"
      }
    ];

    $scope.onSelectMenu = (value) ->
      $scope.selectedMenu = value;
      $scope.setCurrentTab(value);

    $scope.revenueFilters = [
      {name: 'IOs', value: '', type: 'default'}
      {name: 'No-Match IOs', value: 'no-match', type: 'default'}
      {name: 'PMPs', value: 'pmp', type: 'default'}
      {name: 'No-Match Advertisers', value: 'no-match-adv', type: 'custom'}
      {name: 'Upside Revenues', value: 'upside', type: 'default'}
      {name: 'At Risk Revenues', value: 'risk', type: 'default'}
    ]
    $scope.pacingAlertsFilters = [
      {name: 'My Lines', value: 'my'}
      {name: 'My Team\'s Lines', value: 'teammates'}
      {name: 'All Lines', value: 'all'}
    ]
    itemsPerPage = 10
    customItemsPerPage = 25
    $scope.company = {}
    $scope.filter =
      page: 1
      revenue: $routeParams.filter || ''
      pacing: $routeParams.io_owner || ''
      name: ''
      isOpen: false
      search: ''
      minBudget: null
      maxBudget: null
      selected: RevenueFilter.selected
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
      getDateValue: (key) ->
        date = this.selected[key]
        if date.startDate && date.endDate
          return "#{date.startDate.format('MMM D, YYYY')} -\n#{date.endDate.format('MMM D, YYYY')}"
        return switch key
          when 'startDate' then 'Start date'
          when 'endDate' then 'End date'
      getBudgetValue: ->
        budget = this.selected.budget
        if budget.min && !budget.max
          return 'From ' + formatMoney(budget.min)
        if !budget.min && budget.max
          return 'To ' + formatMoney(budget.max)
        if budget.min && budget.max
          return formatMoney(budget.min) + ' - ' + formatMoney(budget.max)
        return 'Budget'			
      open: (event) ->
        this.isOpen = true
      close: (event) ->
        this.isOpen = false
      reset: (key) ->
        RevenueFilter.reset(key)
      resetAll: ->
        RevenueFilter.resetAll()	
      onDropdownToggle: ->
        this.search = ''
      apply: (reset) ->
        $scope.applyFilter($scope.scrollCallback)
        if !reset then this.isOpen = false
      select: (key, value) ->
        RevenueFilter.select(key, value)

    $scope.orderKeys = {
      row_1: true,
      row_2: true,
      row_3: true,
      row_4: true,
      row_5: true,
      row_6: true
    }

    $scope.setCustomOrder = (keyName, orderVal, orderKey) ->
      $scope.orderKeys[orderKey] = !orderVal;
      if !orderVal
        val = '-'+keyName
      else
        val = keyName
      $scope.revenue = $filter('orderBy')($scope.revenue, val)

    $scope.customFilter =
      page: 1
      revenueItems: $routeParams.filter || ''

    $scope.filtering = (item) ->
      if !item then return false
      if item.name
        return item.name.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1
      else
        return item.toString().toUpperCase().indexOf($scope.filter.search.toUpperCase()) > -1

    resetPagination = ->
      $scope.filter.page = 1
      $scope.allItemsLoaded = false
      $scope.revenue = []
      $scope.prevRequest.reject()

    resetCustomPagination = ->
      $scope.customFilter.page = 1
      $scope.allCustomItemsLoaded = false
      $scope.revenueItems = []
      $scope.prevItemsRequest.reject()

    $scope.setFilter = (key, val) ->
      $scope.filter[key] = val
      switch key
        when 'revenue', 'pacing'
          $location.search({filter: $scope.filter.revenue, io_owner: $scope.filter.pacing})
      $scope.applyFilter($scope.scrollCallback)

    $scope.applyFilter = (callback) ->
      resetPagination()
      getData(getQuery(), callback)

    $scope.applyCustomFilter = (id, callback) ->
      resetCustomPagination()
      getItemsData(getItemsQuery(id), callback)

    getItemsQuery = (id) ->
      f = $scope.customFilter
      query = {}
      query.per = customItemsPerPage
      query.page = f.page
      query.customFilter = f.revenueItems
      query.pmp_item_id = id
      query.list_type = 'grouped'
      query.custom = 'items'
      query.is_items = true
      query.name = f.name if f.name


      query

    getQuery = ->
      f = $scope.filter
      query = {}
      query.per = itemsPerPage
      query.page = f.page
      query.filter = f.revenue
      query.name = f.name if f.name

      # Expandable filter only for IO and No Match IO subtabs
      if query.filter == '' or query.filter == 'no-match'
        $scope.showExpandableFilter = true
        query.advertiser_id = f.selected.advertiser.id if f.selected.advertiser
        query.agency_id = f.selected.agency.id if f.selected.agency
        query.io_number = f.selected.ioNumber if f.selected.ioNumber
        query.external_io_number = f.selected.externalIoNumber if f.selected.externalIoNumber
        query.budget_start = f.selected.budget.min if f.selected.budget
        query.budget_end = f.selected.budget.max if f.selected.budget
        query.start_date_start = f.selected.startDate.startDate.add(f.selected.startDate.startDate.utcOffset(), 'm') if f.selected.startDate.startDate
        query.start_date_end = f.selected.startDate.endDate.add(f.selected.startDate.endDate.utcOffset(), 'm') if f.selected.startDate.endDate
        query.end_date_start = f.selected.endDate.startDate.add(f.selected.endDate.startDate.utcOffset(), 'm') if f.selected.endDate.startDate
        query.end_date_end = f.selected.endDate.endDate.add(f.selected.endDate.endDate.utcOffset(), 'm') if f.selected.endDate.endDate
      else if query.filter == 'no-match-adv'
        $scope.showExpandableFilter = true
        query.list_type = 'grouped'
        query.advertiser_id = f.selected.advertiser.id if f.selected.advertiser
        query.agency_id = f.selected.agency.id if f.selected.agency
        query.io_number = f.selected.ioNumber if f.selected.ioNumber
        query.external_io_number = f.selected.externalIoNumber if f.selected.externalIoNumber
        query.budget_start = f.selected.budget.min if f.selected.budget
        query.budget_end = f.selected.budget.max if f.selected.budget
        query.start_date_start = f.selected.startDate.startDate.add(f.selected.startDate.startDate.utcOffset(), 'm') if f.selected.startDate.startDate
        query.start_date_end = f.selected.startDate.endDate.add(f.selected.startDate.endDate.utcOffset(), 'm') if f.selected.startDate.endDate
        query.end_date_start = f.selected.endDate.startDate.add(f.selected.endDate.startDate.utcOffset(), 'm') if f.selected.endDate.startDate
        query.end_date_end = f.selected.endDate.endDate.add(f.selected.endDate.endDate.utcOffset(), 'm') if f.selected.endDate.endDate
        $scope.showExpandableFilter= false
        $scope.filter.close()

      query

    getData = (query, callback) ->
      $scope.isLoading = true
      revenueRequest = $q.defer()
      $scope.prevRequest = revenueRequest
      switch query.filter
        when 'no-match'
          TempIO.query query, (tempIOs) -> revenueRequest.resolve tempIOs
        when 'upside', 'risk'
          query.io_owner = $scope.filter.pacing if $scope.filter.pacing #adding extra param
          DisplayLineItem.query query, (ios) -> revenueRequest.resolve ios
        when 'pmp'
          PMP.query query, (pmps) -> revenueRequest.resolve pmps
        when 'no-match-adv'
          query.with_advertiser = false
          PMPItemDailyActual.query query, (pmpItemDailyActuals) ->
            revenueRequest.resolve pmpItemDailyActuals
        when 'no-match-adv-ssp-advertisers'
          PMP.custom_query query, (pmps) ->
            revenueRequest.resolve pmps
        else
          IO.query query, (ios) -> revenueRequest.resolve ios
      revenueRequest.promise.then (data) ->
        $scope.filter.ioNumbers = data.map( (resource) ->
          resource.io_number
        )
        $scope.filter.externalIoNumbers = data.map( (resource) ->
          resource.external_io_number
        )
        setRevenue data, callback

    getItemsData = (query, callback) ->
      $scope.isItemsLoading = true
      revenueCustomRequest = $q.defer()
      $scope.prevItemsRequest = revenueCustomRequest
      switch query.customFilter
        when 'no-match-adv'
          query.with_advertiser = false
          PMPItemDailyActual.query query, (pmpItemDailyActuals) ->
            revenueCustomRequest.resolve pmpItemDailyActuals
      revenueCustomRequest.promise.then (response) ->
        setItemsRevenue response, callback

    $scope.loadMoreRevenues = ->
      if !$scope.allItemsLoaded then getData(getQuery())

    $scope.loadMoreItemsRevenues = (row) ->
      if $scope.revenueItems.length < $scope.revenueLimit
        getItemsData(getItemsQuery($scope.selectedId))
      else
        $scope.allCustomItemsLoaded = true

    $scope.setCurrentTab = (val) ->
      $scope.setFilter(val);

    parseBudget = (data) ->
      data = _.map data, (item) ->
        item.budget = parseInt item.budget if item.budget
        item.budget_loc = parseInt item.budget_loc if item.budget_loc
        item

    setRevenue = (data, callback) ->
      if data.length < itemsPerPage then $scope.allItemsLoaded = true
      parseBudget data
      $scope.revenue = $scope.revenue.concat(data)
      $scope.filter.page++
      $timeout -> $scope.isLoading = false
      callback() if _.isFunction callback

    setItemsRevenue = (response, callback) ->
      if response.length < customItemsPerPage then $scope.allCustomItemsLoaded = true
      parseBudget response
      $scope.revenueItems = $scope.revenueItems.concat response
      $scope.receivedCount = $scope.revenueItems.length
      $scope.customFilter.page++
      $timeout -> $scope.isItemsLoading = false
      callback() if _.isFunction callback

    $scope.showIOEditModal = (io) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/io_form.html'
        size: 'md'
        controller: 'IOEditController'
        backdrop: 'static'
        keyboard: false
        resolve:
          io: -> io

    $scope.expandRecord = (row, index) ->
      $scope.selectedPmpId = row.pmp.id
      $scope.dataCount = row.count
      row.expanded = !row.expanded;
      $scope.selectedIndex = index
      $scope.selectedId = row.id
      $scope.applyCustomFilter(row.id)

    $scope.showAssignIOModal = (tempIO) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/io_assign_form.html'
        size: 'lg'
        controller: 'IOAssignController'
        backdrop: 'static'
        keyboard: false
        resolve:
          tempIO: ->
            tempIO	

    $scope.showAssignAdvertiserModal = (pmpItemDailyActual) ->
      modalInstance = $modal.open
        templateUrl: 'modals/advertiser_assign_form.html'
        size: 'lg'
        controller: 'AdvertiserAssignController'
        backdrop: 'static'
        keyboard: false
        resolve:
          pmpItemDailyActual: ->
            pmpItemDailyActual
      modalInstance.result.then (ids) ->
        $scope.revenueItems = _.filter $scope.revenueItems, (record) -> !_.contains(ids, record.id)
        PMPItem.get_item(pmp_id: $scope.selectedPmpId, id: $scope.selectedId).then (pmp_item) ->
          changeCounters(pmp_item);

    changeCounters = (pmp_item) ->
      for item in $scope.revenue
        if (item.id == pmp_item.id)
          item.total_revenue_loc = pmp_item.total_revenue_loc;
          item.total_impressions = pmp_item.total_impressions;

    $scope.showAssignPmpAdvertiserModal = (pmpObject) ->
      modalInstance = $modal.open
        templateUrl: 'modals/pmp_ssp_advertiser_assign_form.html'
        size: 'lg'
        controller: 'AdvertiserAssignPmpController'
        backdrop: 'static'
        keyboard: false
        resolve:
          object: ->
            pmpObject
      modalInstance.result.then (ids) ->
        $scope.revenue = _.filter $scope.revenue, (record) -> !_.contains(ids, record.id)

    $scope.deleteIo = (io, $event) ->
      $event.stopPropagation();
      if confirm('Are you sure you want to delete "' + io.name + '"?')
        IO.delete io, ->
          $location.path('/revenue')

    $scope.addPmp = () ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/pmp_form.html'
        size: 'md'
        controller: 'PmpsNewController'
        backdrop: 'static'
        keyboard: false
        resolve:
          pmp: null

    $scope.getFilters = ->
      $q.all({
        filterData: Deal.filter_data(),
        timePeriods: TimePeriod.all()
      }).then (filterData) ->
        $scope.filter.advertisers = filterData.filterData.advertisers
        $scope.filter.agencies = filterData.filterData.agencies
        $scope.filter.timePeriods = filterData.timePeriods
        $scope.filter.slider.maxValue = $scope.filter.slider.options.ceil = filterData.filterData.max_budget

    Company.get().$promise.then (company) -> $scope.company = company
    $scope.getFilters()
    $scope.applyFilter()
  ]
