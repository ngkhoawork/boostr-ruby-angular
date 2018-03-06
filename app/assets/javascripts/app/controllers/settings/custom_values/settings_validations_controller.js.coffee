@app.controller 'SettingsValidationsController',
['$scope', 'Stage', 'Validation'
($scope, Stage, Validation) ->
  Validation.query().$promise.then (validations) ->
    $scope.billing_contact_validation    = _.findWhere(validations, factor: 'Billing Contact')
    $scope.account_manager_validation    = _.findWhere(validations, factor: 'Account Manager')
    $scope.disable_deal_close_validation = _.findWhere(validations, factor: 'Disable Deal Won')
    $scope.billing_contact_full_address_validation = _.findWhere(validations, factor: 'Billing Contact Full Address')
    $scope.advertiser_base_fields        = _.filter(validations, object: 'Advertiser Base Field')
    $scope.agency_base_fields            = _.filter(validations, object: 'Agency Base Field')
    $scope.deal_base_fields            = _.filter(validations, object: 'Deal Base Field')
    $scope.restrict_deal_reopen       = _.findWhere(validations, factor: 'Restrict Deal Reopen')
    $scope.require_won_reason = _.findWhere(validations, factor: 'Require Won Reason')

  $scope.updateValidation = (validation) ->
    Validation.update(id: validation.id, validation: validation)

  $scope.stages = []
  Stage.query().$promise.then (stages) ->
    stages.push { name: 'None', probability: null }
    $scope.stages = stages

  $scope.restrictDealReopen = () ->
    $scope.updateValidation($scope.restrict_deal_reopen)

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
