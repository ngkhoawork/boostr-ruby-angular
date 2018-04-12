@app.controller 'DealsCloseController',
['$scope', '$rootScope', '$routeParams', '$modalInstance', '$q', '$location', 'Deal', 'Client', 'Field', 'currentDeal', 'hasWon'
($scope, $rootScope, $routeParams, $modalInstance, $q, $location, Deal, Client, Field, currentDeal, hasWon) ->
  $scope.selectedReason = null
  $scope.formType = "Closed Reason"
  $scope.submitText = "Submit"
  $scope.currentDeal = {}
  $scope.hasWon = hasWon
  $scope.reasonText = if hasWon then "Won Reason" else "Loss Reason"
  $scope.commentText = if hasWon then "Won Comments" else "Loss Comments"

  $scope.init = ->
    Deal.get(currentDeal.id).then (deal) ->
      $scope.setCurrentDeal(deal)

  $scope.selectReason = (reason) ->
    $scope.selectedReason = reason.name

  $scope.setCurrentDeal = (deal) ->
    Field.defaults(deal, 'Deal').then (fields) ->
      deal.close_reason = Field.field(deal, 'Close Reason')
      if deal.close_reason.option_id
        $scope.selectReason _.find(deal.close_reason.options, id: deal.close_reason.option_id)
      $scope.currentDeal = deal

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
