@app.controller 'RevenueController',
  ['$scope', '$document', '$timeout', '$modal', '$filter', '$routeParams', '$route', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem', 'PMP', 'PMPItemDailyActual',
  ( $scope,   $document,   $timeout,   $modal,   $filter,   $routeParams,   $route,   $location,   $q,   IO,   TempIO,   DisplayLineItem,   PMP,   PMPItemDailyActual) ->
    currentYear = moment().year()
    $scope.isLoading = false
    $scope.allItemsLoaded = false
    $scope.revenue = []
    $scope.prevRequest = $q.defer()
    $scope.revenueFilters = [
      {name: 'IOs', value: ''}
      {name: 'No-Match IOs', value: 'no-match'}
      {name: 'PMPs', value: 'pmp'}
      {name: 'No-Match Advertisers', value: 'no-match-adv'}
      {name: 'Upside Revenues', value: 'upside'}
      {name: 'At Risk Revenues', value: 'risk'}
    ]
    $scope.pacingAlertsFilters = [
      {name: 'My Lines', value: 'my'}
      {name: 'My Team\'s Lines', value: 'teammates'}
      {name: 'All Lines', value: 'all'}
    ]
    itemsPerPage = 10
    $scope.filter =
      page: 1
      revenue: $routeParams.filter || ''
      pacing: $routeParams.io_owner || ''
      name: ''
      date:
        startDate: moment().year(currentYear).startOf('year')
        endDate: moment().year(currentYear).endOf('year')

    $scope.datePicker =
      toString: () ->
        date = $scope.filter.date
        if !date.startDate || !date.endDate then return false
        date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
      apply: ->
        $scope.applyFilter()

    resetPagination = ->
      $scope.filter.page = 1
      $scope.allItemsLoaded = false
      $scope.revenue = []
      $scope.prevRequest.reject()

    $scope.setFilter = (key, val) ->
      $scope.filter[key] = val
      switch key
        when 'revenue', 'pacing'
          $location.search({filter: $scope.filter.revenue, io_owner: $scope.filter.pacing})
      $scope.applyFilter()

    $scope.applyFilter = ->
      resetPagination()
      getData(getQuery())

    getQuery = ->
      f = $scope.filter
      query = {}
      query.per = itemsPerPage
      query.page = f.page
      query.filter = f.revenue
      query.name = f.name if f.name
      if f.date.startDate && f.date.endDate
        query.start_date = f.date.startDate.toDate()
        query.end_date = f.date.endDate.toDate()
      query

    getData = (query) ->
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
        else
          IO.query query, (ios) -> revenueRequest.resolve ios
      revenueRequest.promise.then (data) -> setRevenue data


    $scope.loadMoreRevenues = ->
      if !$scope.allItemsLoaded then getData(getQuery())

    parseBudget = (data) ->
      data = _.map data, (item) ->
        item.budget = parseInt item.budget if item.budget
        item.budget_loc = parseInt item.budget_loc if item.budget_loc
        item

    setRevenue = (data) ->
      if data.length < itemsPerPage then $scope.allItemsLoaded = true
      parseBudget data
      $scope.revenue = $scope.revenue.concat data
      $scope.filter.page++
      $timeout -> $scope.isLoading = false

    $scope.showIOEditModal = (io) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/io_form.html'
        size: 'md'
        controller: 'IOEditController'
        backdrop: 'static'
        keyboard: false
        resolve:
          io: -> io

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

    $scope.applyFilter()
  ]
