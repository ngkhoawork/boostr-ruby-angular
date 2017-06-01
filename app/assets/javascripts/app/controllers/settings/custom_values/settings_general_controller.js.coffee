@app.controller 'SettingsGeneralController',
['$scope', 'Company', 'Stage', 'Validation', 'User'
($scope, Company, Stage, Validation, User) ->
  $scope.userTypes = User.user_types_list
  console.log($scope.userTypes)
  Company.get().$promise.then (company) ->
    $scope.company = company

  Validation.query().$promise.then (validations) ->
    $scope.billing_contact_validation    = _.findWhere(validations, factor: 'Billing Contact')
    $scope.account_manager_validation    = _.findWhere(validations, factor: 'Account Manager')
    $scope.disable_deal_close_validation = _.findWhere(validations, factor: 'Disable Deal Won')

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

  $scope.confirmDisableDealWon = () ->
    if $scope.disable_deal_close_validation.criterion.value
      if confirm(
        "Are you sure that manual change to Closed Won stage should be disabled?
        It will be possible to close deals using API Integrations ONLY."
      )
        $scope.updateValidation($scope.disable_deal_close_validation)
      else
        $scope.disable_deal_close_validation.criterion.value = false
    else
      $scope.updateValidation($scope.disable_deal_close_validation)
]
