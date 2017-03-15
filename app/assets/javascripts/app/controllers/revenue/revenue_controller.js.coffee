@app.controller 'RevenueController',
['$scope', '$document', '$modal', '$filter', '$routeParams', '$route', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem',
($scope, $document, $modal, $filter, $routeParams, $route, $location, $q, IO, TempIO, DisplayLineItem) ->

  sorting =
    ascending: 1
    key: ''
  currentYear = moment().year()
  $scope.revenueFilters = [
    { name: 'IOs', param: '' }
    { name: 'No-Match IOs', param: 'no-match' }
    { name: 'Programmatic', param: 'programmatic' }
    { name: 'Upside Revenues', param: 'upside' }
    { name: 'At Risk Revenues', param: 'risk' }
  ]
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
      $scope.filterByDate()
    cancel: ->
      _this = $scope.datePicker
      _this.element.html('Time period')
      _this.isDateSet = false
    setDefault: ->
      _this = $scope.datePicker
      _this.date.startDate = moment().year(currentYear).startOf('year')
      _this.date.endDate = moment().year(currentYear).endOf('year')
      _this.element.html(_this.date.startDate.format('MMM D, YY') + ' - ' + _this.date.endDate.format('MMM D, YY'))
      _this.isDateSet = true

  $scope.datePicker.setDefault()

  if $routeParams.filter
    _.each $scope.revenueFilters, (filter) ->
      if filter.param == $routeParams.filter
        $scope.revenueFilter = filter
  else
    $scope.revenueFilter = $scope.revenueFilters[0]

  $scope.searchText = ''

  $scope.pacingAlertsFilters = [
    { name: 'My Lines', value: 'my', order: 0 }
    { name: 'My Team\'s Lines', value: 'teammates', order: 1 }
    { name: 'All Lines', value: 'all', order: 2 }
  ]

  $scope.currentPacingAlertsFilterValue =  $routeParams.io_owner || 'my'

  $scope.setPacingAlertsFilter = (filter) ->
    $location.search({ filter: $scope.revenueFilter.param, io_owner: filter.value })

  $scope.setRevenue = (data) ->
#    data.map (item) -> item.budget_loc = Number item.budget_loc if item
    $scope.data = data
    $scope.revenue = data
    $scope.filterByDate()


  $scope.init = ->
    $scope.revenue = []
    switch $scope.revenueFilter.param
      when "no-match"
        TempIO.all({filter: $scope.revenueFilter.param}).then (tempIOs) ->
          $scope.setRevenue tempIOs
      when "upside", "risk"
        DisplayLineItem.all({ filter: $scope.revenueFilter.param, io_owner: $routeParams.io_owner || $scope.currentPacingAlertsFilterValue }).then (ios) ->
          $scope.setRevenue ios
      else
        IO.all({filter: $scope.revenueFilter.param}).then (ios) ->
          $scope.setRevenue ios

  $scope.filterRevenues = (filter) ->
    $scope.revenueFilter = filter
    $scope.init()

  $scope.showIOEditModal = (io, $event) ->
    $event.stopPropagation();
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/io_form.html'
      size: 'lg'
      controller: 'IOEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        io: ->
          io
    .result.then (updated_io) ->
      if (updated_io)
        $scope.init();

  $scope.filterByDate = () ->
    date = $scope.datePicker.date
    $scope.revenue = $scope.data.filter (item) ->
      moment(item.start_date).isBetween(date.startDate, date.endDate, null, '[]')


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
    .result.then (updated_temp_io) ->
      if (updated_temp_io)
        $scope.init();
  $scope.go = (path) ->
    $location.path(path)

  $scope.sortBy = (key) ->
      if sorting.key != key
        sorting.key = key
        sorting.order = 1
      else
        sorting.order *= -1

      getVal = (obj, path) ->
        path = path || ''
        objKey = (obj, key) -> if obj then obj[key] else null
        path.split('.').reduce(objKey, obj)


      $scope.revenue.sort (a, b) ->
        v1 = getVal a, key
        v2 = getVal b, key
        if typeof v1 is 'string' then v1 = v1.toLowerCase()
        if typeof v2 is 'string' then v2 = v2.toLowerCase()
        if key.indexOf('budget') != -1 || key == 'price'
          v1 = Number v1
          v2 = Number v2
        if v1 == null || v1 == undefined || v1 == ''
         return -1 * sorting.order
        if v2 == null || v2 == undefined || v1 == ''
          return 1 * sorting.order
        if v1 > v2 then return 1 * sorting.order
        if v1 < v2 then return -1 * sorting.order
        return 0

  $scope.init()
]
