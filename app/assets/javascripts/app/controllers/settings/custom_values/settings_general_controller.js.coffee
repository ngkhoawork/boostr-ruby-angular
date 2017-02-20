@app.controller 'SettingsGeneralController',
['$scope', 'Company', 'Stage', 'Validation'
($scope, Company, Stage, Validation) ->

  Company.get().$promise.then (company) ->
    $scope.company = company

  Validation.query().$promise.then (validations) ->
    $scope.billing_contact_validation = _.findWhere(validations, factor: 'Billing Contact')
    $scope.account_manager_validation = _.findWhere(validations, factor: 'Account Manager')

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

  $scope.updateValidation = (validation) ->
    Validation.update(id: validation.id, validation: validation)

  $scope.stages = []
  Stage.query().$promise.then (stages) ->
    stages.push { name: 'None', probability: null }
    $scope.stages = stages
]
