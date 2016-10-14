@app.controller 'IOController',
  ['$scope', '$modal', '$filter', '$routeParams', '$location', '$q', 'IO', 'IOMember', 'ContentFee'
    ($scope, $modal, $filter, $routeParams, $location, $q, IO, IOMember, ContentFee) ->
      $scope.currentIO = {}
      $scope.activeTab = 'ios'
      $scope.dateRange = []

      updateDateRange = () ->
        if $scope.currentIO
          $scope.dateRange = []
          startDate = new Date($scope.currentIO.start_date)
          endDate = new Date($scope.currentIO.end_date)
          endDate.setUTCDate(1)
          endDate.setMonth(endDate.getMonth() + 1)
          d = startDate
          $scope.dateRange.push(angular.copy(d))
          loop
            d.setMonth(d.getMonth() + 1)
            break if d >= endDate
            $scope.dateRange.push(angular.copy(d))

      $scope.init = ->
        IO.get($routeParams.id).then (io) ->
          $scope.currentIO = io
          updateDateRange()

      $scope.setActiveTab = (type) ->
        $scope.activeTab = type

      $scope.isActiveTab = (type) ->
        return $scope.activeTab == type

      $scope.go = (path) ->
        $location.path(path)

      $scope.updateContentFee = (data) ->
        ContentFee.update(id: data.id, io_id: $scope.currentIO.id, content_fee: data).then (io) ->
          $scope.currentIO = io
          updateDateRange()
      $scope.updateIOMember = (data) ->
        IOMember.update(id: data.id, io_id: $scope.currentIO.id, io_member: data).then (io) ->
          $scope.currentIO = io
          updateDateRange()

      $scope.updateIO = ->
        IO.update(id: $scope.currentIO.id, io: $scope.currentIO).then (io) ->
          $scope.currentIO = io
          updateDateRange()
      $scope.init()
  ]
