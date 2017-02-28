@app.controller 'RevenueController',
['$scope', '$modal', '$filter', '$routeParams', '$route', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem',
($scope, $modal, $filter, $routeParams, $route, $location, $q, IO, TempIO, DisplayLineItem) ->

  sorting =
    ascending: 1
    key: ''
  currentYear = moment().year()
  $scope.selectedYear = currentYear
  $scope.revenueFilters = [
    { name: 'IOs', param: '' }
    { name: 'No-Match IOs', param: 'no-match' }
    { name: 'Programmatic', param: 'programmatic' }
    { name: 'Upside Revenues', param: 'upside' }
    { name: 'At Risk Revenues', param: 'risk' }
  ]

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
    $scope.setYears data
    $scope.data = data
    $scope.revenue = data
    $scope.filterByYear($scope.selectedYear)

  $scope.setYears = (data) ->
    years = ['All', currentYear]
    _.forEach data, (item) ->
      year = moment(item.start_date).year()
      if years.indexOf(year) is -1
        years.push year
    $scope.years = years.sort().reverse()

  $scope.init = ->
    $scope.years = []
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

  $scope.filterByYear = (year) ->
    $scope.selectedYear = year
    if year != 'All'
      $scope.revenue = $scope.data.filter (item) ->
        moment(item.start_date).year() is year
    else
      $scope.revenue = $scope.data


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
