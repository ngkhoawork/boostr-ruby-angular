@app.controller 'RevenueController',
['$scope', '$modal', '$filter', '$routeParams', '$location', '$q', 'IO', 'TempIO', 'DisplayLineItem',
($scope, $modal, $filter, $routeParams, $location, $q, IO, TempIO, DisplayLineItem) ->

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

  $scope.init = ->
    $scope.revenue = []
    switch $scope.revenueFilter.param
      when "no-match"
        TempIO.all({filter: $scope.revenueFilter.param}).then (tempIOs) ->
          $scope.revenue = tempIOs
      when "upside", "risk"
        DisplayLineItem.all({filter: $scope.revenueFilter.param}).then (ios) ->
          $scope.revenue = ios
      else
        IO.all({filter: $scope.revenueFilter.param}).then (ios) ->
          $scope.revenue = ios

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

  $scope.init()
]
