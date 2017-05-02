@app.controller 'RevenueController',
['$scope', '$document', '$modal', '$filter', '$routeParams', '$route', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem',
($scope, $document, $modal, $filter, $routeParams, $route, $location, $q, IO, TempIO, DisplayLineItem) ->

  $scope.sorting =
    key: ''
    reverse: false
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

  parseBudget = (data) ->
    data = _.map data, (item) ->
      item.budget = parseInt item.budget  if item.budget
      item.budget_loc = parseInt item.budget_loc  if item.budget_loc
      item

  $scope.setRevenue = (data) ->
#    data.map (item) -> item.budget_loc = Number item.budget_loc if item
    parseBudget data
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

  $scope.showIOEditModal = (io) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/io_form.html'
      size: 'md'
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
    if $scope.sorting.key != key
      $scope.sorting.key = key
      $scope.sorting.reverse = false
    else
      $scope.sorting.reverse = !$scope.sorting.reverse

  $scope.$on 'updated_ios', ->
    $scope.init()
    IO.query().$promise

  $scope.deleteIo = (io, $event) ->
    $event.stopPropagation();
    if confirm('Are you sure you want to delete "' +  io.name + '"?')
      IO.delete io, ->
        $location.path('/revenue')

  $scope.init()
]
