@app.controller 'PipelineChangeReportController',
  ['$scope', '$document', '$filter', '$location', 'PipelineChangeReportService',
    ($scope, $document, $filter, $location, PipelineChangeReportService) ->
      $scope.report_data_items = []
      $scope.sortType = 'deal_type'
      $scope.sortReverse  = false
      $scope.query = {}

      $scope.datePicker = {
        startDate: null
        endDate: null
      }
      $scope.isDateSet = false

      datePickerInput = $document.find('#pipeline-change-date-picker')

      $scope.datePickerApply = () ->
        if ($scope.datePicker.startDate && $scope.datePicker.endDate)
          datePickerInput.html($scope.datePicker.startDate.format('MMMM D, YYYY') + ' - ' + $scope.datePicker.endDate.format('MMMM D, YYYY'))
          $scope.isDateSet = true
          getReportData()

      $scope.datePickerCancel = (s, r) ->
        datePickerInput.html('Time period')
        $scope.isDateSet = false
        if !r then getReportData()

      $scope.resetFilters = () ->
        $scope.datePickerCancel(null, true)
        getReportData()

      $scope.go = (path) ->
        $location.path(path)

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      getReportData = ->
        query = {}
        query.start_date = moment().subtract(7,'d')
        query.end_date = moment()

        if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
          query.start_date = $filter('date')($scope.datePicker.startDate)
          query.end_date = $filter('date')($scope.datePicker.endDate)
        PipelineChangeReportService.get(query).$promise.then (data)->
          $scope.report_data_items = data.report_data

      init = ->
        getReportData()
      init()
  ]