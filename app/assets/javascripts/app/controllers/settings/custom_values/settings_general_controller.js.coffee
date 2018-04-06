@app.controller 'SettingsGeneralController',
['$scope', '$modal', 'Company', 'Stage', 'Validation', 'User', 'Forecast'
($scope,    $modal,   Company,   Stage,   Validation,   User,   Forecast) ->
  $scope.userTypes = User.user_types_list

  Company.get().$promise.then (company) ->
    $scope.company = company

  $scope.days = [
    { id: 0, name: 'Sunday' }
    { id: 1, name: 'Monday' }
    { id: 2, name: 'Tuesday' }
    { id: 3, name: 'Wednesday' }
    { id: 4, name: 'Thursday' }
    { id: 5, name: 'Friday' }
    { id: 6, name: 'Saturday' }
  ]

  $scope.updateCompany = ->
    $scope.company.$update()

  $scope.updateStage = (stage) ->
    stage.$update()

  $scope.stages = []
  Stage.query().$promise.then (stages) ->
    stages.push { name: 'None', probability: null }
    $scope.stages = stages
  
  $scope.runForecastCalculation = () ->
    if confirm("Are you sure run the forecast calculation? This will take upto several minutes.")
      Forecast.run_forecast_calculation().$promise.then(
        (response) ->
        (error) ->
          $scope.showWarningModal = (message) ->
          $scope.modalInstance = $modal.open
            templateUrl: 'modals/deal_warning.html'
            size: 'md'
            controller: 'DealWarningController'
            backdrop: 'static'
            keyboard: true
            resolve:
              message: -> error.data['error']
              id: -> null
      )
]
