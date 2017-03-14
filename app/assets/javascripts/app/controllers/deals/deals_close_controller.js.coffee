@app.controller 'DealsCloseController',
['$scope', '$rootScope', '$routeParams', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Field', 'currentDeal',
($scope, $rootScope, $routeParams, $modalInstance, $q, $location, Deal, Client, Field, currentDeal) ->

  $scope.init = ->
    $scope.selectedReason = null
    $scope.formType = "Closed Reason"
    $scope.submitText = "Submit"
    $scope.currentDeal = {}
    $scope.resetDealProductBudget()
    Deal.get(currentDeal.id).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.selectReason = (reason) ->
    $scope.selectedReason = reason

  $scope.setCurrentDeal = (deal) ->
    _.each deal.members, (member) ->
      Field.defaults(member, 'Client').then (fields) ->
        member.role = Field.field(member, 'Member Role')
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.close_reason = Field.field(deal, 'Close Reason')
      $scope.currentDeal = deal

  $scope.resetDealProductBudget = ->
    $scope.deal_product_budget = {
      deal_id: $routeParams.id
      months: []
    }

  $scope.submitForm = () ->
    $scope.errors = {}

    if !$scope.currentDeal.close_reason.option_id
      $scope.errors.reason = 'Reason is required'
      return

    $scope.currentDeal.stage_id = currentDeal.stage_id
    Deal.update(id: $scope.currentDeal.id, deal: $scope.currentDeal).then(
      (deal) ->
        $rootScope.$broadcast 'updated_deal'
        $modalInstance.close()
      (resp) ->
        $rootScope.$broadcast 'deal_update_errors', resp.data.errors
        $modalInstance.close()
    )

  $scope.cancel = ->
    $rootScope.$broadcast 'closeDealCanceled', currentDeal.id
    $modalInstance.close()

  $scope.init()
]
