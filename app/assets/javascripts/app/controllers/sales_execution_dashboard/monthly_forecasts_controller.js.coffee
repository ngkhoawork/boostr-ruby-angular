@app.controller 'MonthlyForecastsController',
  ['$scope', '$document', 'SalesExecutionDashboard', 'Team', 'Product', 'Field', 'Seller','$filter', 'MonthlyForecastsDataStore'
    ($scope, $document, SalesExecutionDashboard, Team, Product, Field, Seller, $filter, MonthlyForecastsDataStore) ->

      #create chart===========================================================
      $scope.teamFilters = []
      $scope.teamId = ''
      $scope.monthlyForecastData = []
      $scope.totalData = { weighted: {}, unweighted: {} }
      $scope.selectedTeam = {
        id:'all',
        name:'Team'
      }
      $scope.datePicker = {
        startDate: null
        endDate: null
      }
      $scope.isDateSet = false

      $scope.dataType = "weighted"

      datePickerInput = $document.find('#kpi-date-picker')

      $scope.datePickerApply = () ->
        if ($scope.datePicker.startDate && $scope.datePicker.endDate)
          datePickerInput.html($scope.datePicker.startDate.format('MMMM D, YYYY') + ' - ' + $scope.datePicker.endDate.format('MMMM D, YYYY'))
          $scope.isDateSet = true
          getData()

      $scope.datePickerCancel = (s, r) ->
        datePickerInput.html('Time period')
        $scope.isDateSet = false
        if !r then getData()

      $scope.resetFilters = () ->
        $scope.selectedTeam = {
          id:'all',
          name:'Team'
        }
        $scope.datePickerCancel(null, true)
        getData()


      #init query

      Team.all(all_teams: true).then (teams) ->
        $scope.teams = teams
        $scope.teams.unshift({
          id:'all',
          name:'All'
        })

      getData = () ->
        query = {}

        if($scope.teamId)
          query.team_id = $scope.teamId

        if($scope.datePicker.startDate && $scope.datePicker.endDate && $scope.isDateSet)
          query.start_date = $filter('date')($scope.datePicker.startDate._d, 'dd-MM-yyyy')
          query.end_date = $filter('date')($scope.datePicker.endDate._d, 'dd-MM-yyyy')

        SalesExecutionDashboard.monthly_forecast(query).then ((data) ->
          $scope.monthlyForecastData = data
          $scope.totalData = { weighted: {}, unweighted: {} }
          _.each data.months, (month) ->
            $scope.totalData.weighted[month] = (if data.forecast.monthly_revenue[month] then data.forecast.monthly_revenue[month] else 0)
            $scope.totalData.unweighted[month] = (if data.forecast.monthly_revenue[month] then data.forecast.monthly_revenue[month] else 0)
            _.each data.forecast.monthly_weighted_pipeline_by_stage, (pipeline, stage_id) ->
              $scope.totalData.weighted[month] += (if pipeline[month] then pipeline[month] else 0)
            _.each data.forecast.monthly_unweighted_pipeline_by_stage, (pipeline, stage_id) ->
              $scope.totalData.unweighted[month] += (if pipeline[month] then pipeline[month] else 0)

          console.log($scope.totalData)

          MonthlyForecastsDataStore.setData(data)
          $scope.dataMonthlyForecast =  MonthlyForecastsDataStore.getData($scope.dataType)
          $scope.optionsMonthlyForecast = MonthlyForecastsDataStore.getOptions()
        ), (err) ->
          if err
            console.log(err)

      #team watcher
      $scope.$watch 'selectedTeam', () ->
        $scope.teamId = $scope.selectedTeam.id
        getData()

      $scope.filterByDataType =(dataType) ->
        $scope.dataType = dataType
        $scope.dataMonthlyForecast =  MonthlyForecastsDataStore.getData($scope.dataType)



#=======================END Cycle Time=======================================================
  ]
