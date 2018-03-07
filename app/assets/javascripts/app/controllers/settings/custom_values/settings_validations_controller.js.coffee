@app.controller 'SettingsValidationsController',
['$scope', 'Stage', 'Validation', '$q'
($scope, Stage, Validation, $q) ->
  $scope.stages = []
  $scope.validation = {
    billing_contacts: [],
    account_managers: []
  }
  $scope.advertiser_base_fields = []
  $scope.agency_base_fields = []
  $scope.deal_base_fields = []

  init = () ->
    $q.all({
      validations: Validation.query().$promise
      stages: Stage.query({active: true}).$promise
    }).then (data) ->
      _.forEach data.validations, (validation) ->
        if validation.object == 'Billing Contact'
          $scope.validation.billing_contacts.push validation
        else if validation.object == 'Account Manager'
          $scope.validation.account_managers.push validation
        else if validation.factor == 'Disable Deal Won'
          $scope.disable_deal_close_validation = validation
        else if validation.factor == 'Billing Contact Full Address'
          $scope.billing_contact_full_address_validation = validation
        else if validation.object == 'Advertiser Base Field'
          $scope.advertiser_base_fields.push validation
        else if validation.object == 'Agency Base Field'
          $scope.agency_base_fields.push validation
        else if validation.object == 'Deal Base Field'
          $scope.deal_base_fields.push validation
        else if validation.factor == 'Restrict Deal Reopen'
          $scope.restrict_deal_reopen = validation
        else if validation.factor == 'Require Won Reason'
          $scope.require_won_reason = validation
      $scope.stages = data.stages

  $scope.updateValidation = (validation) ->
    Validation.update(id: validation.id, validation: validation)

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

  $scope.stageName = (item) ->
    if item.criterion
      stage = _.find $scope.stages, id: item.criterion.value.id
      "#{stage.sales_process.name} #{stage.name}" 
    else
      "#{item.sales_process.name} #{item.name}"

  $scope.updateBillingContactValidation = (item, model) ->
    $scope.validation.billing_contacts = _.reject $scope.validation.billing_contacts, (billingContact) ->
      if billingContact.criterion
        billingContact.criterion.value.sales_process_id == item.sales_process.id
      else
        billingContact.sales_process.id == item.sales_process.id
    Validation.create(validation: {
      object: 'Billing Contact', 
      factor: item.sales_process.id, 
      value_type: 'Object',
      criterion: {
        value_object_id: item.id,
        value_type: 'Object',
        value_object_type: 'Stage'
      }
    }).$promise.then (validation) ->
      $scope.validation.billing_contacts.push validation

  $scope.removeBillingContactValidation = (item, model) ->
    Validation.delete(id: item.id)

  $scope.updateAccountManagerValidation = (item, model) ->
    $scope.validation.account_managers = _.reject $scope.validation.account_managers, (accountManager) ->
      if accountManager.criterion
        accountManager.criterion.value.sales_process_id == item.sales_process.id
      else
        accountManager.sales_process.id == item.sales_process.id
    Validation.create(validation: {
      object: 'Account Manager', 
      factor: item.sales_process.id, 
      value_type: 'Object',
      criterion: {
        value_object_id: item.id,
        value_type: 'Object',
        value_object_type: 'Stage'
      }
    }).$promise.then (validation) ->
      $scope.validation.account_managers.push validation

  $scope.removeAccountManagerValidation = (item, model) ->
    Validation.delete(id: item.id)

  init()
]
