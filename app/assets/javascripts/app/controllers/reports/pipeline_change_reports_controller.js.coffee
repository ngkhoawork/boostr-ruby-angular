@app.controller 'PipelineChangeReportController',
  ['$scope', '$window', '$document', '$httpParamSerializer', '$location', 'PipelineChangeReportService',
    ($scope, $window, $document, $httpParamSerializer, $location, PipelineChangeReportService) ->

      $scope.report_data_items = []
      $scope.changeTypes = [
        'New Deals'
        'Won Deals'
        'Lost Deals'
        'Budget Changed'
        'Stage Changed'
        'Start Date Changed'
        'Member Added'
        'Member Removed'
        'Share Changed'
      ]
      $scope.sortType = 'deal_type'
      $scope.sortReverse  = false

      appliedFilter = null
      defaultFilter =
        type: ''
        date:
          startDate: moment().subtract(7,'d')
          endDate: moment()

      $scope.filter = angular.copy defaultFilter

      $scope.datePicker =
        toString: (key) ->
          date = $scope.filter[key]
          if !date.startDate || !date.endDate then return false
          date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')
#        apply: -> console.log arguments


      $scope.setFilter = (key, val) ->
          $scope.filter[key] = val

      $scope.removeFilter = (key, item) ->
        $scope.filter[key] = _.reject $scope.filter[key], (row) -> row.id == item.id

      $scope.applyFilter = ->
        appliedFilter = angular.copy $scope.filter
        query = getQuery()
        getReport query

      $scope.isFilterApplied = ->
        !angular.equals $scope.filter, appliedFilter

      $scope.resetFilter = ->
        $scope.filter = angular.copy defaultFilter

      getQuery = ->
        f = $scope.filter
        query = {}
        query.change_type = f.type if f.type
        if f.date.startDate && f.date.endDate
          query.start_date = f.date.startDate.toDate()
          query.end_date = f.date.endDate.toDate()
        query

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      getReport = (query) ->
        PipelineChangeReportService.get(query).$promise.then (data)->
          $scope.report_data_items = data.report_data

      $scope.export = ->
        url = '/api/deal_reports.csv'
        query = getQuery()
        query.utc_offset = moment().utcOffset()
        $window.open url + '?' + $httpParamSerializer query
        return
  ]
